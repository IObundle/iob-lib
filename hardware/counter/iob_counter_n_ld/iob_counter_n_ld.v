`timescale 1ns / 1ps

module iob_counter_n_ld
  #(
    parameter DATA_W = 32,
    parameter RST_VAL = 0
    )
   (
    input                   clk_i,
    input                   arst_i,
    input                   rst_i,
    input                   en_i,

    input                   ld_i,
    input [DATA_W-1:0]      ld_val_i,

    output reg [DATA_W-1:0] data_o
    );

   // prevent width mismatch
   localparam [DATA_W-1:0] RST_VAL_INT = RST_VAL;

   always @(negedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         data_o <= RST_VAL_INT;
      end else if (rst_i) begin
         data_o <= RST_VAL_INT;
      end else if (ld_i) begin
         data_o <= ld_val_i;
      end else if (en_i) begin
         data_o <= data_o + 1'b1;
      end
   end

endmodule
