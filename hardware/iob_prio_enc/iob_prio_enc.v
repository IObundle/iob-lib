`timescale 1ns / 1ps

module iob_prio_enc
   #(
      parameter WIDTH = 0,
      // Priority: "LOWEST", "HIGHEST"
      parameter PRIO = "LOWEST" //"LOWEST" -> smaller index
   )
   (
   `IOB_INPUT(unencoded_i, WIDTH),
   `IOB_OUTPUT_VAR(encoded_o, ($clog2(WIDTH)+1))
   );
      
   integer i;
   generate
      if (PRIO == "LOWEST") begin
         `IOB_COMB begin
            encoded_o = {($clog2(WIDTH)+1){1'd0}};  //In case input is 0
            for (i = WIDTH-1; i !=-1 ; i = i-1)
               if (unencoded_i[i])
                  encoded_o = i;
         end
      end else begin   //PRIO == "HIGHEST"
         `IOB_COMB begin
            encoded_o = WIDTH; //In case input is 0
            for (i = 0; i !=WIDTH ; i = i+1)
               if (unencoded_i[i])
                  encoded_o = i;
         end
      end
   endgenerate

endmodule
