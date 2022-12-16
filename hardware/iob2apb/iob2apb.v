`timescale 1ns / 1ps
`include "iob_lib.vh"

//
// IOb slave interface to APB master interface
//

module iob2apb
  #(
    parameter APB_ADDR_W = 32,     // APB address bus width in bits
    parameter APB_DATA_W = 32,     // APB data bus width in bits
    parameter ADDR_W = APB_ADDR_W, // IOb address bus width in bits
    parameter DATA_W = APB_DATA_W  // IOb data bus width in bits
    )
   (
    // IOb slave interface
`include "iob_s_port.vh"

    // APB master interface
`include "apb_m_port.vh"

    // Global signals
`include "iob_clkrst_port.vh"
    );

   //APB outputs
   `IOB_VAR(apb_sel_nxt, 1)
   iob_reg_a #(1,0) sel_reg (clk_i, arst_i, apb_sel_nxt, apb_sel_o);

   `IOB_VAR(apb_enable_nxt, 1)
   iob_reg_a #(1,0) enable_reg (clk_i, arst_i, apb_enable_nxt, apb_enable_o);

   `IOB_VAR(apb_addr_nxt, ADDR_W)
   iob_reg_a #(ADDR_W,0) addr_reg (clk_i, arst_i, apb_addr_nxt, apb_addr_o);

   `IOB_VAR(apb_wstrb_nxt, (DATA_W/8))
   iob_reg_a #(DATA_W/8,0) wstrb_reg (clk_i, arst_i, apb_wstrb_nxt, apb_wstrb_o);

   `IOB_VAR(apb_write_nxt, 1)
   iob_reg_a #(1,0) write_reg (clk_i, arst_i, apb_write_nxt, apb_write_o);

   `IOB_VAR(apb_wdata_nxt, DATA_W)
   iob_reg_a #(DATA_W,0) wdata_reg (clk_i, arst_i, apb_wdata_nxt, apb_wdata_o);

   //IOb outputs
   `IOB_VAR(iob_ready_nxt, 1)
   iob_reg_a #(1,1) ready_reg (clk_i, arst_i, iob_ready_nxt, iob_ready_o);

   `IOB_VAR(iob_rvalid_nxt, 1)
   iob_reg_a #(1,0) rvalid_reg (clk_i, arst_i, iob_rvalid_nxt, iob_rvalid_o);

   `IOB_VAR(iob_rdata_nxt, DATA_W)
   iob_reg_a #(DATA_W,0) rdata_reg (clk_i, arst_i, iob_rdata_nxt, iob_rdata_o);
   
   `IOB_WIRE(pc, 1)
   `IOB_VAR(pc_nxt, 1)
   iob_reg_a #(1,0) access_reg (clk_i, arst_i, pc_nxt, pc);
   
   `IOB_COMB begin
      
      pc_nxt = pc+1'b1;
      
      apb_sel_nxt = apb_sel_o;
      apb_enable_nxt = apb_enable_o;
      apb_addr_nxt = apb_addr_o;
      apb_write_nxt = apb_write_o;
      apb_wstrb_nxt = apb_wstrb_o;
      apb_wdata_nxt = apb_wdata_o;
      
      iob_rdata_nxt = iob_rdata_o;
      iob_rvalid_nxt = 0;
      iob_ready_nxt = iob_ready_o;
      

      case(pc)
        0: begin
           if(!iob_avalid_i) //wait for iob request
             pc_nxt = pc;
           else begin // sample iob signals and initiate apb transaction
              apb_addr_nxt = iob_addr_i;
              apb_write_nxt = (iob_wstrb_i != 0);
              apb_wstrb_nxt = iob_wstrb_i;
              apb_wdata_nxt = iob_wdata_i;
              apb_sel_nxt = 1'b1;

              iob_ready_nxt = 1'b0;
           end
        end
        1: begin
           apb_enable_nxt = 1'b1;
           if(!apb_ready_i) //wait until apb interface is ready
             pc_nxt = pc;
           else begin //sample apb response, assert rvalid and finish transaction
              iob_rdata_nxt = apb_rdata_i;
              iob_rvalid_nxt = 1'b1;              
              iob_ready_nxt = 1'b1;
              pc_nxt = 0;
              apb_sel_nxt = 1'b0;
              apb_enable_nxt = 1'b0;
           end
        end
      endcase
   end

   
endmodule
