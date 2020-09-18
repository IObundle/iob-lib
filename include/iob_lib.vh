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
`define REG(CLK, OUT, IN) always @(posedge clk) OUT <= IN;
`define REG_E(CLK, EN, OUT, IN) always @(posedge clk) if(EN) OUT <= IN;
`define REG_R(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else OUT <= IN;
`define REG_RE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK) if (RST) OUT <= RST_VAL; else if (EN) OUT <= IN;
`define REG_AR(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; else OUT <= IN;
`define REG_ARE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= RST_VAL; else if (EN) OUT <= IN;

//SHIFT REGISTER
`define S_REG(CLK, OUT, IN) always @(posedge clk) OUT <= (OUT << 1) | IN;
`define S_REG_E(CLK, EN, OUT, IN) always @(posedge clk) if (EN) OUT <= (OUT << 1) | IN;
`define S_REG_R(CLK, RST, RST_VAL, OUT, IN) always @(posedge clk) if (RST) OUT <= RST_VAL; else OUT <= (OUT << 1) | IN;
`define S_REG_RE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge clk) if (RST) OUT <= RST_VAL; else if(EN) OUT <= (OUT << 1) | IN;
`define S_REG_AR(CLK, RST, RST_VAL, OUT, IN) always @(posedge clk, posedge RST) if (RST) OUT <= RST_VAL; \
   else OUT <= (OUT << 1) | IN;
`define S_REG_ARE(CLK, RST, RST_VAL, EN, OUT, IN) always @(posedge clk, posedge RST) if (RST) OUT <= RST_VAL; \
   else if(EN) OUT <= (OUT << 1) | IN;
 
//COUNTER
`define COUNTER_R(CLK, RST, NAME) \
   `REG_R(CLK, RST, 0, NAME, NAME+1'b1)
`define COUNTER_RE(CLK, RST, EN, NAME) \
   `REG_ARE(CLK, RST, 0, EN, NAME, NAME+1'b1)
`define COUNTER_AR(CLK, RST, NAME) \
   `REG_AR(CLK, RST, 0, NAME, NAME+1'b1)
`define COUNTER_ARE(CLK, RST, EN, NAME) \
   `REG_ARE(CLK, RST, 0, EN, NAME, NAME+1'b1)

//CIRCULAR COUNTER
`define WRAPCNT_R(CLK, RST, NAME, WRAP) \
   `REG_R(CLK, RST, 0, NAME, (NAME==WRAP? 0: NAME+1'b1))
`define WRAPCNT_AR(CLK, RST, NAME, WRAP) \
   `REG_AR(CLK, RST, 0, NAME, (NAME==WRAP? 0: NAME+1'b1))
`define WRAPCNT_ARE(CLK, RST, EN, NAME, WRAP) \
   `REG_ARE(CLK, RST, 0, EN, NAME, (NAME==WRAP? 0: NAME+1'b1))

//SOFTWARE ACCESSIBLE REGISTER
`define SWREG_R(NAME, WIDTH, RST_VAL) reg [WIDTH-1:0] NAME
`define SWREG_W(NAME, WIDTH, RST_VAL) reg [WIDTH-1:0] NAME
`define SWREG_RW(NAME, WIDTH, RST_VAL) reg [WIDTH-1:0] NAME
   
//COMBINATORIAL CIRCUIT
`define COMB always @*

// SYNCRONIZERS
`define RESET_SYNC(CLK, RST_IN, SYNC, RST_OUT) \
   wire  RST_OUT; \
   reg [1:0] SYNC; \
   always @(posedge CLK, posedge RST_IN) \
   if(RST_IN) SYNC <= 2'b11; else SYNC <= {SYNC[0], 1'b0}; \
   assign RST_OUT = SYNC[1];
   
`define S2F_SYNC(CLK, rst, W, IN, SYNC, OUT) \
   reg [W-1:0] SYNC [1:0]; \
   always @(posedge CLK, posedge RST) \
   if(rst) begin \
   SYNC[0] <= W'b0; \
   SYNC[1] <= W'b0; \
   end else begin \
      SYNC[0] <= IN; \
      SYNC[1] <= SYNC[0]; \
   end


//
// COMMON TESTBENCH UTILS
//
   
//CLOCK GENERATOR
`define CLOCK(CLK, PER) reg CLK=1; always #PER CLK = ~CLK;


//RESET GENERATOR
`define RESET(RST, RISE_TIME, DURATION) reg RST=0; \
initial begin #RISE_TIME RST=1; #DURATION RST=0; end
    
   
   
   
