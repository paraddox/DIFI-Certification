#!/usr/bin/env python3
"""Smoke-test DIFI 1.3 Wireshark dissector coverage with synthetic UDP pcaps.

The test intentionally writes a small libpcap file with only stdlib helpers so
it can run after installing tshark without extra Python test dependencies.
"""

from __future__ import annotations

import ipaddress
import shutil
import struct
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DISSECTOR = ROOT / "difi-dissector.lua"


def u32_words(*words: int) -> bytes:
    return b"".join(struct.pack(">I", word & 0xFFFFFFFF) for word in words)


def checksum(data: bytes) -> int:
    if len(data) % 2:
        data += b"\x00"
    total = sum(struct.unpack("!%dH" % (len(data) // 2), data))
    total = (total & 0xFFFF) + (total >> 16)
    total = (total & 0xFFFF) + (total >> 16)
    return (~total) & 0xFFFF


def udp_frame(payload: bytes, packet_index: int) -> bytes:
    src_ip = ipaddress.IPv4Address("192.0.2.10").packed
    dst_ip = ipaddress.IPv4Address("192.0.2.20").packed

    udp = struct.pack("!HHHH", 4991, 50000, 8 + len(payload), 0) + payload
    ip_without_checksum = struct.pack(
        "!BBHHHBBH4s4s",
        0x45,
        0,
        20 + len(udp),
        packet_index,
        0,
        64,
        17,
        0,
        src_ip,
        dst_ip,
    )
    ip_header = struct.pack(
        "!BBHHHBBH4s4s",
        0x45,
        0,
        20 + len(udp),
        packet_index,
        0,
        64,
        17,
        checksum(ip_without_checksum),
        src_ip,
        dst_ip,
    )
    ethernet = b"\x02\x00\x00\x00\x00\x02" + b"\x02\x00\x00\x00\x00\x01" + struct.pack("!H", 0x0800)
    return ethernet + ip_header + udp


def write_pcap(path: Path, payloads: list[bytes]) -> None:
    with path.open("wb") as handle:
        handle.write(struct.pack("<IHHIIII", 0xA1B2C3D4, 2, 4, 0, 0, 65535, 1))
        for index, payload in enumerate(payloads, start=1):
            frame = udp_frame(payload, index)
            handle.write(struct.pack("<IIII", index, 0, len(frame), len(frame)))
            handle.write(frame)


def extension_header(packet_class: int, packet_size_words: int, command_indicator: int, seq_num: int = 0) -> list[int]:
    # Packet type 0x7, CE bit set, C/A indicator in bits 26..24, UTC TSI,
    # real-time/picoseconds TSF, and packet size in 32-bit words.
    word0 = (
        (0x7 << 28)
        | (1 << 27)
        | ((command_indicator & 0x7) << 24)
        | (1 << 22)
        | (2 << 20)
        | ((seq_num & 0xF) << 16)
        | packet_size_words
    )
    return [
        word0,
        0x00000000,  # Stream ID; zero is required for IC 0x0101.
        0x006A621E,  # DIFI OUI/CID.
        (0x0101 << 16) | packet_class,
        0x00000000,  # Integer timestamp.
        0x00000000,
        0x00000000,  # Fractional timestamp.
    ]


def sink_capability_query_long() -> bytes:
    words = extension_header(0x0007, 13, command_indicator=0, seq_num=1)
    words += [
        0xA1100000,  # CAM: control, execute, validation ack requested.
        0x00000001,  # Message ID.
        0x00000000,  # Controllee ID.
        0x00000000,  # Controller ID.
        0x40300004,  # CIF0 long form.
        0x00000002,  # CIF1: buffer-size field requested.
    ]
    return u32_words(*words)


def sink_capability_response_short() -> bytes:
    words = extension_header(0x0008, 18, command_indicator=4, seq_num=2)
    words += [
        0xA1100400,  # CAM: acknowledge, execute, validation ack, executed in time.
        0x00000001,  # Message ID echoed from query.
        0x00000000,
        0x00000000,
        0x80000000,  # CIF0 short form.
        0x00000000,  # Control packet integer timestamp.
        0x00000000,
        0x00000000,  # Control packet fractional timestamp.
        0x00000000,  # Sink reception integer timestamp.
        0x00000000,
        0x00000000,  # Sink reception fractional timestamp.
    ]
    return u32_words(*words)


def sink_capability_response_long_table_cif0() -> bytes:
    # DIFI 1.3 PDF Tables 4-26/4-27 show long-form response CIF0 as
    # 0x7FB80002, while the surrounding prose uses the sparse CIF0 value
    # 0x40300004. The dissector should decode either value.
    words = extension_header(0x0008, 70, command_indicator=4, seq_num=5)
    words += [
        0xA1100400,  # CAM: acknowledge, execute, validation ack, executed in time.
        0x00000001,  # Message ID echoed from query.
        0x00000000,
        0x00000000,
        0x7FB80002,  # CIF0 long form from DIFI 1.3 tables.
        0x00000002,  # CIF1: buffer-size field present.
    ]
    words += [0x00000000] * (70 - len(words))
    # Table 4-26 fixed-position payload fields.
    words[13] = (3 << 16) | 0x0100          # Word 14: IC count + first IC.
    words[14] = (0x0101 << 16) | 0x0102     # Word 15: second + third IC.
    words[16] = 0x00000001                  # Word 17: one reference point.
    words[21] = (1 << 15) | 2               # Word 22: discrete sample-rate/BW list, count=2.
    words[59] = (0x0123 << 19) | 7          # Word 60: bit-depth indicator + max streams.
    words[61] = 0x00000000                  # Words 62-63: 64-bit buffer size.
    words[62] = 0x00100000
    return u32_words(*words)


def status_report() -> bytes:
    words = extension_header(0x0009, 21, command_indicator=0, seq_num=3)
    words[1] = 0x11223344  # Status reports are paired to a stream for 0x01XX != 0x0101.
    words[3] = (0x0100 << 16) | 0x0009
    words += [
        0xA1100000,
        0x00000002,
        0x00000000,
        0x00000000,
        0x00000000,  # CIF0 all zeros.
        0x88000010,  # Status word 1: packet type undefined + packet size + timeout.
        0x94008018,  # Status word 2: frequency LOL + buffer overflow + context timeout + flags.
        0x00000000,  # Reserved status payload word.
        0x00000000,
        0x00001234,  # Reference level limit.
        0x00000000,
        0x00100000,  # Sample rate limit.
        0x00000000,
        0x00200000,  # Bandwidth limit.
    ]
    return u32_words(*words)


def version_flow_context() -> bytes:
    # DIFI 1.3 uses packet type 0x4 / packet class 0x0004 for Version Flow
    # Signal Context packets. Keep the legacy packet type 0x5 path separate.
    word0 = (0x4 << 28) | (1 << 27) | (1 << 24) | (1 << 22) | (2 << 20) | (4 << 16) | 11
    version_info = (25 << 25) | (1 << 16) | (1 << 10) | (0 << 6) | 0
    return u32_words(
        word0,
        0x00000000,
        0x006A621E,
        (0x0001 << 16) | 0x0004,
        0x00000000,
        0x00000000,
        0x00000000,
        0x80000002,
        0x0000000C,
        0x00000004,
        version_info,
    )


def parse_int(value: str) -> int | None:
    value = value.strip()
    if not value:
        return None
    return int(value, 0)


def main() -> int:
    tshark = shutil.which("tshark")
    if not tshark:
        print("SKIP: tshark is not installed")
        return 0

    with tempfile.TemporaryDirectory() as tmp:
        dissector_path = Path(tmp) / "difi-dissector.lua"
        shutil.copyfile(DISSECTOR, dissector_path)
        pcap_path = Path(tmp) / "difi13-extension-command.pcap"
        write_pcap(
            pcap_path,
            [
                version_flow_context(),
                sink_capability_query_long(),
                sink_capability_response_short(),
                sink_capability_response_long_table_cif0(),
                status_report(),
            ],
        )

        cmd = [
            tshark,
            "-r",
            str(pcap_path),
            "-X",
            f"lua_script:{dissector_path}",
            "-o",
            "udp.try_heuristic_first:TRUE",
            "-T",
            "fields",
            "-E",
            "separator=,",
            "-E",
            "occurrence=f",
            "-e",
            "frame.number",
            "-e",
            "difi.packet_type",
            "-e",
            "difi.packet_class_code",
            "-e",
            "difi.command_indicator",
            "-e",
            "difi.ctrl_cif0",
            "-e",
            "difi.v49spec",
            "-e",
            "difi.capability_ic_count",
            "-e",
            "difi.capability_ic_1",
            "-e",
            "difi.capability_ic_2",
            "-e",
            "difi.capability_ic_3",
            "-e",
            "difi.capability_ref_point_count",
            "-e",
            "difi.capability_sample_rate_count",
            "-e",
            "difi.capability_max_stream_count",
            "-e",
            "difi.capability_buffer_size",
            "-e",
            "difi.status_word1",
            "-e",
            "difi.status_word2",
            "-e",
            "difi.status_packet_type_not_defined",
            "-e",
            "difi.status_packet_size_error",
            "-e",
            "difi.status_context_timeout",
            "-e",
            "difi.status_ref_level_limit_flag",
            "-e",
            "difi.status_sr_bw_limit_flag",
            "-e",
            "difi.status_ref_level_limit",
            "-e",
            "difi.status_sample_rate_limit",
            "-e",
            "difi.status_bandwidth_limit",
        ]
        result = subprocess.run(cmd, text=True, capture_output=True)
        if result.returncode != 0:
            print(result.stdout)
            print(result.stderr, file=sys.stderr)
            raise SystemExit(result.returncode)

    print(result.stdout)
    rows = [line.split(",") for line in result.stdout.splitlines() if line.strip()]
    packet_types = {parse_int(row[1]) for row in rows if len(row) > 1}
    packet_classes = {parse_int(row[2]) for row in rows if len(row) > 2}
    command_indicators = {parse_int(row[3]) for row in rows if len(row) > 3}
    cif0_values = {parse_int(row[4]) for row in rows if len(row) > 4}
    v49spec_values = {parse_int(row[5]) for row in rows if len(row) > 5}
    capability_ic_counts = {parse_int(row[6]) for row in rows if len(row) > 6}
    capability_ic_1_values = {parse_int(row[7]) for row in rows if len(row) > 7}
    capability_ic_2_values = {parse_int(row[8]) for row in rows if len(row) > 8}
    capability_ic_3_values = {parse_int(row[9]) for row in rows if len(row) > 9}
    capability_ref_point_counts = {parse_int(row[10]) for row in rows if len(row) > 10}
    capability_sample_rate_counts = {parse_int(row[11]) for row in rows if len(row) > 11}
    capability_max_stream_counts = {parse_int(row[12]) for row in rows if len(row) > 12}
    capability_buffer_sizes = {parse_int(row[13]) for row in rows if len(row) > 13}
    status_word1_values = {parse_int(row[14]) for row in rows if len(row) > 14}
    status_word2_values = {parse_int(row[15]) for row in rows if len(row) > 15}
    status_packet_type_bits = {parse_int(row[16]) for row in rows if len(row) > 16}
    status_packet_size_bits = {parse_int(row[17]) for row in rows if len(row) > 17}
    status_context_timeout_bits = {parse_int(row[18]) for row in rows if len(row) > 18}
    status_ref_level_limit_bits = {parse_int(row[19]) for row in rows if len(row) > 19}
    status_sr_bw_limit_bits = {parse_int(row[20]) for row in rows if len(row) > 20}
    status_ref_level_limits = {parse_int(row[21]) for row in rows if len(row) > 21}
    status_sample_rate_limits = {parse_int(row[22]) for row in rows if len(row) > 22}
    status_bandwidth_limits = {parse_int(row[23]) for row in rows if len(row) > 23}

    assert {0x4, 0x7}.issubset(packet_types), packet_types
    assert {0x0004, 0x0007, 0x0008, 0x0009}.issubset(packet_classes), packet_classes
    assert 0x4 in command_indicators, command_indicators
    assert {0x40300004, 0x7FB80002, 0x80000000, 0x00000000}.issubset(cif0_values), cif0_values
    assert 0x00000004 in v49spec_values, v49spec_values
    assert 3 in capability_ic_counts, capability_ic_counts
    assert {0x0100}.issubset(capability_ic_1_values), capability_ic_1_values
    assert {0x0101}.issubset(capability_ic_2_values), capability_ic_2_values
    assert {0x0102}.issubset(capability_ic_3_values), capability_ic_3_values
    assert 1 in capability_ref_point_counts, capability_ref_point_counts
    assert 2 in capability_sample_rate_counts, capability_sample_rate_counts
    assert 7 in capability_max_stream_counts, capability_max_stream_counts
    assert 0x00100000 in capability_buffer_sizes, capability_buffer_sizes
    assert 0x88000010 in status_word1_values, status_word1_values
    assert 0x94008018 in status_word2_values, status_word2_values
    assert 1 in status_packet_type_bits, status_packet_type_bits
    assert 1 in status_packet_size_bits, status_packet_size_bits
    assert 1 in status_context_timeout_bits, status_context_timeout_bits
    assert 1 in status_ref_level_limit_bits, status_ref_level_limit_bits
    assert 1 in status_sr_bw_limit_bits, status_sr_bw_limit_bits
    assert 0x00001234 in status_ref_level_limits, status_ref_level_limits
    assert 0x00100000 in status_sample_rate_limits, status_sample_rate_limits
    assert 0x00200000 in status_bandwidth_limits, status_bandwidth_limits
    print("PASS: DIFI 1.3 version-flow and extension command packets decoded")
    return 0


if __name__ == "__main__":
    sys.exit(main())
