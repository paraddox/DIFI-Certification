-- Constants
CONTEXT_PKT = "Standard Flow Signal Context Packet"
VERSION_PKT = "Version Flow Signal Context Packet"
DATA_PKT    = "Standard Flow Signal Data Packet"
CMD_PKT     = "Command Packet"
EXT_CMD_PKT = "Extension Command Packet"

local tsi_codes = {
    [0] = "Not Allowed", -- (Some ICDs call this Not Specified)
    [1] = "UTC",
    [2] = "GPS",
    [3] = "POSIX"
}

local tsf_codes = {
    [0] = "Undefined",
    [1] = "Sample Count Time",
    [2] = "Real (pico secs) Time",
    [3] = "Free-Running Count Time"
}

local command_indicator_codes = {
    [0] = "Control",
    [4] = "Acknowledge"
}

-- Common Header fields
packet_type    = ProtoField.uint8 ("difi.packet_type", "Packet Type", base.HEX, nil)
tsi            = ProtoField.uint8 ("difi.tsi", "TSI", base.DEC, tsi_codes)
tsf            = ProtoField.uint8 ("difi.tsf", "TSF", base.DEC, tsf_codes)
seq_num        = ProtoField.uint8 ("difi.seq_num", "Seq Num", base.DEC)
packet_size    = ProtoField.uint16("difi.packet_size", "Packet Size (32-bit words)", base.DEC)
stream_id      = ProtoField.uint32("difi.stream_id", "Stream ID", base.DEC)
padding_bits   = ProtoField.uint8 ("difi.padding_bits", "Padding Bits", base.DEC)
oui            = ProtoField.uint24("difi.oui", "OUI/CID", base.HEX)
packet_class_code = ProtoField.uint16("difi.packet_class_code", "Packet Class Code", base.HEX)
information_class = ProtoField.uint16("difi.information_class", "Information Class Code", base.HEX)
int_timestamp  = ProtoField.uint32("difi.integer_timestamp", "Integer-Seconds Timestamp", base.DEC)
frac_timestamp = ProtoField.uint64("difi.fractional_timestamp", "Fractional-Seconds Timestamp (ps)", base.DEC)

-- Data Header fields
data     = ProtoField.bytes ("difi.data", "Payload")
data_len = ProtoField.uint64("difi.data_len", "Length", base.DEC)

-- Context Packet Header fields
ctxt_cif      = ProtoField.uint32("difi.ctxt_cif", "Context Indicator Field", base.HEX)
ref_point     = ProtoField.uint32("difi.ref_point", "Reference Point", base.HEX)
bandwidth     = ProtoField.uint64("difi.bandwidth", "Bandwidth (Hz)", base.DEC)
if_ref_freq   = ProtoField.uint64("difi.if_ref_freq", "IF Reference Frequency (Hz)", base.DEC)
rf_ref_freq   = ProtoField.uint64("difi.rf_ref_freq", "RF Reference Frequency (Hz)", base.DEC)
if_offset     = ProtoField.int64 ("difi.if_offset", "IF Band Offset (Hz)", base.DEC)
ref_level     = ProtoField.float ("difi.ref_level", "Reference Level (dB)", base.DEC)
scaling_level = ProtoField.float ("difi.scaling_level", "Scaling Level (dB)", base.DEC)
stage1_gain   = ProtoField.float ("difi.stage1_gain", "Stage 1 Attenuation/Gain (dB)", base.DEC)
stage2_gain   = ProtoField.float ("difi.stage2_gain", "Stage 2 Attenuation/Gain (dB)", base.DEC)
sample_rate   = ProtoField.uint64("difi.sample_rate", "Sample Rate (Hz)", base.DEC)
timestamp_adj = ProtoField.uint64("difi.time_adj", "Timestamp Adjustment (fs)", base.DEC)
time_cal      = ProtoField.uint32("difi.time_cal", "Timestamp Calibration Time", base.DEC)
se_indicator  = ProtoField.uint32("difi.se_indicator", "State and Event Indicators", base.HEX)
data_format   = ProtoField.uint64("difi.data_format", "Data Packet Payload Format", base.HEX)

