`timescale 1ns / 1ps

module iob_acc_ld #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}}
) (
   `include "iob_clkenrst_port.vs"

   input rst_i,
   input en_i,

   input              ld_i,
   input [DATA_W-1:0] ld_val_i,

   input  [DATA_W-1:0] incr_i,
   output [DATA_W-1:0] data_o
);

   wire [DATA_W-1:0] data;
   assign data = ld_i ? ld_val_i : data_o + incr_i;

   iob_reg_re #(
      .DATA_W(DATA_W),
      .RST_VAL(RST_VAL)
   ) reg0 (
      `include "iob_clkenrst_portmap.vs"

      .rst_i(rst_i),
      .en_i (en_i),

      .data_i(data),
      .data_o(data_o)
   );

endmodule
