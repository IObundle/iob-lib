`ifndef LIBINC
`define LIBINC

// COMMON UTILS
`define max(a,b) {(a) > (b) ? (a) : (b)}
`define min(a,b) {(a) < (b) ? (a) : (b)}

//IO
`define INPUT(NAME, WIDTH) input [WIDTH-1:0] NAME
`define INPUT_SIGNED(NAME, WIDTH) input signed [WIDTH-1:0] NAME
`define OUTPUT(NAME, WIDTH) output [WIDTH-1:0] NAME
`define INOUT(NAME, WIDTH) inout [WIDTH-1:0] NAME

//WIRES AND VARIABLES
`define WIRE(NAME, WIDTH) wire [WIDTH-1:0] NAME;
`define WIRE_INIT(NAME, WIDTH, INIT) wire [WIDTH-1:0] NAME = INIT;
`define WIRE_SIGNED(NAME, WIDTH) wire signed [WIDTH-1:0] NAME;
`define VAR(NAME, WIDTH) reg [WIDTH-1:0] NAME;
`define VAR_INIT(NAME, WIDTH, INIT) reg [WIDTH-1:0] NAME = INIT;
`define VAR_SIGNED(NAME, WIDTH) reg signed [WIDTH-1:0] NAME;
`define WIRE2WIRE(IN, OUT) assign OUT = IN;//assign WIRE to WIRE
`define VAR2WIRE(IN, OUT) assign OUT = IN;//convert VAR to WIRE
`define WIRE2VAR(IN, OUT) `COMB OUT = IN;//convert WIRE to VAR

//2d arrays
`define WIREARRAY_2D(NAME, LEN, WIDTH) wire [WIDTH-1:0] NAME [LEN-1:0];
`define WIREARRAY_2D_SIGNED(NAME, LEN, WIDTH) wire signed [WIDTH-1:0] NAME [LEN-1:0];
`define VARARRAY_2D(NAME, LEN, WIDTH) reg [WIDTH-1:0] NAME [LEN-1:0];
`define VARARRAY_2D_SIGNED(NAME, LEN, WIDTH) reg signed [WIDTH-1:0] NAME [LEN-1:0];


//REGISTER
`define REG(CLK, OUT, IN) always @(posedge CLK) OUT <= IN;
`define REG_E(CLK, EN, OUT, IN) always @(posedge CLK) if(EN) OUT <= IN;
`define REG_R(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else OUT <= IN;
`define REG_RE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else if (EN) OUT <= IN;
`define REG_AR(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; else OUT <= IN;
`define REG_ARE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; else if (EN) OUT <= IN;
`define REG_ARR(CLK, ARST, ARST_VAL, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK, posedge ARST) if (ARST) OUT <= ARST_VAL; \
        else if (RST) OUT <= RST_VAL; else OUT <= IN;
`define REG_ARRE(CLK, ARST, ARST_VAL, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK, posedge ARST) if (ARST) OUT <= ARST_VAL; \
        else if (RST) OUT <= RST_VAL; else if (EN) OUT <= IN;

//SHIFT REGISTER

//shift left
`define SL_REG(CLK, OUT, IN) always @(posedge CLK) OUT <= (OUT << 1) | IN;
`define SL_REG_E(CLK, EN, OUT, IN) always @(posedge CLK) if (EN) OUT <= (OUT << 1) | IN;
`define SL_REG_R(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else OUT <= (OUT << 1) | IN;
`define SL_REG_RE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else if(EN) OUT <= (OUT << 1) | IN;
`define SL_REG_AR(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; \
   else OUT <= (OUT << 1) | IN;
`define SL_REG_ARE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; \
   else if(EN) OUT <= (OUT << 1) | IN;

//shift right
`define SR_REG(CLK, OUT, IN) always @(posedge CLK) OUT <= (OUT >> 1) | IN;
`define SR_REG_E(CLK, EN, OUT, IN) always @(posedge CLK) if (EN) OUT <= (OUT >> 1) | IN;
`define SR_REG_R(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else OUT <= (OUT >> 1) | IN;
`define SR_REG_RE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else if(EN) OUT <= (OUT >> 1) | IN;
`define SR_REG_AR(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; \
   else OUT <= (OUT >> 1) | IN;
`define SR_REG_ARE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; \
   else if(EN) OUT <= (OUT >> 1) | IN;

//parallel in and serial-out shift reg
//shift left
`define PISLO_REG(CLK, LD, OUT, IN) always @(posedge CLK) if(LD) OUT <= IN; else OUT <= (OUT << 1);
`define PISLO_REG_E(CLK, LD, EN, OUT, IN) always @(posedge CLK) if(LD) OUT <= IN; else if (EN) OUT <= (OUT << 1);
//shift right
`define PISRO_REG(CLK, LD, OUT, IN) always @(posedge CLK) if(LD) OUT <= IN; else OUT <= (OUT >> 1);
`define PISRO_REG_E(CLK, LD, EN, OUT, IN) always @(posedge CLK) if(LD) OUT <= IN; else if (EN) OUT <= (OUT >> 1);