-- Version Header fields
ctxt_cif0     = ProtoField.uint32("difi.ctxt_cif0", "Context Indicator Field (CIF) 0", base.HEX)
ctxt_cif1     = ProtoField.uint32("difi.ctxt_cif1", "Context Indicator Field (CIF) 1", base.HEX)
v49spec       = ProtoField.uint32("difi.v49spec", "V49 Spec Version", base.HEX)
year          = ProtoField.uint32("difi.year","Year (Starting from 2000)", base.DEC, nil, 0xfe000000)
day           = ProtoField.uint32("difi.day","Day", base.DEC, nil, 0x01ff0000)
revision      = ProtoField.uint32("difi.revision","Revision", base.DEC, nil, 0x0000fc00)
user_type     = ProtoField.uint32("difi.user_type","Type (user-defined)", base.DEC, nil, 0x000003c0)
icd_version   = ProtoField.uint32("difi.icd_version","ICD Version", base.DEC, nil, 0x0000003f)

-- Command header fields
command_indicator = ProtoField.uint8 ("difi.command_indicator", "Control/Acknowledge Indicators", base.HEX, command_indicator_codes)
cam_field        = ProtoField.uint32("difi.cam_field", "CAM field", base.HEX)
message_id       = ProtoField.uint32("difi.message_id", "Message ID", base.HEX)
controllee_id    = ProtoField.uint32("difi.controllee_id", "Controllee ID", base.DEC)
controller_id    = ProtoField.uint32("difi.controller_id", "Controller ID", base.DEC)
ctrl_cif0        = ProtoField.uint32("difi.ctrl_cif0", "Control Indicator Field (CIF) 0", base.HEX)
ctrl_cif1        = ProtoField.uint32("difi.ctrl_cif1", "Control Indicator Field (CIF) 1", base.HEX)
buffer_size      = ProtoField.uint64("difi.buffer_size", "Buffer Size", base.DEC)
buffer_reserved  = ProtoField.uint16("difi.buffer_reserved","RESERVED", base.HEX)
buffer_level     = ProtoField.uint16("difi.buffer_level","Buffer Level", base.DEC, nil, 0xfff0)
buffer_overflow  = ProtoField.uint16("difi.buffer_overflow","Buffer Overflow", base.DEC, nil, 0x0008)
near_full        = ProtoField.uint16("difi.near_full","near_full", base.DEC, nil, 0x0004)
near_empty       = ProtoField.uint16("difi.near_empty","near_empty", base.DEC, nil, 0x0002)
buffer_underflow = ProtoField.uint16("difi.buffer_underflow","Buffer Underflow", base.DEC, nil, 0x0001)

-- DIFI 1.3 Extension Command packet fields
sink_time_cal_int_timestamp     = ProtoField.uint32("difi.sink_time_cal_integer_timestamp", "Sink Time Calibration Integer-Seconds", base.DEC)
sink_time_cal_frac_timestamp    = ProtoField.uint64("difi.sink_time_cal_fractional_timestamp", "Sink Time Calibration Fractional-Seconds", base.DEC)
control_int_timestamp           = ProtoField.uint32("difi.control_integer_timestamp", "Control Packet Integer-Seconds Timestamp", base.DEC)
control_frac_timestamp          = ProtoField.uint64("difi.control_fractional_timestamp", "Control Packet Fractional-Seconds Timestamp", base.DEC)
sink_reception_int_timestamp    = ProtoField.uint32("difi.sink_reception_integer_timestamp", "Sink Reception Integer-Seconds Timestamp", base.DEC)
sink_reception_frac_timestamp   = ProtoField.uint64("difi.sink_reception_fractional_timestamp", "Sink Reception Fractional-Seconds Timestamp", base.DEC)
capabilities_payload            = ProtoField.bytes ("difi.capabilities_payload", "Sink Capabilities Payload")
status_code_payload             = ProtoField.bytes ("difi.status_code_payload", "Status Code Payload")
extension_payload               = ProtoField.bytes ("difi.extension_payload", "Extension Command Payload")

