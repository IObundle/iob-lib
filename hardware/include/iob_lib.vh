//IO
`define INPUT(NAME, WIDTH) input [WIDTH-1:0] NAME
`define OUTPUT(NAME, WIDTH) output [WIDTH-1:0] NAME
`define INOUT(NAME, WIDTH) inout [WIDTH-1:0] NAME

//SIGNAL
`define SIGNAL(NAME, WIDTH) reg [WIDTH-1:0] NAME;
`define SIGNAL_SIGNED(NAME, WIDTH) reg signed [WIDTH-1:0] NAME;
`define SIGNAL_OUT(NAME, WIDTH) wire [WIDTH-1:0] NAME;
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
   `REG_R(CLK, RST, 0, NAME, NAME+1'b1)
`define COUNTER_RE(CLK, RST, EN, NAME) \
   `REG_RE(CLK, RST, 0, EN, NAME, NAME+1'b1)
`define COUNTER_AR(CLK, RST, NAME) \
   `REG_AR(CLK, RST, 0, NAME, NAME+1'b1)
`define COUNTER_ARE(CLK, RST, EN, NAME) \
   `REG_ARE(CLK, RST, 0, EN, NAME, NAME+1'b1)

//CIRCULAR COUNTER
`define WRAPCNT_R(CLK, RST, NAME, WRAP) \
   `REG_R(CLK, RST, !1, NAME, (NAME>=WRAP? !1: NAME+1'b1))
`define WRAPCNT_RE(CLK, RST, EN, NAME, WRAP) \
   `REG_RE(CLK, RST, !1, EN, NAME, (NAME>=WRAP? !1: NAME+1'b1))
`define WRAPCNT_AR(CLK, RST, NAME, WRAP) \
   `REG_AR(CLK, RST, !1, NAME, (NAME>=WRAP? !1: NAME+1'b1))
`define WRAPCNT_ARE(CLK, RST, EN, NAME, WRAP) \
   `REG_ARE(CLK, RST, !1, EN, NAME, (NAME>=WRAP? !1: NAME+1'b1))

//SOFTWARE ACCESSIBLE REGISTER
`define SWREG_R(NAME, WIDTH, RST_VAL) wire [WIDTH-1:0] NAME;
`define SWREG_W(NAME, WIDTH, RST_VAL) reg [WIDTH-1:0] NAME;

//COMBINATORIAL CIRCUIT
`define COMB always @*


//MUX
`define MUX(SEL, OUT, IN) `COMB OUT = IN[SEL];


// SYNCRONIZERS
`define RESET_SYNC(CLK, RST_IN, RST_OUT) \
   reg [1:0] RST_IN``_sync; \
   always @(posedge CLK, posedge RST_IN) \
   if(RST_IN)  RST_IN``_sync <= 2'b11; else RST_IN``_sync <= {RST_IN``_sync[0], 1'b0}; \
   `COMB RST_OUT = RST_IN``_sync[1];

`define S2F_SYNC(CLK, RST, W, IN, OUT) \
   reg [W-1:0] IN``_sync [1:0]; \
   always @(posedge CLK, posedge RST) \
   if(RST) begin \
      IN``_sync[0] <= W'b0; \
      IN``_sync[1] <= W'b0; \
   end else begin \
      IN``_sync[0] <= IN; \
      IN``_sync[1] <= IN``_sync[0]; \
   end \
   `COMB OUT = IN``_sync[1];

//Posedge Detector
`define POSEDGE_DETECT(CLK, RST, IN, OUT) \
   reg IN``_det_reg; \
   always @(posedge CLK, posedge RST) \
     if(RST) \
       IN``_det_reg <= 1'b1; \
     else \
       IN``_det_reg <= IN; \
   `COMB OUT = IN & ~IN``_det_reg;


//
// COMMON TESTBENCH UTILS
//

//CLOCK GENERATOR
`define CLOCK(CLK, PER) reg CLK=1; always #(PER/2) CLK = ~CLK;


//RESET GENERATOR
`define RESET(RST, RISE_TIME, DURATION) reg RST=0; \
initial begin #RISE_TIME RST=1; #DURATION RST=0; end
