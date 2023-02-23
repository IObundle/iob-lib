`timescale 1ns / 1ps

module iob_sync
  #(
    parameter DATA_W = 21,
    parameter RST_VAL = {DATA_W{1'b0}}
  )
  (
    input                   clk_i,
    input                   arst_i,
    input [DATA_W-1:0]      signal_i,
    output reg [DATA_W-1:0] signal_o
  );

  reg [DATA_W-1:0] sync;

  always @(posedge clk_i, posedge arst_i) begin
    if (arst_i) begin
      sync <= RST_VAL;
    end else begin
      sync <= signal_i;
    end
  end

  always @(posedge clk_i, posedge arst_i) begin
    if (arst_i) begin
      signal_o <= RST_VAL;
    end else begin
      signal_o <= sync;
    end
  end

endmodule
