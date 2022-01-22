//
// Signals width
//

// Address width
`define AXI_ADDR_W 32

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

//
// AXI-4 full
//

// Port

`define AXI4_M_IF_PORT(PREFIX) \
    /*address write*/ \
    output [`AXI_ID_W-1:0]    PREFIX``axi_awid,    /*Address write channel ID*/ \
    output [AXI_ADDR_W-1:0]   PREFIX``axi_awaddr,  /*Address write channel address*/ \
    output [`AXI_LEN_W-1:0]   PREFIX``axi_awlen,   /*Address write channel burst length*/ \
    output [`AXI_SIZE_W-1:0]  PREFIX``axi_awsize,  /*Address write channel burst size. This signal indicates the size of each transfer in the burst*/ \
    output [`AXI_BURST_W-1:0] PREFIX``axi_awburst, /*Address write channel burst type*/ \
    output [`AXI_LOCK_W-1:0]  PREFIX``axi_awlock,  /*Address write channel lock type*/ \
    output [`AXI_CACHE_W-1:0] PREFIX``axi_awcache, /*Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).*/ \
    output [`AXI_PROT_W-1:0]  PREFIX``axi_awprot,  /*Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    output [`AXI_QOS_W-1:0]   PREFIX``axi_awqos,   /*Address write channel quality of service*/ \
    output                    PREFIX``axi_awvalid, /*Address write channel valid*/ \
    input                     PREFIX``axi_awready, /*Address write channel ready*/ \
    /*write*/ \
    output [`AXI_ID_W-1:0]    PREFIX``axi_wid,     /*Write channel ID*/ \
    output [AXI_DATA_W-1:0]   PREFIX``axi_wdata,   /*Write channel data*/ \
    output [AXI_DATA_W/8-1:0] PREFIX``axi_wstrb,   /*Write channel write strobe*/ \
    output                    PREFIX``axi_wlast,   /*Write channel last word flag*/ \
    output                    PREFIX``axi_wvalid,  /*Write channel valid*/ \
    input                     PREFIX``axi_wready,  /*Write channel ready*/ \
    /*write response*/ \
    input [`AXI_ID_W-1:0]     PREFIX``axi_bid,     /*Write response channel ID*/ \
    input [`AXI_RESP_W-1:0]   PREFIX``axi_bresp,   /*Write response channel response*/ \
    input                     PREFIX``axi_bvalid,  /*Write response channel valid*/ \
    output                    PREFIX``axi_bready,  /*Write response channel ready*/ \
    /*address read*/ \
    output [`AXI_ID_W-1:0]    PREFIX``axi_arid,    /*Address read channel ID*/ \
    output [AXI_ADDR_W-1:0]   PREFIX``axi_araddr,  /*Address read channel address*/ \
    output [`AXI_LEN_W-1:0]   PREFIX``axi_arlen,   /*Address read channel burst length*/ \
    output [`AXI_SIZE_W-1:0]  PREFIX``axi_arsize,  /*Address read channel burst size. This signal indicates the size of each transfer in the burst*/ \
    output [`AXI_BURST_W-1:0] PREFIX``axi_arburst, /*Address read channel burst type*/ \
    output [`AXI_LOCK_W-1:0]  PREFIX``axi_arlock,  /*Address read channel lock type*/ \
    output [`AXI_CACHE_W-1:0] PREFIX``axi_arcache, /*Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).*/ \
    output [`AXI_PROT_W-1:0]  PREFIX``axi_arprot,  /*Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    output [`AXI_QOS_W-1:0]   PREFIX``axi_arqos,   /*Address read channel quality of service*/ \
    output                    PREFIX``axi_arvalid, /*Address read channel valid*/ \
    input                     PREFIX``axi_arready, /*Address read channel ready*/ \
    /*read*/ \
    input [`AXI_ID_W-1:0]     PREFIX``axi_rid,     /*Read channel ID*/ \
    input [AXI_DATA_W-1:0]    PREFIX``axi_rdata,   /*Read channel data*/ \
    input [`AXI_RESP_W-1:0]   PREFIX``axi_rresp,   /*Read channel response*/ \
    input                     PREFIX``axi_rlast,   /*Read channel last word*/ \
    input                     PREFIX``axi_rvalid,  /*Read channel valid*/ \
    output                    PREFIX``axi_rready   /*Read channel ready*/

