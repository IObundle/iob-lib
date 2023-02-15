`ifndef LIBINC
`define LIBINC

//
//COMMON UTILS
//

`define IOB_MAX(a,b) (((a) > (b)) ? (a) : (b))
`define IOB_MIN(a,b) (((a) < (b)) ? (a) : (b))
`define IOB_ABS(a, w) {a[w-1]? (-a): (a)}
`define IOB_MUX2(SEL, OUT, IN1, IN2) assign OUT = SEL==1'b0? IN1 : IN2;
`define IOB_COMB always @*
`define IOB_MUX(SEL, IN, OUT) assign OUT = IN[SEL];
`define IOB_DEMUX(SEL, IN, OUT) assign OUT = IN << SEL;

//IO
`define IOB_INPUT(NAME, WIDTH) input [WIDTH-1:0] NAME
`define IOB_INPUT_SIGNED(NAME, WIDTH) input signed [WIDTH-1:0] NAME
`define IOB_OUTPUT(NAME, WIDTH) output [WIDTH-1:0] NAME
`define IOB_OUTPUT_VAR(NAME, WIDTH) output reg [WIDTH-1:0] NAME
`define IOB_INOUT(NAME, WIDTH) inout [WIDTH-1:0] NAME

//WIRES AND VARIABLES
`define IOB_WIRE(NAME, WIDTH) wire [WIDTH-1:0] NAME;
`define IOB_WIRE_SIGNED(NAME, WIDTH) wire signed [WIDTH-1:0] NAME;
`define IOB_VAR(NAME, WIDTH) reg [WIDTH-1:0] NAME;
`define IOB_VAR_SIGNED(NAME, WIDTH) reg signed [WIDTH-1:0] NAME;
`define IOB_VAR2WIRE(IN, OUT) assign OUT = IN;//convert IOB_VAR to IOB_WIRE
//2d arrays
`define IOB_WIREARRAY_2D(NAME, LEN, WIDTH) wire [WIDTH-1:0] NAME [LEN-1:0];
`define IOB_WIREARRAY_2D_SIGNED(NAME, LEN, WIDTH) wire signed [WIDTH-1:0] NAME [LEN-1:0];
`define IOB_VARARRAY_2D(NAME, LEN, WIDTH) reg [WIDTH-1:0] NAME [LEN-1:0];
`define IOB_VARARRAY_2D_SIGNED(NAME, LEN, WIDTH) reg signed [WIDTH-1:0] NAME [LEN-1:0];

//ADDRESSES
`define IOB_NBYTES (DATA_W/8)
`define IOB_NBYTES_W $clog2(`IOB_NBYTES)
`define IOB_BYTE_OFFSET(ADDR) (ADDR%(DATA_W/8))
`define IOB_WORD_ADDR(ADDR) ((ADDR>>`IOB_NBYTES_W)<<`IOB_NBYTES_W)
`define IOB_GET_NBYTES(WIDTH) (WIDTH/8 + |(WIDTH%8))
`define IOB_GET_WDATA(ADDR, DATA) (DATA<<(8*`IOB_BYTE_OFFSET(ADDR)))
`define IOB_GET_WSTRB(ADDR, WIDTH) (((1<<`IOB_GET_NBYTES(WIDTH))-1)<<`IOB_BYTE_OFFSET(ADDR))
`define IOB_GET_RDATA(ADDR, DATA, WIDTH) ((DATA>>(8*`IOB_BYTE_OFFSET(ADDR)))&((1<<WIDTH)-1))


//
// COMMON TESTBENCH UTILS
//

//declare and init var
`define IOB_VAR_INIT(NAME, WIDTH, VAL) reg [WIDTH-1:0] NAME = VAL;

//CLOCK GENERATOR
`define IOB_CLOCK(CLK, PER) reg CLK=1; always #(PER/2) CLK = ~CLK;

//PULSE 
`define IOB_PULSE(VAR, PRE, DURATION, POST) #PRE VAR=1; #DURATION VAR=0; #POST;
   
//RESET SYNCHRONIZER
`define IOB_RESET_SYNC(CLK, RST_IN, RST_OUT) \
   always @(posedge CLK, posedge RST_IN) \
   if(RST_IN) RST_OUT = 1; else RST_OUT = #1 RST_IN;


//
// BUS INTERCONNECT MACROS
//

//DATA WIDTHS
`define VALID_W     1
`define WSTRB_W_(D) D/8
`define READY_W     1

`define WRITE_W_(D) (D+`WSTRB_W_(D))
`define READ_W_(D)  (D)

//DATA POSITIONS
//REQ bus
`define WDATA_P_(D)    `WSTRB_W_(D)
`define ADDR_P_(D)     (`WDATA_P_(D)+D)
`define AVALID_P_(A,D) (`ADDR_P_(D)+A)
//RESP bus
`define RDATA_P `VALID_W+`READY_W


//CONCAT BUS WIDTHS
//request part
`define REQ_W_(A,D) (`VALID_W+A+`WRITE_W_(D))
//response part
`define RESP_W_(D)  (`READ_W_(D)+`VALID_W+`READY_W)


