`timescale 1ns / 1ps

// Demux that works like iob_mux (uses an output reg).
module iob_demux2 #(
   parameter DATA_W = 21,
   parameter N      = 21
) (
   input      [($clog2(N)+($clog2(N)==0))-1:0] sel_i,
   input      [                    DATA_W-1:0] data_i,
   output reg [                (N*DATA_W)-1:0] data_o
);

   //Select the data to output
   integer i;
   always @* begin
      data_o = {N*DATA_W{1'b0}};
      for (i = 0; i < N; i = i + 1) begin : gen_demux
         if (i == sel_i) begin
            data_o[i*DATA_W+:DATA_W] = data_i;
         end
      end
   end

endmodule