`define AXI4_S_IF_PORT(PREFIX) \
    /*address write*/ \
    input [`AXI_ID_W-1:0]     PREFIX``axi_awid,    /*Address write channel ID*/ \
    input [AXI_ADDR_W-1:0]    PREFIX``axi_awaddr,  /*Address write channel address*/ \
    input [`AXI_LEN_W-1:0]    PREFIX``axi_awlen,   /*Address write channel burst length*/ \
    input [`AXI_SIZE_W-1:0]   PREFIX``axi_awsize,  /*Address write channel burst size. This signal indicates the size of each transfer in the burst*/ \
    input [`AXI_BURST_W-1:0]  PREFIX``axi_awburst, /*Address write channel burst type*/ \
    input [`AXI_LOCK_W-1:0]   PREFIX``axi_awlock,  /*Address write channel lock type*/ \
    input [`AXI_CACHE_W-1:0]  PREFIX``axi_awcache, /*Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).*/ \
    input [`AXI_PROT_W-1:0]   PREFIX``axi_awprot,  /*Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    input [`AXI_QOS_W-1:0]    PREFIX``axi_awqos,   /*Address write channel quality of service*/ \
    input                     PREFIX``axi_awvalid, /*Address write channel valid*/ \
    output                    PREFIX``axi_awready, /*Address write channel ready*/ \
    /*write*/ \
    input [`AXI_ID_W-1:0]     PREFIX``axi_wid,     /*Write channel ID*/ \
    input [AXI_DATA_W-1:0]    PREFIX``axi_wdata,   /*Write channel data*/ \
    input [AXI_DATA_W/8-1:0]  PREFIX``axi_wstrb,   /*Write channel write strobe*/ \
    input                     PREFIX``axi_wlast,   /*Write channel last word flag*/ \
    input                     PREFIX``axi_wvalid,  /*Write channel valid*/ \
    output                    PREFIX``axi_wready,  /*Write channel ready*/ \
    /*write response*/ \
    output [`AXI_ID_W-1:0]    PREFIX``axi_bid,     /*Write response channel ID*/ \
    output [`AXI_RESP_W-1:0]  PREFIX``axi_bresp,   /*Write response channel response*/ \
    output                    PREFIX``axi_bvalid,  /*Write response channel valid*/ \
    input                     PREFIX``axi_bready,  /*Write response channel ready*/ \
    /*address read*/ \
    input [`AXI_ID_W-1:0]     PREFIX``axi_arid,    /*Address read channel ID*/ \
    input [AXI_ADDR_W-1:0]    PREFIX``axi_araddr,  /*Address read channel address*/ \
    input [`AXI_LEN_W-1:0]    PREFIX``axi_arlen,   /*Address read channel burst length*/ \
    input [`AXI_SIZE_W-1:0]   PREFIX``axi_arsize,  /*Address read channel burst size. This signal indicates the size of each transfer in the burst*/ \
    input [`AXI_BURST_W-1:0]  PREFIX``axi_arburst, /*Address read channel burst type*/ \
    input [`AXI_LOCK_W-1:0]   PREFIX``axi_arlock,  /*Address read channel lock type*/ \
    input [`AXI_CACHE_W-1:0]  PREFIX``axi_arcache, /*Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).*/ \
    input [`AXI_PROT_W-1:0]   PREFIX``axi_arprot,  /*Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    input [`AXI_QOS_W-1:0]    PREFIX``axi_arqos,   /*Address read channel quality of service*/ \
    input                     PREFIX``axi_arvalid, /*Address read channel valid*/ \
    output                    PREFIX``axi_arready, /*Address read channel ready*/ \
    /*read*/ \
    output [`AXI_ID_W-1:0]    PREFIX``axi_rid,     /*Read channel ID*/ \
    output [AXI_DATA_W-1:0]   PREFIX``axi_rdata,   /*Read channel data*/ \
    output [`AXI_RESP_W-1:0]  PREFIX``axi_rresp,   /*Read channel response*/ \
    output                    PREFIX``axi_rlast,   /*Read channel last word*/ \
    output                    PREFIX``axi_rvalid,  /*Read channel valid*/ \
    input                     PREFIX``axi_rready   /*Read channel ready*/

// Portmap