-- DIFI 1.3 long-form Sink Capabilities Response fields (Tables 4-26/4-27)
capability_ic_count             = ProtoField.uint16("difi.capability_ic_count", "Number of Supported Information Classes", base.DEC)
capability_ic_1                 = ProtoField.uint16("difi.capability_ic_1", "First Supported Information Class", base.HEX)
capability_ic_2                 = ProtoField.uint16("difi.capability_ic_2", "Second Supported Information Class", base.HEX)
capability_ic_3                 = ProtoField.uint16("difi.capability_ic_3", "Third Supported Information Class", base.HEX)
capability_ref_point_count      = ProtoField.uint16("difi.capability_ref_point_count", "Number of Reference Points Supported", base.DEC)
capability_sample_rate_count    = ProtoField.uint32("difi.capability_sample_rate_count", "Number of Sample Rates/Maximum Bandwidths Supported", base.DEC, nil, 0x00007fff)
capability_bit_depth_indicator  = ProtoField.uint32("difi.capability_bit_depth_indicator", "Bit-Depth Indicator Field", base.HEX, nil, 0xfff80000)
capability_max_stream_count     = ProtoField.uint32("difi.capability_max_stream_count", "Maximum Simultaneous Stream Count", base.DEC, nil, 0x0000003f)
capability_buffer_size          = ProtoField.uint64("difi.capability_buffer_size", "Sink Capability Buffer Size (bytes)", base.DEC)

-- DIFI 1.3 Status Report fields (Table 4-29/Table 4-30)
status_word1                    = ProtoField.uint32("difi.status_word1", "Status Word 1: Packet-Related Error Bits", base.HEX)
status_word2                    = ProtoField.uint32("difi.status_word2", "Status Word 2: System Errors and Warnings", base.HEX)
status_packet_type_not_defined  = ProtoField.uint32("difi.status_packet_type_not_defined", "Selected Packet Type Not Defined", base.DEC, nil, 0x80000000)
status_packet_size_error        = ProtoField.uint32("difi.status_packet_size_error", "Incorrectly Specified Packet Size", base.DEC, nil, 0x08000000)
status_timeout_link_termination = ProtoField.uint32("difi.status_timeout_link_termination", "Timeout/Link Termination", base.DEC, nil, 0x00000010)
status_word1_reserved           = ProtoField.uint32("difi.status_word1_reserved", "Status Word 1 Reserved Bits [3:0]", base.HEX, nil, 0x0000000f)
status_frequency_lol            = ProtoField.uint32("difi.status_frequency_lol", "Frequency LOL Causing Data Stoppage", base.DEC, nil, 0x80000000)
status_timebase_lol             = ProtoField.uint32("difi.status_timebase_lol", "Timebase LOL Causing Data Stoppage", base.DEC, nil, 0x40000000)
status_buffer_overflow          = ProtoField.uint32("difi.status_buffer_overflow", "Buffer Overflow", base.DEC, nil, 0x10000000)
status_context_timeout          = ProtoField.uint32("difi.status_context_timeout", "Context Error Timeout", base.DEC, nil, 0x04000000)
status_link_termination         = ProtoField.uint32("difi.status_link_termination", "Link Termination", base.DEC, nil, 0x02000000)
status_probable_context_drop    = ProtoField.uint32("difi.status_probable_context_drop", "Probable Context Packet Drop", base.DEC, nil, 0x00008000)
status_probable_data_drop       = ProtoField.uint32("difi.status_probable_data_drop", "Probable Data Packet Drop", base.DEC, nil, 0x00004000)
status_ref_level_limit_flag     = ProtoField.uint32("difi.status_ref_level_limit_flag", "Reference Level Limit Flag", base.DEC, nil, 0x00000010)
status_sr_bw_limit_flag         = ProtoField.uint32("difi.status_sr_bw_limit_flag", "Sample Rate and Bandwidth Limits Flag", base.DEC, nil, 0x00000008)
status_word2_reserved_high      = ProtoField.uint32("difi.status_word2_reserved_high", "Status Word 2 Reserved Bits [24:16]", base.HEX, nil, 0x01ff0000)
status_word2_reserved_mid       = ProtoField.uint32("difi.status_word2_reserved_mid", "Status Word 2 Reserved Bits [10:5]", base.HEX, nil, 0x000007e0)
status_word2_reserved_low       = ProtoField.uint32("difi.status_word2_reserved_low", "Status Word 2 Reserved Bits [2:0]", base.HEX, nil, 0x00000007)
status_reserved_word            = ProtoField.uint32("difi.status_reserved_word", "Status Payload Reserved Word", base.HEX)
status_ref_level_limit          = ProtoField.uint64("difi.status_ref_level_limit", "Reference Level Limit", base.HEX)
status_sample_rate_limit        = ProtoField.uint64("difi.status_sample_rate_limit", "Sample Rate Limit", base.HEX)
status_bandwidth_limit          = ProtoField.uint64("difi.status_bandwidth_limit", "Bandwidth Limit", base.HEX)

