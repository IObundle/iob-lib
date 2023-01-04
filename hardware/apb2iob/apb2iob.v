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

   `IOB_WIRE(apb_ready_nxt, 1)
   `IOB_VAR(iob_avalid_nxt, 1)

   assign apb_ready_nxt = apb_write_i? (iob_avalid_nxt & iob_ready_nxt_i): iob_rvalid_nxt_i;

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

   // IOb outputs
   iob_reg
     #(1,0)
   avlid_reg
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .data_i(iob_avalid_nxt),
      .data_o(iob_avalid_o)
      );

   `IOB_WIRE(pc, 2)
   `IOB_VAR(pc_nxt, 2)
   iob_reg
     #(2,0)
   pc_reg
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .data_i(pc_nxt),
      .data_o(pc)
      );

   `IOB_COMB begin
      
      pc_nxt = pc+1'b1;
      iob_avalid_nxt = iob_avalid_o;
      
      case(pc)
        0: begin
           if(!apb_sel_i) //wait periph selection
             pc_nxt = pc;
           else
             iob_avalid_nxt = 1'b1;
        end

        1: begin
           if(!iob_ready_nxt_i) //wait until iob interface is ready
             pc_nxt = pc;
           else
             iob_avalid_nxt = 1'b0; //deassert valid - transaction will be done
        end
        
        default: begin //wait apb transaction to finish
           if(apb_sel_i)
             pc_nxt = pc;
           else
              pc_nxt = 0;
        end
      endcase
   end

   assign iob_addr_o  = apb_addr_i;
   assign iob_wdata_o = apb_wdata_i;
   assign iob_wstrb_o = apb_wstrb_i;
  
endmodule
