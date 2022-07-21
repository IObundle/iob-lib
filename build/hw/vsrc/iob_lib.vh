`ifndef LIBINC
`define LIBINC

//COMMON UTILS
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
`define IOB_WIRE_INIT(NAME, WIDTH, INIT) wire [WIDTH-1:0] NAME = INIT;
`define IOB_WIRE_SIGNED(NAME, WIDTH) wire signed [WIDTH-1:0] NAME;
`define IOB_VAR(NAME, WIDTH) reg [WIDTH-1:0] NAME;
`define IOB_VAR_INIT(NAME, WIDTH, INIT) reg [WIDTH-1:0] NAME = INIT;
`define IOB_VAR_SIGNED(NAME, WIDTH) reg signed [WIDTH-1:0] NAME;
`define IOB_WIRE2WIRE(IN, OUT) assign OUT = IN;//assign IOB_WIRE to IOB_WIRE
`define IOB_VAR2WIRE(IN, OUT) assign OUT = IN;//convert IOB_VAR to IOB_WIRE
`define IOB_WIRE2VAR(IN, OUT) `IOB_COMB OUT = IN;//convert IOB_WIRE to IOB_VAR
//2d arrays
`define IOB_WIREARRAY_2D(NAME, LEN, WIDTH) wire [WIDTH-1:0] NAME [LEN-1:0];
`define IOB_WIREARRAY_2D_SIGNED(NAME, LEN, WIDTH) wire signed [WIDTH-1:0] NAME [LEN-1:0];
`define IOB_VARARRAY_2D(NAME, LEN, WIDTH) reg [WIDTH-1:0] NAME [LEN-1:0];
`define IOB_VARARRAY_2D_SIGNED(NAME, LEN, WIDTH) reg signed [WIDTH-1:0] NAME [LEN-1:0];


//IOB_REGISTER
`define IOB_REG(CLK, OUT, IN) always @(posedge CLK) OUT <= IN;
`define IOB_REG_E(CLK, EN, OUT, IN) always @(posedge CLK) if(EN) OUT <= IN;
`define IOB_REG_R(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else OUT <= IN;
`define IOB_REG_RE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else if (EN) OUT <= IN;
`define IOB_REG_AR(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; else OUT <= IN;
`define IOB_REG_ARE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; else if (EN) OUT <= IN;
`define IOB_REG_ARR(CLK, ARST, ARST_VAL, RST, RST_VAL, OUT, IN) always @(posedge CLK, posedge ARST) if (ARST) OUT <= ARST_VAL; \
        else if (RST) OUT <= RST_VAL; else OUT <= IN;
`define IOB_REG_ARRE(CLK, ARST, ARST_VAL, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK, posedge ARST) if (ARST) OUT <= ARST_VAL; \
        else if (RST) OUT <= RST_VAL; else if (EN) OUT <= IN;

//IOB_REVERSER -- NOT TESTED
`define IOB_REVERSE(A, B, W) \
   reg [W-1:0] B;\
   always @* begin\
      integer rev_i;\
      for(rev_i = 0; rev_i < W; rev_i = rev_i + 1)\
        B[i] = A[W-1-i];\
   end
   
//IOB_ACCUMULATOR
`define IOB_ACC_R(CLK, RST, RST_VAL, NAME, INCR) \
   `IOB_REG_R(CLK, RST, RST_VAL, NAME, NAME+INCR)
`define IOB_ACC_RE(CLK, RST, RST_VAL, EN, NAME, INCR) \
   `IOB_REG_RE(CLK, RST, RST_VAL, EN, NAME, NAME+INCR)
`define IOB_ACC_AR(CLK, RST, RST_VAL, NAME, INCR) \
   `IOB_REG_AR(CLK, RST, RST_VAL, NAME, NAME+INCR)
`define IOB_ACC_ARE(CLK, RST, RST_VAL, EN, NAME, INCR) \
   `IOB_REG_ARE(CLK, RST, RST_VAL, EN, NAME, NAME+INCR)

//IOB_COUNTER
`define IOB_COUNTER_R(CLK, RST, NAME) \
   `IOB_REG_R(CLK, RST, 1'b0, NAME, NAME+1'b1)
`define IOB_COUNTER_RE(CLK, RST, EN, NAME) \
   `IOB_REG_RE(CLK, RST, 1'b0, EN, NAME, NAME+1'b1)
`define IOB_COUNTER_AR(CLK, RST, NAME) \
   `IOB_REG_AR(CLK, RST, 1'b0, NAME, NAME+1'b1)
`define IOB_COUNTER_ARE(CLK, RST, EN, NAME) \
   `IOB_REG_ARE(CLK, RST, 1'b0, EN, NAME, NAME+1'b1)
`define IOB_COUNTER_ARR(CLK, ARST, RST, NAME) \
   `IOB_REG_ARR(CLK, ARST, 1'b0, RST, 1'b0, NAME, NAME+1'b1)
`define IOB_COUNTER_ARRE(CLK, ARST, RST, EN, NAME) \
   `IOB_REG_ARRE(CLK, ARST, 1'b0, RST, 1'b0, EN, NAME, NAME+1'b1)

//MODULO IOB_COUNTER
`define IOB_MODCNT_R(CLK, RST, RST_VAL, NAME, MOD) \
   `IOB_REG_R(CLK, RST, RST_VAL, NAME, (NAME==(MOD-1)? 1'b0: NAME+1'b1))
`define IOB_MODCNT_RE(CLK, RST, RST_VAL, EN, NAME, MOD) \
   `IOB_REG_RE(CLK, RST, RST_VAL, EN, NAME, (NAME==(MOD-1)? 1'b0: NAME+1'b1))
`define IOB_MODCNT_AR(CLK, RST, RST_VAL, NAME, MOD) \
   `IOB_REG_AR(CLK, RST, RST_VAL, NAME, (NAME==(MOD-1)? 1'b0: NAME+1'b1))
`define IOB_MODCNT_ARE(CLK, RST, RST_VAL, EN, NAME, MOD) \
   `IOB_REG_ARE(CLK, RST, RST_VAL, EN, NAME, (NAME==(MOD-1)? 1'b0: NAME+1'b1))


   // IOB_SYNCRONIZERS
   // reset iob_sync
`define IOB_RESET_SYNC(CLK, RST_IN, IOB_SYNC_REG, RST_OUT) \
   reg [1:0] IOB_SYNC_REG; \
   always @(posedge CLK, posedge RST_IN) \
   if(RST_IN)  IOB_SYNC_REG <= 2'b11; else IOB_SYNC_REG <= {IOB_SYNC_REG[0], 1'b0}; \
   assign RST_OUT = IOB_SYNC_REG[1];

   //regular 2-flop iob_sync
`define IOB_SYNC(CLK, RST, RST_VAL, W, IN, IOB_SYNC_REG0, IOB_SYNC_REG1, OUT) \
   reg [W-1:0] IOB_SYNC_REG0, IOB_SYNC_REG1; \
   always @(posedge CLK, posedge RST) \
   if(RST) begin \
      IOB_SYNC_REG0 <= RST_VAL; \
      IOB_SYNC_REG1 <= RST_VAL; \
   end else begin \
      IOB_SYNC_REG0 <= IN; \
      IOB_SYNC_REG1 <= IOB_SYNC_REG0; \
   end \
   assign OUT = IOB_SYNC_REG1;
   

   //fast domain to slow domain
`define IOB_F2S_SYNC(CLK, IN, IOB_IN_SYNC, OUT) \
    `IOB_RESET_SYNC(CLK, IN, IOB_IN_SYNC, OUT)

   //slow domain to fast domain
`define IOB_S2F_SYNC(CLK, RST, RST_VAL, W, IN, IOB_IN_SYNC, OUT) \
   `IOB_SYNC(CLK, RST, RST_VAL, W, IN, IOB_IN_SYNC, OUT)


`define IOB_POSEDGE_DETECT(CLK, RST, IN, IOB_IN_REG, OUT) \
   reg IOB_IN_REG; \
   always @(posedge CLK, posedge RST) \
     if(RST) \
       IOB_IN_REG <= 1'b1; \
     else \
       IOB_IN_REG <= IN; \
   wire OUT = IN & ~IOB_IN_REG;

`define IOB_NEGEDGE_DETECT(CLK, RST, IN, IOB_IN_REG, OUT) \
   reg IOB_IN_REG; \
   always @(posedge CLK, posedge RST) \
     if(RST) \
       IOB_IN_REG <= 1'b1; \
     else \
       IOB_IN_REG <= IN; \
   wire OUT = ~IN & IOB_IN_REG;

//One Detected
`define IOB_PULSE_DETECT(CLK, RST, IN, OUT) \
   reg OUT; \
   always @(posedge CLK, posedge RST) \
     if(RST) \
       OUT <= 1'b0; \
     else if (IN)\
       OUT <= 1'b1;

//IOB_DIFFERENTIATOR
`define IOB_DIFF(CLK, RST, EN, D, X, X_IOB_REG) \
   `IOB_REG_ARE(CLK, RST, 1'b0, EN, X_IOB_REG, X) \
   `IOB_COMB D = X - X_IOB_REG;

//
// COMMON TESTBENCH UTILS
//

//IOB_CLOCK GENERATOR
`define IOB_CLOCK(CLK, PER) reg CLK=1; always #(PER/2) CLK = ~CLK;


//IOB_RESET GENERATOR
`define IOB_RESET(RST, RISE_TIME, DURATION) reg RST=0; \
initial begin #RISE_TIME RST=1; #DURATION RST=0; end


`endif //  `ifndef LIBINC
           
   
