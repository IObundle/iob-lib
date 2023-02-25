`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_prio_enc
   #(
      parameter WIDTH = 21,
      // Priority: "LOWEST", "HIGHEST"
      parameter PRIO = "LOWEST" //"LOWEST" -> smaller index
   )
   (
   `IOB_INPUT(unencoded_i, WIDTH),
   `IOB_OUTPUT_VAR(encoded_o, ($clog2(WIDTH)+1))
   );
      
   integer pos;
   generate
      if (PRIO == "LOWEST") begin
         `IOB_COMB begin
            encoded_o = {($clog2(WIDTH)+1){1'd0}};  //In case input is 0
            for (pos = WIDTH-1; pos !=-1 ; pos = pos-1)
               if (unencoded_i[pos])
                  encoded_o = pos;
         end
      end else begin   //PRIO == "HIGHEST"
         `IOB_COMB begin
            encoded_o = WIDTH; //In case input is 0
            for (pos = 0; pos !=WIDTH ; pos = pos+1)
               if (unencoded_i[pos])
                  encoded_o = pos;
         end
      end
   endgenerate

endmodule
