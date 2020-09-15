//
//include this file in your top module to assign registers 
//

`define R_TYP 1
`define W_TYP 2
`define RW_TYP 3


/*
 in your project do:
 
`define NAME_REG(I) I2S_TDM_REG_I
`define NAME_REG_INI(I) I2S_TDM_REG_INIT_I

//generate following definitions using script

//name mapping
`define `NAME_REG(0) actual_reg0_name
....
`define `NAME_REG(N) actual_regN_name

//width mapping 
`define `NAME_REG_W(0) reg0_width;
....
`define `NAME_REG_W(N) regN_width;

//init val mapping
`define `NAME_REG_INI(0) reg0_init_val;
....
`define `NAME_REG_INI(N) regN_init_val;

//init type mapping
`define `NAME_REG_TYP(0) reg0_init_val;
....
`define `NAME_REG_TYP(N) regN_init_val;

 */


//write registers
genvar i;
generate for (i=0; i<`N_WREGS; i=i+1)
  if(`NAME_REG_TYP(i) == W_TYP || `NAME_REG_TYP(i) == RW_TYP)
    `REG_ARE(clk, rst, valid & wstrb, `NAME_REG_INI(i), wdata[`NAME_REG_W(i)]);  
endgenerate
    
//read registers
generate for (i=0; i<`N_WREGS; i=i+1)
  `COMB
    if(`NAME_REG_TYP(i) == R_TYP || `NAME_REG_TYP(i) == RW_TYP)
      rdata = `NAME_REG(i) | `DATA_W'd0;
    else
      rdata = `DATA_W'd0;
   `ENDCOMB  
endgenerate
    
// reply with ready
`REG_AR(clk, rst, ready, valid);
   
