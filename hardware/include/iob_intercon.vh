//
// BUS INTERCONNECT MACROS
//

//DATA WIDTHS
`define VALID_W     1
`define WSTRB_W_(D) D/8
`define READY_W     1

`define WRITE_W_(D) (D+`WSTRB_W_(D))
`define READ_W_(D)  (D+`READY_W)

//DATA POSITIONS
//req bus 
`define WDATA_P_(D)   `WSTRB_W_(D)
`define ADDR_P_(D)    (`WDATA_P_(D)+D)
`define VALID_P_(A,D) (`ADDR_P_(D)+A)
//resp bus
`define RDATA_P `READY_W

              
//CONCAT BUS WIDTHS
//request part
`define REQ_W_(A,D) (`VALID_W+A+`WRITE_W_(D))
//response part
`define RESP_W_(D)  (`READ_W_(D))


/////////////////////////////////////////////////////////////////////////////////
//FIELD RANGES

//gets request section of cat bus
`define req_(I,A,D) I*`REQ_W_(A,D) +: `REQ_W_(A,D)

//gets the response part of a cat bus section
`define resp_(I,D) I*`RESP_W_(D) +: `RESP_W_(D)

//gets the valid bit of cat bus section 
`define valid_(I,A,D) I*`REQ_W_(A,D) + `VALID_P_(A,D)

//gets the address of cat bus section
`define address_(I,W,A,D) I*`REQ_W_(A,D)+`ADDR_P_(D)+W-1 -: W

//gets the wdata field of cat bus
`define wdata_(I,A,D) I*`REQ_W_(A,D)+`WDATA_P_(D) +: D

//gets the wstrb field of cat bus
`define wstrb_(I,A,D) I*`REQ_W_(A,D) +: `WSTRB_W_(D)

//gets the write fields of cat bus
`define write_(I,A,D) I*`REQ_W_(A,D) +: `WRITE_W_(D)

//gets the rdata field of cat bus
`define rdata_(I,D) I*`RESP_W_(D)+`RDATA_P +: D

//gets the ready field of cat bus
`define ready_(I,D) I*`RESP_W_(D)


/////////////////////////////////////////////////////////////////////////////////
//defaults

`define WSTRB_W `WSTRB_W_(DATA_W)

`define WRITE_W `WRITE_W_(DATA_W)
`define READ_W  `READ_W_(DATA_W)

`define WDATA_P `WDATA_P_(DATA_W)
`define ADDR_P  `ADDR_P_(DATA_W)
`define VALID_P `VALID_P_(ADDR_W, DATA_W)

`define REQ_W  `REQ_W_(ADDR_W, DATA_W)
`define RESP_W `RESP_W_(DATA_W)

`define req(I)       `req_(I, ADDR_W, DATA_W)
`define resp(I)      `resp_(I, DATA_W)
`define valid(I)     `valid_(I, ADDR_W, DATA_W)
`define address(I,W) `address_(I, W, ADDR_W, DATA_W)
`define wdata(I)     `wdata_(I, ADDR_W, DATA_W)
`define wstrb(I)     `wstrb_(I, ADDR_W, DATA_W)
`define write(I)     `write_(I, ADDR_W, DATA_W)
`define rdata(I)     `rdata_(I, DATA_W)
`define ready(I)     `ready_(I, DATA_W)
