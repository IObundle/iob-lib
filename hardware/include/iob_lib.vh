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
`define IOB_NBYTES DATA_W/8)
`define IOB_NBYTES_W $clog(`IOB_NBYTES)
`define IOB_BYTE_OFFSET(ADDR) (ADDR%(DATA_W/8))
`define IOB_WORD_ADDR(ADDR) ((ADDR>>`IOB_NBYTES_W)<<`IOB_NBYTES_W)
`define IOB_WORD_CADDR(ADDR) (((ADDR>>`IOB_NBYTES_W)+(`IOB_BYTE_OFFSET(ADDR)>0))>>`IOB_NBYTES_W)


   
//
// COMMON TESTBENCH UTILS
//

//IOB_CLOCK GENERATOR
`define IOB_CLOCK(CLK, PER) reg CLK=1; always #(PER/2) CLK = ~CLK;


//IOB_RESET GENERATOR
`define IOB_RESET(RST, RISE_TIME, DURATION) reg RST=0; \
initial begin #RISE_TIME RST=1; #DURATION RST=0; end


`endif //  `ifndef LIBINC
           
   