`define AXI4_IF_PORTMAP(PORT_PREFIX, WIRE_PREFIX) \
    /*address write*/ \
    .``PORT_PREFIX``axi_awid    (WIRE_PREFIX``axi_awid),    /*Address write channel ID*/ \
    .``PORT_PREFIX``axi_awaddr  (WIRE_PREFIX``axi_awaddr),  /*Address write channel address*/ \
    .``PORT_PREFIX``axi_awlen   (WIRE_PREFIX``axi_awlen),   /*Address write channel burst length*/ \
    .``PORT_PREFIX``axi_awsize  (WIRE_PREFIX``axi_awsize),  /*Address write channel burst size. This signal indicates the size of each transfer in the burst*/ \
    .``PORT_PREFIX``axi_awburst (WIRE_PREFIX``axi_awburst), /*Address write channel burst type*/ \
    .``PORT_PREFIX``axi_awlock  (WIRE_PREFIX``axi_awlock),  /*Address write channel lock type*/ \
    .``PORT_PREFIX``axi_awcache (WIRE_PREFIX``axi_awcache), /*Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).*/ \
    .``PORT_PREFIX``axi_awprot  (WIRE_PREFIX``axi_awprot),  /*Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    .``PORT_PREFIX``axi_awqos   (WIRE_PREFIX``axi_awqos),   /*Address write channel quality of service*/ \
    .``PORT_PREFIX``axi_awvalid (WIRE_PREFIX``axi_awvalid), /*Address write channel valid*/ \
    .``PORT_PREFIX``axi_awready (WIRE_PREFIX``axi_awready), /*Address write channel ready*/ \
    /*write*/ \
    .``PORT_PREFIX``axi_wid     (WIRE_PREFIX``axi_wid),     /*Write channel ID*/ \
    .``PORT_PREFIX``axi_wdata   (WIRE_PREFIX``axi_wdata),   /*Write channel data*/ \
    .``PORT_PREFIX``axi_wstrb   (WIRE_PREFIX``axi_wstrb),   /*Write channel write strobe*/ \
    .``PORT_PREFIX``axi_wlast   (WIRE_PREFIX``axi_wlast),   /*Write channel last word flag*/ \
    .``PORT_PREFIX``axi_wvalid  (WIRE_PREFIX``axi_wvalid),  /*Write channel valid*/ \
    .``PORT_PREFIX``axi_wready  (WIRE_PREFIX``axi_wready),  /*Write channel ready*/ \
    /*write response*/ \
    .``PORT_PREFIX``axi_bid     (WIRE_PREFIX``axi_bid),     /*Write response channel ID*/ \
    .``PORT_PREFIX``axi_bresp   (WIRE_PREFIX``axi_bresp),   /*Write response channel response*/ \
    .``PORT_PREFIX``axi_bvalid  (WIRE_PREFIX``axi_bvalid),  /*Write response channel valid*/ \
    .``PORT_PREFIX``axi_bready  (WIRE_PREFIX``axi_bready),  /*Write response channel ready*/ \
    /*address read*/ \
    .``PORT_PREFIX``axi_arid    (WIRE_PREFIX``axi_arid),    /*Address read channel ID*/ \
    .``PORT_PREFIX``axi_araddr  (WIRE_PREFIX``axi_araddr),  /*Address read channel address*/ \
    .``PORT_PREFIX``axi_arlen   (WIRE_PREFIX``axi_arlen),   /*Address read channel burst length*/ \
    .``PORT_PREFIX``axi_arsize  (WIRE_PREFIX``axi_arsize),  /*Address read channel burst size. This signal indicates the size of each transfer in the burst*/ \
    .``PORT_PREFIX``axi_arburst (WIRE_PREFIX``axi_arburst), /*Address read channel burst type*/ \
    .``PORT_PREFIX``axi_arlock  (WIRE_PREFIX``axi_arlock),  /*Address read channel lock type*/ \
    .``PORT_PREFIX``axi_arcache (WIRE_PREFIX``axi_arcache), /*Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).*/ \
    .``PORT_PREFIX``axi_arprot  (WIRE_PREFIX``axi_arprot),  /*Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    .``PORT_PREFIX``axi_arqos   (WIRE_PREFIX``axi_arqos),   /*Address read channel quality of service*/ \
    .``PORT_PREFIX``axi_arvalid (WIRE_PREFIX``axi_arvalid), /*Address read channel valid*/ \
    .``PORT_PREFIX``axi_arready (WIRE_PREFIX``axi_arready), /*Address read channel ready*/ \
    /*read*/ \
    .``PORT_PREFIX``axi_rid     (WIRE_PREFIX``axi_rid),     /*Read channel ID*/ \
    .``PORT_PREFIX``axi_rdata   (WIRE_PREFIX``axi_rdata),   /*Read channel data*/ \
    .``PORT_PREFIX``axi_rresp   (WIRE_PREFIX``axi_rresp),   /*Read channel response*/ \
    .``PORT_PREFIX``axi_rlast   (WIRE_PREFIX``axi_rlast),   /*Read channel last word*/ \
    .``PORT_PREFIX``axi_rvalid  (WIRE_PREFIX``axi_rvalid),  /*Read channel valid*/ \
    .``PORT_PREFIX``axi_rready  (WIRE_PREFIX``axi_rready)   /*Read channel ready*/

// Wire

`define AXI4_IF_WIRE(PREFIX) \
    /*address write*/ \
    wire [`AXI_ID_W-1:0]    PREFIX``axi_awid;    /*Address write channel ID*/ \
    wire [AXI_ADDR_W-1:0]   PREFIX``axi_awaddr;  /*Address write channel address*/ \
    wire [`AXI_LEN_W-1:0]   PREFIX``axi_awlen;   /*Address write channel burst length*/ \
    wire [`AXI_SIZE_W-1:0]  PREFIX``axi_awsize;  /*Address write channel burst size. This signal indicates the size of each transfer in the burst*/ \
    wire [`AXI_BURST_W-1:0] PREFIX``axi_awburst; /*Address write channel burst type*/ \
    wire [`AXI_LOCK_W-1:0]  PREFIX``axi_awlock;  /*Address write channel lock type*/ \
    wire [`AXI_CACHE_W-1:0] PREFIX``axi_awcache; /*Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).*/ \
    wire [`AXI_PROT_W-1:0]  PREFIX``axi_awprot;  /*Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    wire [`AXI_QOS_W-1:0]   PREFIX``axi_awqos;   /*Address write channel quality of service*/ \
    wire                    PREFIX``axi_awvalid; /*Address write channel valid*/ \
    wire                    PREFIX``axi_awready; /*Address write channel ready*/ \
    /*write*/ \
    wire [`AXI_ID_W-1:0]    PREFIX``axi_wid;     /*Write channel ID*/ \
    wire [AXI_DATA_W-1:0]   PREFIX``axi_wdata;   /*Write channel data*/ \
    wire [AXI_DATA_W/8-1:0] PREFIX``axi_wstrb;   /*Write channel write strobe*/ \
    wire                    PREFIX``axi_wlast;   /*Write channel last word flag*/ \
    wire                    PREFIX``axi_wvalid;  /*Write channel valid*/ \
    wire                    PREFIX``axi_wready;  /*Write channel ready*/ \
    /*write response*/ \
    wire [`AXI_ID_W-1:0]    PREFIX``axi_bid;     /*Write response channel ID*/ \
    wire [`AXI_RESP_W-1:0]  PREFIX``axi_bresp;   /*Write response channel response*/ \
    wire                    PREFIX``axi_bvalid;  /*Write response channel valid*/ \
    wire                    PREFIX``axi_bready;  /*Write response channel ready*/ \
    /*address read*/ \
    wire [`AXI_ID_W-1:0]    PREFIX``axi_arid;    /*Address read channel ID*/ \
    wire [AXI_ADDR_W-1:0]   PREFIX``axi_araddr;  /*Address read channel address*/ \
    wire [`AXI_LEN_W-1:0]   PREFIX``axi_arlen;   /*Address read channel burst length*/ \
    wire [`AXI_SIZE_W-1:0]  PREFIX``axi_arsize;  /*Address read channel burst size. This signal indicates the size of each transfer in the burst*/ \
    wire [`AXI_BURST_W-1:0] PREFIX``axi_arburst; /*Address read channel burst type*/ \
    wire [`AXI_LOCK_W-1:0]  PREFIX``axi_arlock;  /*Address read channel lock type*/ \
    wire [`AXI_CACHE_W-1:0] PREFIX``axi_arcache; /*Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).*/ \
    wire [`AXI_PROT_W-1:0]  PREFIX``axi_arprot;  /*Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    wire [`AXI_QOS_W-1:0]   PREFIX``axi_arqos;   /*Address read channel quality of service*/ \
    wire                    PREFIX``axi_arvalid; /*Address read channel valid*/ \
    wire                    PREFIX``axi_arready; /*Address read channel ready*/ \
    /*read*/ \
    wire [`AXI_ID_W-1:0]    PREFIX``axi_rid;     /*Read channel ID*/ \
    wire [AXI_DATA_W-1:0]   PREFIX``axi_rdata;   /*Read channel data*/ \
    wire [`AXI_RESP_W-1:0]  PREFIX``axi_rresp;   /*Read channel response*/ \
    wire                    PREFIX``axi_rlast;   /*Read channel last word*/ \
    wire                    PREFIX``axi_rvalid;  /*Read channel valid*/ \
    wire                    PREFIX``axi_rready   /*Read channel ready*/

