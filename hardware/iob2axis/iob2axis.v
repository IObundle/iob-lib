//
// AXI-Stream write and read 
//
`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob2axis
  #(
    parameter DATA_W = 0
    )
   (
    `IOB_INPUT(clk_i, 1),
    `IOB_INPUT(arst_i, 1),
    `IOB_INPUT(cke_i, 1),
    
    //iob if
    `IOB_INPUT(valid_i, 1),
    `IOB_INPUT(wstrb_i, DATA_W/8),
    `IOB_INPUT(wdata_i, DATA_W),
    `IOB_OUTPUT(ready_o, 1),
    `IOB_OUTPUT(rvalid_o, 1),

    //axis out (write)
    `IOB_OUTPUT(tdata_o, DATA_W),
    `IOB_OUTPUT(tvalid_o, 1),   
    `IOB_INPUT(tready_i, 1),

    //axis in (read)
    `IOB_INPUT(tdata_i, DATA_W),
    `IOB_INPUT(tvalid_i, 1),   
    `IOB_OUTPUT(tready_o, 1)
    );


   //write
   assign tdata_o = wdata_i;
   assign tvalid_o = |wstrb_i;

   //read
   assign tready_o = valid_i;
   
   
   //ready
   assign ready_o = wstrb_i? tready_i: tvalid_i;

   //rvalid
   `IOB_WIRE(rvalid_nxt, 1)
   assign rvalid_nxt = tvalid_i & tready_o;
   iob_reg
     #(1,0)
   rvalid_reg
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .data_i(rvalid_nxt),
      .data_o(rvalid_o)
      );
   
endmodule 
