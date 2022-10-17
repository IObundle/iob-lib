`timescale 1ns / 1ps

module iob_pulse_gen
  #(
    parameter START=5,
    parameter DURATION=5
    )
  (
   input      clk_i,
   input      arst_i,
   input      restart_i,
   output reg pulse_o
   );

   localparam WIDTH = DURATION==1? 1: $clog2(DURATION);
   
   reg [WIDTH-1:0] cnt;
   
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         cnt <= {WIDTH{1'b0}};
         pulse_o <= 1'b0;
      end else if (restart_i) begin
         cnt <= {WIDTH{1'b0}};
         pulse_o <= 1'b0;
      end else begin
        cnt <= cnt+1'b1;
        if ( cnt == START )
          pulse_o <= 1'b1;
        else if ( cnt == (START+DURATION) ) begin
           pulse_o <= 1'b0;
           cnt <= cnt;
        end
      end
   end

endmodule