difi_protocol = Proto("DIFI", "DIFI Protocol")

-- Register all fields
difi_protocol.fields = {
    -- common
    packet_type, packet_size, seq_num, tsi, tsf, stream_id, padding_bits, oui,
    packet_class_code, information_class, int_timestamp, frac_timestamp,
    -- data
    data, data_len,
    -- context
    ctxt_cif, ref_point, bandwidth, if_ref_freq, rf_ref_freq, if_offset, ref_level, scaling_level,
    stage1_gain, stage2_gain, sample_rate, timestamp_adj, time_cal, se_indicator, data_format,
    -- version
    ctxt_cif0, ctxt_cif1, v49spec, year, day, revision, user_type, icd_version,
    -- command
    command_indicator, cam_field, message_id, controllee_id, controller_id, ctrl_cif0, ctrl_cif1,
    buffer_size, buffer_reserved, buffer_level, buffer_overflow, near_full, near_empty, buffer_underflow,
    -- DIFI 1.3 extension command
    sink_time_cal_int_timestamp, sink_time_cal_frac_timestamp,
    control_int_timestamp, control_frac_timestamp,
    sink_reception_int_timestamp, sink_reception_frac_timestamp,
    capabilities_payload, status_code_payload, extension_payload,
    capability_ic_count, capability_ic_1, capability_ic_2, capability_ic_3,
    capability_ref_point_count, capability_sample_rate_count,
    capability_bit_depth_indicator, capability_max_stream_count, capability_buffer_size,
    status_word1, status_word2, status_packet_type_not_defined, status_packet_size_error,
    status_timeout_link_termination, status_word1_reserved, status_frequency_lol,
    status_timebase_lol, status_buffer_overflow, status_context_timeout,
    status_link_termination, status_probable_context_drop, status_probable_data_drop,
    status_ref_level_limit_flag, status_sr_bw_limit_flag, status_word2_reserved_high,
    status_word2_reserved_mid, status_word2_reserved_low, status_reserved_word,
    status_ref_level_limit, status_sample_rate_limit, status_bandwidth_limit
}

-- Helpers ----------------------------------------------------

-- All frequency and sample rate fields are 64-bit 2's complement with radix point right of bit 20.
local function get_int_freq(word64)
    return word64:rshift(20)
end

-- Convert 16-bit signed fixed-point with radix at bit 7 into dB float.
local function get_dB(word16)
    local db_val = 0.0
    if (bit.band(word16,0x8000) == 0x8000) then
        local temp = (bit.bxor(word16, 0xffff)) + 1
        db_val = -temp/0x80
    else
        db_val = word16/0x80
    end
    return db_val
end

-- Common header
local function difi_common_dissector(buffer, tree)
    local word0 = buffer(0, 4):uint()
    local word3 = buffer(12, 4):uint()

    tree:add(packet_type,  bit.rshift(bit.band(word0, 0xF0000000), 28))
    tree:add(packet_size,  bit.band(word0, 0xffff))
    tree:add(seq_num,      bit.rshift(bit.band(word0, 0x000F0000), 16))
    tree:add(tsi,          bit.rshift(bit.band(word0, 0x00C00000), 22))
    tree:add(tsf,          bit.rshift(bit.band(word0, 0x00300000), 20))
    tree:add(stream_id,    buffer(4, 4):uint())

    -- padding bits (byte 8) + OUI/CID (bytes 9..11)
    tree:add(padding_bits, buffer(8,1):uint())
    tree:add(oui,          buffer(9,3):uint())

    tree:add(packet_class_code, bit.band(word3, 0xffff))
    tree:add(information_class, bit.rshift(word3, 16))
    tree:add(int_timestamp,  buffer(16, 4):uint())
    tree:add(frac_timestamp, buffer(20, 8):uint64())