//
// AXI-4 lite
//

// Port

`define AXI4_LITE_M_IF_PORT(PREFIX) \
    /*address write*/ \
    output [`AXI_ID_W-1:0]     PREFIX``axil_awid,    /*Address write channel ID*/ \
    output [AXIL_ADDR_W-1:0]   PREFIX``axil_awaddr,  /*Address write channel address*/ \
    output [`AXI_PROT_W-1:0]   PREFIX``axil_awprot,  /*Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    output [`AXI_QOS_W-1:0]    PREFIX``axil_awqos,   /*Address write channel quality of service*/ \
    output                     PREFIX``axil_awvalid, /*Address write channel valid*/ \
    input                      PREFIX``axil_awready, /*Address write channel ready*/ \
    /*write*/ \
    output [`AXI_ID_W-1:0]     PREFIX``axil_wid,     /*Write channel ID*/ \
    output [AXIL_DATA_W-1:0]   PREFIX``axil_wdata,   /*Write channel data*/ \
    output [AXIL_DATA_W/8-1:0] PREFIX``axil_wstrb,   /*Write channel write strobe*/ \
    output                     PREFIX``axil_wvalid,  /*Write channel valid*/ \
    input                      PREFIX``axil_wready,  /*Write channel ready*/ \
    /*write response*/ \
    input [`AXI_ID_W-1:0]      PREFIX``axil_bid,     /*Write response channel ID*/ \
    input [`AXI_RESP_W-1:0]    PREFIX``axil_bresp,   /*Write response channel response*/ \
    input                      PREFIX``axil_bvalid,  /*Write response channel valid*/ \
    output                     PREFIX``axil_bready,  /*Write response channel ready*/ \
    /*address read*/ \
    output [`AXI_ID_W-1:0]     PREFIX``axil_arid,    /*Address read channel ID*/ \
    output [AXIL_ADDR_W-1:0]   PREFIX``axil_araddr,  /*Address read channel address*/ \
    output [`AXI_PROT_W-1:0]   PREFIX``axil_arprot,  /*Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    output [`AXI_QOS_W-1:0]    PREFIX``axil_arqos,   /*Address read channel quality of service*/ \
    output                     PREFIX``axil_arvalid, /*Address read channel valid*/ \
    input                      PREFIX``axil_arready, /*Address read channel ready*/ \
    /*read*/ \
    input [`AXI_ID_W-1:0]      PREFIX``axil_rid,     /*Read channel ID*/ \
    input [AXIL_DATA_W-1:0]    PREFIX``axil_rdata,   /*Read channel data*/ \
    input [`AXI_RESP_W-1:0]    PREFIX``axil_rresp,   /*Read channel response*/ \
    input                      PREFIX``axil_rvalid,  /*Read channel valid*/ \
    output                     PREFIX``axil_rready   /*Read channel ready*/

