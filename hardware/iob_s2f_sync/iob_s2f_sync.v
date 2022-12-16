`timescale 1ns / 1ps

module iob_s2f_sync
  #(
    parameter DATA_W = 32,
    parameter RST_VAL = 0
    )
   (
    input                   clk_i,
    input                   arst_i,
    input                   rst_i,

    input                   ld_i,
    input [DATA_W-1:0]      ld_val_i,

    input [DATA_W-1:0]      data_i,
    output reg [DATA_W-1:0] data_o
    );

   reg [DATA_W-1:0]         sync;
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         sync <= RST_VAL[DATA_W-1:0];
         data_o <= RST_VAL[DATA_W-1:0];
      end else if (rst_i) begin
         sync <= RST_VAL[DATA_W-1:0];
         data_o <= RST_VAL[DATA_W-1:0];
      end else if (ld_i) begin
         sync <= ld_val_i;
         data_o <= ld_val_i;
      end else begin
         sync <= data_i;
         data_o <= sync;
      end
   end

endmodule