/////////////////////////////////////////////////////////////////////////////////
//FIELD RANGES

//gets request section of cat bus
`define REQ_(I,A,D) I*`REQ_W_(A,D) +: `REQ_W_(A,D)

//gets the response part of a cat bus section
`define RESP_(I,D) I*`RESP_W_(D) +: `RESP_W_(D)

//gets the WRITE valid bit of cat bus section
`define AVALID_(I,A,D) I*`REQ_W_(A,D) + `AVALID_P_(A,D)

//gets the ADDRESS of cat bus section
`define ADDRESS_(I,W,A,D) I*`REQ_W_(A,D)+`ADDR_P_(D)+W-1 -: W

//gets the WDATA field of cat bus
`define WDATA_(I,A,D) I*`REQ_W_(A,D)+`WDATA_P_(D) +: D

//gets the WSTRB field of cat bus
`define WSTRB_(I,A,D) I*`REQ_W_(A,D) +: `WSTRB_W_(D)

//gets the WRITE fields of cat bus
`define WRITE_(I,A,D) I*`REQ_W_(A,D) +: `WRITE_W_(D)

//gets the RDATA field of cat bus
`define RDATA_(I,D) I*`RESP_W_(D)+`RDATA_P +: D

//gets the read valid field of cat bus
`define RVALID_(I,D) I*`RESP_W_(D)+`READY_W

//gets the READY field of cat bus
`define READY_(I,D) I*`RESP_W_(D)


/////////////////////////////////////////////////////////////////////////////////
//defaults

`define WSTRB_W  `WSTRB_W_(DATA_W)

`define WRITE_W  `WRITE_W_(DATA_W)
`define READ_W   `READ_W_(DATA_W)

`define WDATA_P  `WDATA_P_(DATA_W)
`define ADDR_P   `ADDR_P_(DATA_W)
`define AVALID_P `AVALID_P_(ADDR_W, DATA_W)

`define REQ_W    `REQ_W_(ADDR_W, DATA_W)
`define RESP_W   `RESP_W_(DATA_W)

`define REQ(I)       `REQ_(I, ADDR_W, DATA_W)
`define RESP(I)      `RESP_(I, DATA_W)
`define AVALID(I)    `AVALID_(I, ADDR_W, DATA_W)
`define ADDRESS(I,W) `ADDRESS_(I, W, ADDR_W, DATA_W)
`define WDATA(I)     `WDATA_(I, ADDR_W, DATA_W)
`define WSTRB(I)     `WSTRB_(I, ADDR_W, DATA_W)
`define WRITE(I)     `WRITE_(I, ADDR_W, DATA_W)
`define RDATA(I)     `RDATA_(I, DATA_W)
`define RVALID(I)    `RVALID_(I, DATA_W)
`define READY(I)     `READY_(I, DATA_W)

`endif //  `ifndef LIBINC
           
   
   
