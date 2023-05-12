`timescale 1ns / 1ps

module iob_reg_r #(
    parameter DATA_W  = 21,
    parameter RST_VAL = {DATA_W{1'b0}},
    parameter CLKEDGE = "posedge"
) (
    input clk_i,
    input arst_i,
    input cke_i,

    input rst_i,

    input      [DATA_W-1:0] data_i,
    output reg [DATA_W-1:0] data_o
);

   generate
      if (CLKEDGE == "posedge") begin : positive_edge
         always @(posedge clk_i, posedge arst_i)
            if (arst_i) data_o <= RST_VAL;
            else if (cke_i) begin
               if (rst_i) data_o <= RST_VAL;
               else data_o <= data_i;
            end
      end else begin : negative_edge
         always @(negedge clk_i, posedge arst_i)
            if (arst_i) data_o <= RST_VAL;
            else if (cke_i) begin
               if (rst_i) data_o <= RST_VAL;
               else data_o <= data_i;
            end
      end
   endgenerate

endmodule
