//IO
`define INPUT(NAME, WIDTH) input [WIDTH-1:0] NAME
`define INPUT_SIGNED(NAME, WIDTH) input signed [WIDTH-1:0] NAME
`define OUTPUT(NAME, WIDTH) output [WIDTH-1:0] NAME
`define INOUT(NAME, WIDTH) inout [WIDTH-1:0] NAME

//WIRES AND VARIABLES
`define VAR(NAME, WIDTH) reg [WIDTH-1:0] NAME;
`define WIRE(NAME, WIDTH) wire [WIDTH-1:0] NAME;
`define WIRE_SIGNED(NAME, WIDTH) wire signed [WIDTH-1:0] NAME;
//convert VAR to WIRE
`define VAR2WIRE(OUT, IN) assign OUT = IN;


//SIGNAL (deprecated)
`define SIGNAL(NAME, WIDTH) reg [WIDTH-1:0] NAME;
`define SIGNAL_OUT(NAME, WIDTH) wire [WIDTH-1:0] NAME;
`define SIGNAL_SIGNED(NAME, WIDTH) reg signed [WIDTH-1:0] NAME;
//convert signal to output
`define SIGNAL2OUT(OUT, IN) assign OUT = IN;

//REGISTER
`define REG(CLK, OUT, IN) always @(posedge CLK) OUT <= IN;
`define REG_E(CLK, EN, OUT, IN) always @(posedge CLK) if(EN) OUT <= IN;
`define REG_R(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else OUT <= IN;
`define REG_RE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else if (EN) OUT <= IN;
`define REG_AR(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; else OUT <= IN;
`define REG_ARE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; else if (EN) OUT <= IN;

//SHIFT REGISTER
//serial-in and parallel out shift reg
`define SIPO_REG(CLK, OUT, IN) always @(posedge CLK) OUT <= (OUT << 1) | IN;
`define SIPO_REG_E(CLK, EN, OUT, IN) always @(posedge CLK) if (EN) OUT <= (OUT << 1) | IN;
`define SIPO_REG_R(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else OUT <= (OUT << 1) | IN;
`define SIPO_REG_RE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else if(EN) OUT <= (OUT << 1) | IN;
`define SIPO_REG_AR(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; \
   else OUT <= (OUT << 1) | IN;
`define SIPO_REG_ARE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; \
   else if(EN) OUT <= (OUT << 1) | IN;

//parallel in and serial-out shift reg
`define PISO_REG(CLK, LD, OUT, IN) always @(posedge CLK) if(LD) OUT <= IN; else OUT <= (OUT >> 1);
`define PISO_REG_E(CLK, LD, EN, OUT, IN) always @(posedge CLK) if(LD) OUT <= IN; else if (EN) OUT <= (OUT >> 1);

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
`define WRAPCNT_R(CLK, RST, NAME, WRAP) \
   `REG_R(CLK, RST, 1'b0, NAME, (NAME>=WRAP? 1'b0: NAME+1'b1))
`define WRAPCNT_RE(CLK, RST, EN, NAME, WRAP) \
   `REG_RE(CLK, RST, 1'b0, EN, NAME, (NAME>=WRAP? 1'b0: NAME+1'b1))
`define WRAPCNT_AR(CLK, RST, NAME, WRAP) \
   `REG_AR(CLK, RST, 1'b0, NAME, (NAME>=WRAP? 1'b0: NAME+1'b1))
`define WRAPCNT_ARE(CLK, RST, EN, NAME, WRAP) \
   `REG_ARE(CLK, RST, 1'b0, EN, NAME, (NAME>=WRAP? 1'b0: NAME+1'b1))

//SOFTWARE ACCESSIBLE REGISTER
`define SWREG_R(NAME, WIDTH, RST_VAL) wire [WIDTH-1:0] NAME;
`define SWREG_W(NAME, WIDTH, RST_VAL) reg [WIDTH-1:0] NAME;

//COMBINATORIAL CIRCUIT
`define COMB always @*


//MUX
`define MUX(SEL, OUT, IN) `COMB OUT = IN[SEL];


   // SYNCRONIZERS
   // reset sync
`define RESET_SYNC(CLK, RST_IN, RST_OUT) \
   reg [1:0] RST_IN``_``RST_OUT``_sync; \
   always @(posedge CLK, posedge RST_IN) \
   if(RST_IN)  RST_IN``_``RST_OUT``_sync <= 2'b11; else RST_IN``_``RST_OUT``_sync <= {RST_IN``_``RST_OUT``_sync[0], 1'b0}; \
   `COMB RST_OUT = RST_IN``_``RST_OUT``_sync[1];

   //use this one when `` is not supported
`define RESET_SYNC_(CLK, RST_IN, SYNC_REG, RST_OUT) \
   reg [1:0] SYNC_REG; \
   always @(posedge CLK, posedge RST_IN) \
   if(RST_IN)  SYNC_REG <= 2'b11; else SYNC_REG <= {SYNC_REG[0], 1'b0}; \
   `COMB RST_OUT = SYNC_REG[1];

   //fast to slow
`define F2S_SYNC(CLK, IN, OUT) \
    `RESET_SYNC(CLK, IN, OUT)

   //use this one when `` is not supported
`define F2S_SYNC_(CLK, IN, IN_SYNC, OUT) \
    `RESET_SYNC_(CLK, IN, IN_SYNC, OUT)

   //regular 2-flop sync
`define SYNC(CLK, RST, RST_VAL, W, IN, OUT) \
   reg [W-1:0] IN``_sync[1:0]; \
   always @(posedge CLK, posedge RST) \
   if(RST) begin \
      IN``_sync[0] <= RST_VAL; \
      IN``_sync[1] <= RST_VAL; \
   end else begin \
      IN``_sync[0] <= IN; \
      IN``_sync[1] <= IN``_sync[0]; \
   end \
   `COMB OUT = IN``_sync[1];

   //use this one when `` is not supported
`define SYNC_(CLK, RST, RST_VAL, W, IN, SYNC_REG, OUT) \
   reg [W-1:0] SYNC_REG[1:0]; \
   always @(posedge CLK, posedge RST) \
   if(RST) begin \
      SYNC_REG[0] <= RST_VAL; \
      SYNC_REG[1] <= RST_VAL; \
   end else begin \
      SYNC_REG[0] <= IN; \
      SYNC_REG[1] <= SYNC_REG[0]; \
   end \
   `COMB OUT = SYNC_REG[1];


`define S2F_SYNC(CLK, RST, RST_VAL, W, IN, OUT) \
   `SYNC(CLK, RST, RST_VAL, IN, OUT)

   //use this one when `` is not supported
`define S2F_SYNC_(CLK, RST, RST_VAL, W, IN, IN_SYNC, OUT) \
   `SYNC_(CLK, RST, RST_VAL, W, IN, IN_SYNC, OUT)


//Posedge Detector
`define POSEDGE_DETECT(CLK, RST, IN, OUT) \
   reg IN``_det_reg; \
   always @(posedge CLK, posedge RST) \
     if(RST) \
       IN``_det_reg <= 1'b1; \
     else \
       IN``_det_reg <= IN; \
   `COMB OUT = IN & ~IN``_det_reg;

   //use this one when `` is not supported
`define POSEDGE_DETECT_(CLK, RST, IN, IN_REG, OUT) \
   reg IN_REG; \
   always @(posedge CLK, posedge RST) \
     if(RST) \
       IN_REG <= 1'b1; \
     else \
       IN_REG <= IN; \
   `COMB OUT = IN & ~IN_REG;

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
   
