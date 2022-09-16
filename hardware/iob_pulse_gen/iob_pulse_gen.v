`timescale 1ns / 1ps

module iob_pulse_gen
  #(
    parameter START=5,
    parameter DURATION=5
    )
  (
   input      clk,
   input      arst,
   input      restart,
   output reg pulse_out
   );

   localparam WIDTH = DURATION==1? 1: $clog2(DURATION);
   
   reg [WIDTH-1:0] cnt;
   
   always @(posedge clk, posedge arst) begin
      if (arst) begin
         cnt <= {WIDTH{1'b0}};
         pulse_out <= 1'b0;
      end else if (restart) begin
         cnt <= {WIDTH{1'b0}};
         pulse_out <= 1'b0;
      end else begin
        cnt <= cnt+1'b1;
        if ( cnt == START )
          pulse_out <= 1'b1;
        else if ( cnt == (START+DURATION) ) begin
           pulse_out <= 1'b0;
           cnt <= cnt;
        end
      end
   end

endmodule