end

-- Packet dissectors ------------------------------------------

local function context_pkt_dissector(buffer, tree, name)
    if buffer:len() < 108 then return end

    local subtree = tree:add(difi_protocol, buffer(0, 108), "DIFI Protocol, " .. name)

    -- Header
    difi_common_dissector(buffer, subtree)

    -- Additional header fields
    subtree:add(ctxt_cif,  buffer(28, 4):uint())
    subtree:add(ref_point, buffer(32, 4):uint())

    -- 64-bit fixed-point -> integer Hz via shift
    local bw_int       = get_int_freq(buffer(36, 8):uint64())
    local if_ref_int   = get_int_freq(buffer(44, 8):uint64())
    local rf_ref_int   = get_int_freq(buffer(52, 8):uint64())
    local if_offset_i  = get_int_freq(buffer(60, 8):int64())
    subtree:add(bandwidth,   bw_int)
    subtree:add(if_ref_freq, if_ref_int)
    subtree:add(rf_ref_freq, rf_ref_int)
    subtree:add(if_offset,   if_offset_i)

    -- Levels/Gains (two 16-bit fixed-point values in each 32-bit word)
    local level_word = buffer(68,4):int()
    local ref_level_word16     = bit.band(level_word, 0xFFFF)
    local scaling_level_word16 = bit.rshift(bit.band(level_word, 0xFFFF0000), 16)
    subtree:add(ref_level,     get_dB(ref_level_word16))
    subtree:add(scaling_level, get_dB(scaling_level_word16))

    local gain_word = buffer(72,4):int()
    local stage1_gain_word16 = bit.band(gain_word, 0xFFFF)
    local stage2_gain_word16 = bit.rshift(bit.band(gain_word, 0xFFFF0000), 16)
    subtree:add(stage1_gain, get_dB(stage1_gain_word16))
    subtree:add(stage2_gain, get_dB(stage2_gain_word16))

    local sample_rate_int = get_int_freq(buffer(76,8):uint64())
    subtree:add(sample_rate, sample_rate_int)

    subtree:add(timestamp_adj, buffer(84, 8):uint64())
    subtree:add(time_cal,      buffer(92, 4):uint())
    subtree:add(se_indicator,  buffer(96, 4):uint())
    subtree:add(data_format,   buffer(100, 8):uint64())
end

local function data_pkt_dissector(buffer, tree, name)
    if buffer:len() < 28 then return end

    local length  = buffer:len()
    local subtree = tree:add(difi_protocol, buffer(0, 28), "DIFI Protocol, " .. name)

    -- Header
    difi_common_dissector(buffer, subtree)

    -- Payload
    local payload_len   = length - 28
    if payload_len > 0 then
        local data_subtree = subtree:add(difi_protocol, buffer(28, payload_len), "Data")
        data_subtree:add(data, buffer(28, payload_len))
    end
end