//REVERSER -- NOT TESTED
`define REVERSE(A, B, W) \
   reg [W-1:0] B;\
   always @* begin\
      integer rev_i;\
      for(ref_i = 0; rev_i < W; rev_i = rev_i + 1)\
        B[i] = A[W-1-i];\
   end
   
//ACCUMULATOR
`define ACC_R(CLK, RST, RST_VAL, NAME, INCR) \
   `REG_R(CLK, RST, RST_VAL, NAME, NAME+INCR)
`define ACC_RE(CLK, RST, RST_VAL, EN, NAME, INCR) \
   `REG_RE(CLK, RST, RST_VAL, EN, NAME, NAME+INCR)
`define ACC_AR(CLK, RST, RST_VAL, NAME, INCR) \
   `REG_AR(CLK, RST, RST_VAL, NAME, NAME+INCR)
`define ACC_ARE(CLK, RST, RST_VAL, EN, NAME, INCR) \
   `REG_ARE(CLK, RST, RST_VAL, EN, NAME, NAME+INCR)

//COUNTER
`define COUNTER_R(CLK, RST, NAME) \
   `REG_R(CLK, RST, 1'b0, NAME, NAME+1'b1)
`define COUNTER_RE(CLK, RST, EN, NAME) \
   `REG_RE(CLK, RST, 1'b0, EN, NAME, NAME+1'b1)
`define COUNTER_AR(CLK, RST, NAME) \
   `REG_AR(CLK, RST, 1'b0, NAME, NAME+1'b1)
`define COUNTER_ARE(CLK, RST, EN, NAME) \
   `REG_ARE(CLK, RST, 1'b0, EN, NAME, NAME+1'b1)

//CIRCULAR COUNTER
`define MODCNT_R(CLK, RST, NAME, MOD) \
   `REG_R(CLK, RST, 1'b0, NAME, (NAME==(MOD-1)? 1'b0: NAME+1'b1))
`define MODCNT_RE(CLK, RST, EN, NAME, MOD) \
   `REG_RE(CLK, RST, 1'b0, EN, NAME, (NAME==(MOD-1)? 1'b0: NAME+1'b1))
`define MODCNT_AR(CLK, RST, NAME, MOD) \
   `REG_AR(CLK, RST, 1'b0, NAME, (NAME==(MOD-1)? 1'b0: NAME+1'b1))
`define MODCNT_ARE(CLK, RST, EN, NAME, MOD) \
   `REG_ARE(CLK, RST, 1'b0, EN, NAME, (NAME==(MOD-1)? 1'b0: NAME+1'b1))

//SOFTWARE ACCESSIBLE REGISTER
`define SWREG_R(NAME, WIDTH, RST_VAL) wire [WIDTH-1:0] NAME; //RST_VAL is used in mkregs.py
`define SWREG_W(NAME, WIDTH, RST_VAL) reg [WIDTH-1:0] NAME; //RST_VAL is used in mkregs.py

//COMBINATORIAL CIRCUIT
`define COMB always @*


//MUX
`define MUX(SEL, OUT, IN) `COMB OUT = IN[SEL];


   // SYNCRONIZERS
   // reset sync
`define RESET_SYNC(CLK, RST_IN, SYNC_REG, RST_OUT) \
   reg [1:0] SYNC_REG; \
   always @(posedge CLK, posedge RST_IN) \
   if(RST_IN)  SYNC_REG <= 2'b11; else SYNC_REG <= {SYNC_REG[0], 1'b0}; \
   assign RST_OUT = SYNC_REG[1];

   //regular 2-flop sync
`define SYNC(CLK, RST, RST_VAL, W, IN, SYNC_REG0, SYNC_REG1, OUT) \
   reg [W-1:0] SYNC_REG0, SYNC_REG1; \
   always @(posedge CLK, posedge RST) \
   if(RST) begin \
      SYNC_REG0 <= RST_VAL; \
      SYNC_REG1 <= RST_VAL; \
   end else begin \
      SYNC_REG0 <= IN; \
      SYNC_REG1 <= SYNC_REG0; \
   end \
   assign OUT = SYNC_REG1;
   

   //fast domain to slow domain
`define F2S_SYNC(CLK, IN, IN_SYNC, OUT) \
    `RESET_SYNC(CLK, IN, IN_SYNC, OUT)

   //slow domain to fast domain
`define S2F_SYNC(CLK, RST, RST_VAL, W, IN, IN_SYNC, OUT) \
   `SYNC(CLK, RST, RST_VAL, W, IN, IN_SYNC, OUT)


`define POSEDGE_DETECT(CLK, RST, IN, IN_REG, OUT) \
   reg IN_REG; \
   always @(posedge CLK, posedge RST) \
     if(RST) \
       IN_REG <= 1'b1; \
     else \
       IN_REG <= IN; \
   wire OUT = IN & ~IN_REG;

`define NEGEDGE_DETECT(CLK, RST, IN, IN_REG, OUT) \
   reg IN_REG; \
   always @(posedge CLK, posedge RST) \
     if(RST) \
       IN_REG <= 1'b1; \
     else \
       IN_REG <= IN; \
   wire OUT = ~IN & IN_REG;

//One Detected
`define PULSE_DETECT(CLK, RST, IN, OUT) \
   reg OUT; \
   always @(posedge CLK, posedge RST) \
     if(RST) \
       OUT <= 1'b0; \
     else if (IN)\
       OUT <= 1'b1;



//
// COMMON TESTBENCH UTILS
//

//CLOCK GENERATOR
`define CLOCK(CLK, PER) reg CLK=1; always #(PER/2) CLK = ~CLK;


//RESET GENERATOR
`define RESET(RST, RISE_TIME, DURATION) reg RST=0; \
initial begin #RISE_TIME RST=1; #DURATION RST=0; end


//DIFFERENTIATOR
`define DIFF(CLK, RST, EN, D, X, X_REG) \
   `REG_ARE(CLK, RST, 1'b0, EN, X_REG, X) \
   `COMB D = X - X_REG;
   
`endif //  `ifndef LIBINC
           
   
