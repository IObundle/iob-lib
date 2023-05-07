`timescale 1ns / 1ps


module iob_prio_enc
   #(
      parameter WIDTH = 21,
      // Priority: "LOWEST", "HIGHEST"
      parameter PRIO = "LOWEST" //"LOWEST" -> smaller index
   )
   (
   input [WIDTH-1:0] unencoded_i,
   output reg [($clog2(WIDTH)+1)-1:0] encoded_o
   );
      
   integer pos;
   generate
      if (PRIO == "LOWEST") begin
         always @* begin
            encoded_o = {($clog2(WIDTH)+1){1'd0}};  //In case input is 0
            for (pos = WIDTH-1; pos !=-1 ; pos = pos-1)
               if (unencoded_i[pos])
                  encoded_o = pos;
         end
      end else begin   //PRIO == "HIGHEST"
         always @* begin
            encoded_o = WIDTH; //In case input is 0
            for (pos = 0; pos !=WIDTH ; pos = pos+1)
               if (unencoded_i[pos])
                  encoded_o = pos;
         end
      end
   endgenerate

endmodule