local function version_pkt_dissector(buffer, tree, name)
    if buffer:len() < 44 then return end

    local subtree = tree:add(difi_protocol, buffer(0, 44), "DIFI Protocol, " .. name)

    -- Header
    difi_common_dissector(buffer, subtree)

    -- Version fields
    subtree:add(ctxt_cif0, buffer(28, 4):uint())
    subtree:add(ctxt_cif1, buffer(32, 4):uint())
    subtree:add(v49spec,   buffer(36, 4):uint())

    -- Packed bitfields in the last 32-bit word
    subtree:add_packet_field(year,      buffer(40,4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(day,       buffer(40,4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(revision,  buffer(40,4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(user_type, buffer(40,4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(icd_version, buffer(40,4), ENC_BIG_ENDIAN)
end

local function control_pkt_dissector(buffer, tree, name)
    if buffer:len() < 84 then return end

    local subtree = tree:add(difi_protocol, buffer(0, 84), "DIFI Protocol, " .. name)

    -- Header
    difi_common_dissector(buffer, subtree)

    subtree:add_packet_field(cam_field,     buffer(28, 4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(message_id,    buffer(32, 4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(controllee_id, buffer(36, 4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(controller_id, buffer(40, 4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(ctrl_cif0,     buffer(44, 4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(ctrl_cif1,     buffer(48, 4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(ref_point,     buffer(52, 4), ENC_BIG_ENDIAN)

    local sample_rate_int = get_int_freq(buffer(56,8):uint64())
    subtree:add(sample_rate, sample_rate_int)

    subtree:add_packet_field(timestamp_adj,   buffer(64, 8), ENC_BIG_ENDIAN)
    subtree:add_packet_field(buffer_size,     buffer(72, 8), ENC_BIG_ENDIAN)
    subtree:add_packet_field(buffer_reserved, buffer(80, 2), ENC_BIG_ENDIAN)
    subtree:add_packet_field(buffer_level,    buffer(82, 2), ENC_BIG_ENDIAN)
    subtree:add_packet_field(buffer_overflow, buffer(82, 2), ENC_BIG_ENDIAN)
    subtree:add_packet_field(near_full,       buffer(82, 2), ENC_BIG_ENDIAN)
    subtree:add_packet_field(near_empty,      buffer(82, 2), ENC_BIG_ENDIAN)
    subtree:add_packet_field(buffer_underflow,buffer(82, 2), ENC_BIG_ENDIAN)
end

local function add_sink_capability_long_fields(buffer, subtree, packet_len)
    -- DIFI 1.3 Tables 4-26/4-27 define the long-form response payload as a
    -- table of supported information classes, reference points, rate/bandwidth
    -- capabilities, and trailing sink limits. Decode the stable table fields
    -- with fixed word positions; keep the raw payload as a fallback for variable
    -- or implementation-specific list lengths.
    if packet_len >= 56 then
        subtree:add_packet_field(capability_ic_count, buffer(52, 2), ENC_BIG_ENDIAN)
        subtree:add_packet_field(capability_ic_1,     buffer(54, 2), ENC_BIG_ENDIAN)
    end
    if packet_len >= 60 then
        subtree:add_packet_field(capability_ic_2,     buffer(56, 2), ENC_BIG_ENDIAN)
        subtree:add_packet_field(capability_ic_3,     buffer(58, 2), ENC_BIG_ENDIAN)
    end
    if packet_len >= 68 then
        subtree:add_packet_field(capability_ref_point_count, buffer(66, 2), ENC_BIG_ENDIAN)
    end
    if packet_len >= 88 then
        subtree:add_packet_field(capability_sample_rate_count, buffer(84, 4), ENC_BIG_ENDIAN)
    end
    if packet_len >= 240 then
        subtree:add_packet_field(capability_bit_depth_indicator, buffer(236, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(capability_max_stream_count,    buffer(236, 4), ENC_BIG_ENDIAN)
    end
    if packet_len >= 252 then
        subtree:add_packet_field(capability_buffer_size, buffer(244, 8), ENC_BIG_ENDIAN)
    end
end

local function add_status_report_fields(buffer, subtree, packet_len)
    -- DIFI 1.3 Table 4-29/4-30: CIF0 is followed by Status Word 1,
    -- Status Word 2, a reserved word, and optional quantitative fields for
    -- 17-word and 21-word status reports.
    if packet_len >= 56 then
        subtree:add_packet_field(status_word1,                   buffer(48, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_packet_type_not_defined, buffer(48, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_packet_size_error,       buffer(48, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_timeout_link_termination,buffer(48, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_word1_reserved,          buffer(48, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_word2,                   buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_frequency_lol,           buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_timebase_lol,            buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_buffer_overflow,         buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_context_timeout,         buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_link_termination,        buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_probable_context_drop,   buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_probable_data_drop,      buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_ref_level_limit_flag,    buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_sr_bw_limit_flag,        buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_word2_reserved_high,     buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_word2_reserved_mid,      buffer(52, 4), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_word2_reserved_low,      buffer(52, 4), ENC_BIG_ENDIAN)
    end
    if packet_len >= 60 then
        subtree:add_packet_field(status_reserved_word, buffer(56, 4), ENC_BIG_ENDIAN)
    end
    if packet_len >= 68 then
        subtree:add_packet_field(status_ref_level_limit, buffer(60, 8), ENC_BIG_ENDIAN)
    end
    if packet_len >= 84 then
        subtree:add_packet_field(status_sample_rate_limit, buffer(68, 8), ENC_BIG_ENDIAN)
        subtree:add_packet_field(status_bandwidth_limit,   buffer(76, 8), ENC_BIG_ENDIAN)
    end
end

local function extension_command_pkt_dissector(buffer, tree, name)
    -- DIFI 1.3 Extension Command packets all include the 7-word prologue plus
    -- CAM, Message ID, Controllee ID, Controller ID, and CIF0 (12 words total).
    -- Packet classes 0x0007, 0x0008, and 0x0009 then interpret the remaining
    -- words differently.
    if buffer:len() < 48 then return end

    local word0 = buffer(0,4):uint()
    local word3 = buffer(12,4):uint()
    local packet_class_int = bit.band(word3, 0x0000ffff)
    local size_words = bit.band(word0, 0xffff)
    local size_bytes = size_words * 4
    local packet_len = buffer:len()
    if size_words > 0 and size_bytes < packet_len then
        packet_len = size_bytes
    end

    local subtree = tree:add(difi_protocol, buffer(0, packet_len), "DIFI Protocol, " .. name)

    difi_common_dissector(buffer, subtree)

    subtree:add(command_indicator, bit.rshift(bit.band(word0, 0x07000000), 24))
    subtree:add_packet_field(cam_field,     buffer(28, 4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(message_id,    buffer(32, 4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(controllee_id, buffer(36, 4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(controller_id, buffer(40, 4), ENC_BIG_ENDIAN)
    subtree:add_packet_field(ctrl_cif0,     buffer(44, 4), ENC_BIG_ENDIAN)

    local cif0 = buffer(44, 4):uint()
    local is_short_form = bit.band(cif0, 0x80000000) ~= 0

    if packet_class_int == 0x0007 then
        -- Sink Capability Query Control.
        -- Short form: CIF0 bit 31 set, optional Sink Time Calibration words.
        -- Long form: CIF0 bit 31 clear, CIF1 follows.
        if is_short_form then
            subtree:add("Sink Capability Query Form: Short")
            if packet_len >= 60 then
                subtree:add_packet_field(sink_time_cal_int_timestamp,  buffer(48, 4), ENC_BIG_ENDIAN)
                subtree:add_packet_field(sink_time_cal_frac_timestamp, buffer(52, 8), ENC_BIG_ENDIAN)
            end
        else
            subtree:add("Sink Capability Query Form: Long")
            if packet_len >= 52 then
                subtree:add_packet_field(ctrl_cif1, buffer(48, 4), ENC_BIG_ENDIAN)
            end
        end

    elseif packet_class_int == 0x0008 then
        -- Sink Capability Response Acknowledge.
        -- Short form carries echoed query timestamps and sink reception time.
        -- Long form carries a variable capabilities payload after CIF1.
        if is_short_form then
            subtree:add("Sink Capability Response Form: Short")
            if packet_len >= 72 then
                subtree:add_packet_field(control_int_timestamp,         buffer(48, 4), ENC_BIG_ENDIAN)
                subtree:add_packet_field(control_frac_timestamp,        buffer(52, 8), ENC_BIG_ENDIAN)
                subtree:add_packet_field(sink_reception_int_timestamp,  buffer(60, 4), ENC_BIG_ENDIAN)
                subtree:add_packet_field(sink_reception_frac_timestamp, buffer(64, 8), ENC_BIG_ENDIAN)
            end
        else
            subtree:add("Sink Capability Response Form: Long")
            if packet_len >= 52 then
                subtree:add_packet_field(ctrl_cif1, buffer(48, 4), ENC_BIG_ENDIAN)
            end
            if packet_len > 52 then
                subtree:add(capabilities_payload, buffer(52, packet_len - 52))
                add_sink_capability_long_fields(buffer, subtree, packet_len)
            end
        end

    elseif packet_class_int == 0x0009 then
        -- Status Report Control. CIF0 is all zero per DIFI 1.3; remaining
        -- words are the status-code payload plus optional quantitative fields.
        if packet_len > 48 then
            subtree:add(status_code_payload, buffer(48, packet_len - 48))
            add_status_report_fields(buffer, subtree, packet_len)
        end

    elseif packet_len > 48 then
        subtree:add(extension_payload, buffer(48, packet_len - 48))
    end
end

-- Heuristic --------------------------------------------------

local function heuristic_checker(buffer, pinfo, tree)
    -- guard for minimal header: 7 * 32-bit words = 28 bytes
    if buffer:len() < 28 then return false end

    -- OUI/CID is 24 bits at bytes 9..11 (pad at byte 8)
    local potential_oui = buffer(9, 3):uint()
    if (potential_oui ~= 0x7C386C and potential_oui ~= 0x6A621E) then
        return false
    end

    local word0 = buffer(0,4):uint()
    local packet_type_int = bit.rshift(bit.band(word0,0xf0000000), 28)
    local valid_ptype = (packet_type_int == 4 or packet_type_int == 5 or packet_type_int == 1 or packet_type_int == 6 or packet_type_int == 7)
    if not valid_ptype then return false end

    if packet_type_int == 7 then
        local packet_class_int = bit.band(buffer(12,4):uint(), 0x0000ffff)
        local valid_extension_class = (packet_class_int == 7 or packet_class_int == 8 or packet_class_int == 9)
        if not valid_extension_class then return false end
    end

    -- Optional: basic size sanity check (packet_size is in 32-bit words)
    local size_words = bit.band(word0, 0xffff)
    local size_bytes = size_words * 4
    if size_words > 0 and buffer:len() < size_bytes then
        return false
    end

    -- Looks like DIFI—hand over to the dissector
    difi_protocol.dissector(buffer, pinfo, tree)
    return true
end

-- Main dissector --------------------------------------------

function difi_protocol.dissector(buffer, pinfo, tree)
    if buffer:len() < 28 then return end

    local word0 = buffer(0,4):uint()
    local word3 = buffer(12,4):uint()
    local packet_type_int  = bit.rshift(bit.band(word0,0xf0000000), 28)
    local packet_class_int = bit.band(word3, 0x0000ffff)

    -- Optional: enforce size sanity here as well
    local size_words = bit.band(word0, 0xffff)
    local size_bytes = size_words * 4
    if size_words > 0 and buffer:len() < size_bytes then
        return
    end

    local name = "unknown type=" .. packet_type_int .. " , class=" .. packet_class_int

    if packet_type_int == 0x4 then
        if packet_class_int == 1 then name = "Standard Flow Signal Context Packet" end
        if packet_class_int == 3 then name = "Sample Count Context Packet" end
        if packet_class_int == 4 then
            name = "Version Flow Signal Context Packet"
            version_pkt_dissector(buffer, tree, name)
        else
            context_pkt_dissector(buffer, tree, name)
        end

    elseif packet_type_int == 0x5 then
        name = "Version Flow Signal Context Packet"
        version_pkt_dissector(buffer, tree, name)

    elseif packet_type_int == 0x1 then
        if packet_class_int == 0 then name = "Standard Flow Signal Data Packet" end
        if packet_class_int == 2 then name = "Sample Count Data Packet" end
        data_pkt_dissector(buffer, tree, name)

    elseif packet_type_int == 0x6 then
        if packet_class_int == 6 then name = "Real Time Command Packet" end
        if packet_class_int == 5 then name = "Sample Count Command Packet" end
        control_pkt_dissector(buffer, tree, name)

    elseif packet_type_int == 0x7 then
        if packet_class_int == 7 then name = "Sink Capability Query Control Packet" end
        if packet_class_int == 8 then name = "Sink Capability Response Acknowledge Packet" end
        if packet_class_int == 9 then name = "Status Report Control Packet" end
        extension_command_pkt_dissector(buffer, tree, name)
    end

    pinfo.cols.protocol = difi_protocol.name
end

-- Register heuristic on UDP
difi_protocol:register_heuristic("udp", heuristic_checker)
