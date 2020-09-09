`define SIGNAL(NAME, WIDTH) reg [WIDTH-1:0] NAME

`define SWREG_R(TYPE, MSB, LSB, NAME, MODE) (TYPE) [(MSB):(LSB)] (NAME)
`define SWREG_W(TYPE, MSB, LSB, NAME, MODE) (TYPE) [(MSB):(LSB)] (NAME)
`define SWREG_RW(TYPE, MSB, LSB, NAME, MODE) (TYPE) [(MSB):(LSB)] (NAME)

`define REG(CLK, OUT, IN) always @(posedge clk) OUT <= IN
`define REG_R(CLK, RST, IVAL, OUT, IN) always @(posedge CLK) if (RST) OUT <= IVAL; else OUT <= IN
`define REG_AR(CLK, RST, IVAL, OUT, IN) always @(posedge CLK, posedge RST) if (RST) OUT <= IVAL; else OUT <= IN

`define COMB always @* begin
`define ENDCOMB end

   
