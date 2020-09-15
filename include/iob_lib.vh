//IOs
`define INPUT(NAME, WIDTH) input [WIDTH-1:0] NAME
`define INPUT_S(NAME, WIDTH) input signed [WIDTH-1:0] NAME
`define OUTPUT(NAME, WIDTH) output [WIDTH-1:0] NAME
`define OUTPUT_S(NAME, WIDTH) output signed [WIDTH-1:0] NAME
`define OUTPUT_R(NAME, WIDTH) output reg [WIDTH-1:0] NAME
`define OUTPUT_RS(NAME, WIDTH) output reg signed [WIDTH-1:0] NAME
`define INOUT(NAME, WIDTH) inout [WIDTH-1:0] NAME
`define INOUT_S(NAME, WIDTH) inout signed [WIDTH-1:0] NAME

//SIGNALs
`define SIGNAL(NAME, WIDTH) reg [WIDTH-1:0] NAME
`define SIGNAL_S(NAME, WIDTH) reg signed [WIDTH-1:0] NAME
`define SIGNAL_O(NAME, WIDTH) wire [WIDTH-1:0] NAME
`define SIGNAL_OS(NAME, WIDTH) wire signed [WIDTH-1:0] NAME

//REGISTERS
`define REG(CLK, OUT, IN) always @(posedge clk) OUT <= IN
`define REG_E(CLK, EN, OUT, IN) always @(posedge clk) if(EN) OUT <= IN

`define REG_R(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= IVAL; else OUT <= IN
`define REG_RE(CLK, RST, EN, RST_VAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= IVAL; else if (EN) OUT <= IN

`define REG_AR(CLK, RST, RST_VAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= IVAL; else OUT <= IN

`define REG_ARE(CLK, RST, EN, RST_VAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= IVAL; else if (EN) OUT <= IN

//SOFTWARE ACCESSIBLE REGISTERS
`define SWREG_R(NAME, WIDTH, RST_VAL) wire [WIDTH-1:0] NAME
`define SWREG_R_S(NAME, WIDTH, RST_VAL) wire signed [WIDTH-1:0] NAME
`define SWREG_W(NAME, WIDTH, RST_VAL) reg [WIDTH-1:0] NAME
`define SWREG_W_S(NAME, WIDTH, RST_VAL) reg signed [WIDTH-1:0] NAME
`define SWREG_RW(NAME, WIDTH, RST_VAL) reg [WIDTH-1:0] NAME
`define SWREG_RW_S(NAME, WIDTH, RST_VAL) reg signed [WIDTH-1:0] NAME

//convert some internal reg type (IN) to SWREG_R wire (OUT)
`define TO_SWREG_R(OUT, IN) assign OUT = IN;

   
 //COMBINATORIAL CIRCUIT
`define COMB always @* begin
`define ENDCOMB end


//CLOCK GENERATOR

`define CLOCK(PER) initial CLK=1; always #PER clk = ~CLK

   
   
   
