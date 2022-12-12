  //START_IO_TABLE iob_m_port
output [1-1:0] iob_avalid_o, //Request valid.
output [ADDR_W-1:0] iob_addr_o, //Address.
output [DATA_W-1:0] iob_wdata_o, //Write data.
output [(DATA_W/8)-1:0] iob_wstrb_o, //Write strobe.
input [1-1:0] iob_rvalid_nxt_i, //Read data valid.
input [DATA_W-1:0] iob_rdata_i, //Read data.
input [1-1:0] iob_ready_nxt_i, //Interface ready.
