`timescale 1 ns / 1 ps

module iob_regfile_dp
  #(
    parameter ADDR_W = 2,
    parameter DATA_W = 32
    )
   (
    input                clk_i,
    input                rst_i,

    // Port A
    input                weA_i,
    input [ADDR_W-1:0]   addrA_i,
    input [DATA_W-1:0]   wdataA_i,
    output [DATA_W-1 :0] rdataA_o,

    // Port B
    input                weB_i,
    input [ADDR_W-1:0]   addrB_i,
    input [DATA_W-1:0]   wdataB_i,
    output [DATA_W-1 :0] rdataB_o
    );

   reg [DATA_W-1:0]      reg_file [2**ADDR_W-1:0];

   wire [ADDR_W-1:0]     addr  = weA_i? addrA_i : addrB_i;
   wire [DATA_W-1:0]     wdata = weA_i? wdataA_i : wdataB_i;
   wire                  we    = weA_i? weA_i : weB_i;

   //read
   assign rdataA_o = reg_file[addrA_i];
   assign rdataB_o = reg_file[addrB_i];

   //write
   genvar                i;
   generate
      for (i=0; i < 2**ADDR_W; i=i+1) begin: register_file
         always @(posedge clk_i)
           if (rst_i)
             reg_file[i] <= {DATA_W{1'b0}};
           else if (we)
             if (addr == i)
               reg_file[i] <= wdata;
        end
   endgenerate

endmodule
