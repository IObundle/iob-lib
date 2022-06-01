`ifndef AXI
`define AXI
//
// Signals width
//

// Data width and address width should be defined by the user of this header
//`define AXI_DATA_W 32
//`define AXI_ADDR_W 32

// 2**1 = 2 AXI IDs
`define AXI_ID_W 1

// 2**8 = 256 max burst length
`define AXI_LEN_W 8

// Burst size width (burst size = 2, 4 bytes per word)
`define AXI_SIZE_W 3

// Burst type width (burst type = 1, Incrementing burst)
`define AXI_BURST_W 2

// Lock Type width (lock type = 0, Normal)
`define AXI_LOCK_W 1

// Memory type width (memory type = 2, Normal, non-cacheable and non-bufferable)
`define AXI_CACHE_W 4

// Protection type width (protection type = 2, Data access, non-secure access and unprivileged access)
`define AXI_PROT_W 3

// Quality of Service width (quality of service = 0, No QoS scheme implemented)
`define AXI_QOS_W 4

// Response width (response = 0 - Okay = 0; Exokay = 1; Slverr = 2; decerr = 3)
`define AXI_RESP_W 2

`endif //  `ifndef AXI
