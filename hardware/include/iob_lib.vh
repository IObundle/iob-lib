`ifndef LIBINC
`define LIBINC

//
//COMMON UTILS
//

`define IOB_MAX(a,b) {((a) > (b)) ? (a) : (b)}
`define IOB_MIN(a,b) {((a) < (b)) ? (a) : (b)}
`define IOB_ABS(a, w) {a[w-1]? (-a): (a)}
`define IOB_MUX2(SEL, OUT, IN1, IN2) assign OUT = SEL==1'b0? IN1 : IN2;
`define IOB_COMB always @*
`define IOB_MUX(SEL, OUT, IN) `IOB_COMB OUT = IN[SEL];

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
`define IOB_WORD_CADDR(ADDR) (((ADDR>>`IOB_NBYTES_W)+ |`IOB_BYTE_OFFSET(ADDR))<<`IOB_NBYTES_W)
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
`define IOB_PULSE(VAR, DURATION) VAR=1; #DURATION VAR=0;
   
//RESET SYNCHRONIZER
`define IOB_RESET_SYNC(CLK, RST_IN, RST_OUT) \
   always @(posedge CLK, posedge RST_IN) \
   if(RST_IN) RST_OUT = 1; else RST_OUT = #1 RST_IN;
   

`endif //  `ifndef LIBINC
           
   
   
