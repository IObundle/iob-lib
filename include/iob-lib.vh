//IOs
`define INPUT(NAME, WIDTH) input
`define INPUT_S(NAME, WIDTH) input
`define OUTPUT(NAME, WIDTH) output reg [WIDTH-1:0] NAME
`define OUTPUT_S(NAME, WIDTH) output reg signed [WIDTH-1:0] NAME
`define INOUT(NAME, WIDTH) output reg [WIDTH-1:0] NAME
`define INOUT_S(NAME, WIDTH) output reg signed [WIDTH-1:0] NAME

//SIGNALs
`define SIGNAL(NAME, WIDTH) reg [WIDTH-1:0] NAME
`define SIGNAL_S(NAME, WIDTH) reg signed [WIDTH-1:0] NAME

//REGISTERS
`define REG(CLK, OUT, IN) always @(posedge clk) OUT <= IN
`define REG_R(CLK, RST, IVAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= IVAL; else OUT <= IN
`define REG_AR(CLK, RST, IVAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= IVAL; else OUT <= IN

//SOFTWARE ACCESSIBLE REGISTERS
`define SWREG_R(NAME, WIDTH) reg [WIDTH-1:0] NAME
`define SWREG_R_S(NAME, WIDTH) reg signed [WIDTH-1:0] NAME
`define SWREG_W(NAME, WIDTH) reg [WIDTH-1:0] NAME
`define SWREG_W_S(NAME, WIDTH) reg signed [WIDTH-1:0] NAME
`define SWREG_RW(NAME, WIDTH) reg [WIDTH-1:0] NAME
`define SWREG_RW_S(NAME, WIDTH) reg signed [WIDTH-1:0] NAME

 //COMBINATORIAL CIRCUIT
`define COMB always @* begin
`define ENDCOMB end

   
