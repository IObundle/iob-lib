`timescale 1ns / 1ps
`include "iob_lib.vh"

//
// APB slave port to IOb master interface

module apb2iob
  #(
    parameter APB_ADDR_W = 32,     // APB address bus width in bits
    parameter APB_DATA_W = 32,     // APB data bus width in bits
    parameter ADDR_W = APB_ADDR_W, // IOb address bus width in bits
    parameter DATA_W = APB_DATA_W  // IOb data bus width in bits
    )
   (
    // APB slave interface
`include "apb_s_port.vh"
    
    // IOb master interface
`include "iob_m_port.vh"

    // Global signals
`include "iob_clkenrst_port.vh"
    );


   // APB outputs
   `IOB_VAR(apb_ready_nxt, 1)

   iob_reg
     #(1,0)
   apb_ready_reg_inst
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .data_i(apb_ready_nxt),
      .data_o(apb_ready_o)
      );

   assign apb_rdata_o = iob_rdata_i;

   `IOB_WIRE(pc, 1)
   `IOB_VAR(pc_nxt, 1)
   iob_reg
     #(1,0)
   pc_reg
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .data_i(pc_nxt),
      .data_o(pc)
      );
      
   `IOB_VAR(iob_avalid_int, 1)

   `IOB_COMB begin
      
      pc_nxt = pc+1'b1;
      iob_avalid_int = 1'd1;
      apb_ready_nxt = apb_write_i? iob_ready_nxt_i : iob_rvalid_nxt_i;
   
      case(pc)
        0: begin
           if(!apb_sel_i) begin//wait periph selection
             pc_nxt = pc;
             iob_avalid_int = 1'b0;
             apb_ready_nxt = 1'd0;
           end
        end

        default: begin
           if (apb_enable_i && !apb_ready_o)
             pc_nxt = pc;
        end
      endcase
   end

   assign iob_avalid_o = iob_avalid_int;
   assign iob_addr_o  = apb_addr_i;
   assign iob_wdata_o = apb_wdata_i;
   assign iob_wstrb_o = apb_wstrb_i;
  
endmodule