`define AXI4_LITE_S_IF_PORT(PREFIX) \
    /*address write*/ \
    input [`AXI_ID_W-1:0]      PREFIX``axil_awid,    /*Address write channel ID*/ \
    input [AXIL_ADDR_W-1:0]    PREFIX``axil_awaddr,  /*Address write channel address*/ \
    input [`AXI_PROT_W-1:0]    PREFIX``axil_awprot,  /*Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    input [`AXI_QOS_W-1:0]     PREFIX``axil_awqos,   /*Address write channel quality of service*/ \
    input                      PREFIX``axil_awvalid, /*Address write channel valid*/ \
    output                     PREFIX``axil_awready, /*Address write channel ready*/ \
    /*write*/ \
    input [`AXI_ID_W-1:0]      PREFIX``axil_wid,     /*Write channel ID*/ \
    input [AXIL_DATA_W-1:0]    PREFIX``axil_wdata,   /*Write channel data*/ \
    input [AXIL_DATA_W/8-1:0]  PREFIX``axil_wstrb,   /*Write channel write strobe*/ \
    input                      PREFIX``axil_wvalid,  /*Write channel valid*/ \
    output                     PREFIX``axil_wready,  /*Write channel ready*/ \
    /*write response*/ \
    output [`AXI_ID_W-1:0]     PREFIX``axil_bid,     /*Write response channel ID*/ \
    output [`AXI_RESP_W-1:0]   PREFIX``axil_bresp,   /*Write response channel response*/ \
    output                     PREFIX``axil_bvalid,  /*Write response channel valid*/ \
    input                      PREFIX``axil_bready,  /*Write response channel ready*/ \
    /*address read*/ \
    input [`AXI_ID_W-1:0]      PREFIX``axil_arid,    /*Address read channel ID*/ \
    input [AXIL_ADDR_W-1:0]    PREFIX``axil_araddr,  /*Address read channel address*/ \
    input [`AXI_PROT_W-1:0]    PREFIX``axil_arprot,  /*Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    input [`AXI_QOS_W-1:0]     PREFIX``axil_arqos,   /*Address read channel quality of service*/ \
    input                      PREFIX``axil_arvalid, /*Address read channel valid*/ \
    output                     PREFIX``axil_arready, /*Address read channel ready*/ \
    /*read*/ \
    output [`AXI_ID_W-1:0]     PREFIX``axil_rid,     /*Read channel ID*/ \
    output [AXIL_DATA_W-1:0]   PREFIX``axil_rdata,   /*Read channel data*/ \
    output [`AXI_RESP_W-1:0]   PREFIX``axil_rresp,   /*Read channel response*/ \
    output                     PREFIX``axil_rvalid,  /*Read channel valid*/ \
    input                      PREFIX``axil_rready   /*Read channel ready*/

