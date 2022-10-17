`timescale 1 ns / 1 ps

module iob_regfile_sp
  #(
    parameter ADDR_W = 2,
    parameter DATA_W = 32
    )
   (
    input               clk_i,
    input               rst_i,

    input               we_i,
    input [ADDR_W-1:0]  addr_i,
    input [DATA_W-1:0]  w_data_i,
    output [DATA_W-1:0] r_data_o
    );

   reg [DATA_W-1:0]     reg_file [2**ADDR_W-1:0];

   //read
   assign r_data_o = reg_file[addr_i];

   //write
   genvar               i;
   generate
      for (i=0; i < 2**ADDR_W; i=i+1) begin: register_file
         always @(posedge clk_i)
           if (rst_i)
             reg_file[i] <= {DATA_W{1'b0}};
           else if (we_i)
             if (addr_i == i)
               reg_file[i] <= w_data_i;
        end
   endgenerate

endmodule