// Portmap

`define AXI4_LITE_IF_PORTMAP(PORT_PREFIX, WIRE_PREFIX) \
    /*address write*/ \
    .``PORT_PREFIX``axil_awid    (WIRE_PREFIX``axil_awid),    /*Address write channel ID*/ \
    .``PORT_PREFIX``axil_awaddr  (WIRE_PREFIX``axil_awaddr),  /*Address write channel address*/ \
    .``PORT_PREFIX``axil_awprot  (WIRE_PREFIX``axil_awprot),  /*Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    .``PORT_PREFIX``axil_awqos   (WIRE_PREFIX``axil_awqos),   /*Address write channel quality of service*/ \
    .``PORT_PREFIX``axil_awvalid (WIRE_PREFIX``axil_awvalid), /*Address write channel valid*/ \
    .``PORT_PREFIX``axil_awready (WIRE_PREFIX``axil_awready), /*Address write channel ready*/ \
    /*write*/ \
    .``PORT_PREFIX``axil_wid     (WIRE_PREFIX``axil_wid),     /*Write channel ID*/ \
    .``PORT_PREFIX``axil_wdata   (WIRE_PREFIX``axil_wdata),   /*Write channel data*/ \
    .``PORT_PREFIX``axil_wstrb   (WIRE_PREFIX``axil_wstrb),   /*Write channel write strobe*/ \
    .``PORT_PREFIX``axil_wvalid  (WIRE_PREFIX``axil_wvalid),  /*Write channel valid*/ \
    .``PORT_PREFIX``axil_wready  (WIRE_PREFIX``axil_wready),  /*Write channel ready*/ \
    /*write response*/ \
    .``PORT_PREFIX``axil_bid     (WIRE_PREFIX``axil_bid),     /*Write response channel ID*/ \
    .``PORT_PREFIX``axil_bresp   (WIRE_PREFIX``axil_bresp),   /*Write response channel response*/ \
    .``PORT_PREFIX``axil_bvalid  (WIRE_PREFIX``axil_bvalid),  /*Write response channel valid*/ \
    .``PORT_PREFIX``axil_bready  (WIRE_PREFIX``axil_bready),  /*Write response channel ready*/ \
    /*address read*/ \
    .``PORT_PREFIX``axil_arid    (WIRE_PREFIX``axil_arid),    /*Address read channel ID*/ \
    .``PORT_PREFIX``axil_araddr  (WIRE_PREFIX``axil_araddr),  /*Address read channel address*/ \
    .``PORT_PREFIX``axil_arprot  (WIRE_PREFIX``axil_arprot),  /*Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    .``PORT_PREFIX``axil_arqos   (WIRE_PREFIX``axil_arqos),   /*Address read channel quality of service*/ \
    .``PORT_PREFIX``axil_arvalid (WIRE_PREFIX``axil_arvalid), /*Address read channel valid*/ \
    .``PORT_PREFIX``axil_arready (WIRE_PREFIX``axil_arready), /*Address read channel ready*/ \
    /*read*/ \
    .``PORT_PREFIX``axil_rid     (WIRE_PREFIX``axil_rid),     /*Read channel ID*/ \
    .``PORT_PREFIX``axil_rdata   (WIRE_PREFIX``axil_rdata),   /*Read channel data*/ \
    .``PORT_PREFIX``axil_rresp   (WIRE_PREFIX``axil_rresp),   /*Read channel response*/ \
    .``PORT_PREFIX``axil_rvalid  (WIRE_PREFIX``axil_rvalid),  /*Read channel valid*/ \
    .``PORT_PREFIX``axil_rready  (WIRE_PREFIX``axil_rready)   /*Read channel ready*/

// Wire

`define AXI4_LITE_IF_WIRE(PREFIX) \
    /*address write*/ \
    wire [`AXI_ID_W-1:0]     PREFIX``axil_awid;    /*Address write channel ID*/ \
    wire [AXIL_ADDR_W-1:0]   PREFIX``axil_awaddr;  /*Address write channel address*/ \
    wire [`AXI_PROT_W-1:0]   PREFIX``axil_awprot;  /*Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    wire [`AXI_QOS_W-1:0]    PREFIX``axil_awqos;   /*Address write channel quality of service*/ \
    wire                     PREFIX``axil_awvalid; /*Address write channel valid*/ \
    wire                     PREFIX``axil_awready; /*Address write channel ready*/ \
    /*write*/ \
    wire [`AXI_ID_W-1:0]     PREFIX``axil_wid;     /*Write channel ID*/ \
    wire [AXIL_DATA_W-1:0]   PREFIX``axil_wdata;   /*Write channel data*/ \
    wire [AXIL_DATA_W/8-1:0] PREFIX``axil_wstrb;   /*Write channel write strobe*/ \
    wire                     PREFIX``axil_wvalid;  /*Write channel valid*/ \
    wire                     PREFIX``axil_wready;  /*Write channel ready*/ \
    /*write response*/ \
    wire [`AXI_ID_W-1:0]     PREFIX``axil_bid;     /*Write response channel ID*/ \
    wire [`AXI_RESP_W-1:0]   PREFIX``axil_bresp;   /*Write response channel response*/ \
    wire                     PREFIX``axil_bvalid;  /*Write response channel valid*/ \
    wire                     PREFIX``axil_bready;  /*Write response channel ready*/ \
    /*address read*/ \
    wire [`AXI_ID_W-1:0]     PREFIX``axil_arid;    /*Address read channel ID*/ \
    wire [AXIL_ADDR_W-1:0]   PREFIX``axil_araddr;  /*Address read channel address*/ \
    wire [`AXI_PROT_W-1:0]   PREFIX``axil_arprot;  /*Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).*/ \
    wire [`AXI_QOS_W-1:0]    PREFIX``axil_arqos;   /*Address read channel quality of service*/ \
    wire                     PREFIX``axil_arvalid; /*Address read channel valid*/ \
    wire                     PREFIX``axil_arready; /*Address read channel ready*/ \
    /*read*/ \
    wire [`AXI_ID_W-1:0]     PREFIX``axil_rid;     /*Read channel ID*/ \
    wire [AXIL_DATA_W-1:0]   PREFIX``axil_rdata;   /*Read channel data*/ \
    wire [`AXI_RESP_W-1:0]   PREFIX``axil_rresp;   /*Read channel response*/ \
    wire                     PREFIX``axil_rvalid;  /*Read channel valid*/ \
    wire                     PREFIX``axil_rready   /*Read channel ready*/
