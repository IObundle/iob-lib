`timescale 1ns / 1ps

`include "iob_lib.vh"

module iob_split
  #(
    parameter DATA_W = 32,
    parameter ADDR_W = 32,
    parameter N_SLAVES = 2, //number of slaves
    parameter P_SLAVES = `REQ_W-2 //slave select word msb position
    )
   (
    input                            clk_i,
    input                            rst_i,

    //masters interface
    input [`REQ_W-1:0]               m_req_i,
    output reg [`RESP_W-1:0]         m_resp_o,

    //slave interface
    output reg [N_SLAVES*`REQ_W-1:0] s_req_o,
    input [N_SLAVES*`RESP_W-1:0]     s_resp_i
    );

   localparam  Nb=$clog2(N_SLAVES)+($clog2(N_SLAVES)==0);


   //slave select word
   wire [Nb-1:0] s_sel;
   assign s_sel = m_req_i[P_SLAVES -:Nb];

   //route master request to selected slave
   integer i;
   always @* begin
      /*
     $display("pslave %d", P_SLAVES+1);
     $display("mreq %x", m_req);
     $display("s_sel %x", s_sel);
   */
     for (i=0; i<N_SLAVES; i=i+1)
       if(i == s_sel) begin
         s_req_o[`req(i)] = m_req_i;
       end else
         s_req_o[`req(i)] = {(`REQ_W){1'b0}};
   end

   //
   //route response from previously selected slave to master
   //

   //register the slave selection
   reg [Nb-1:0] s_sel_reg;
   always @( posedge clk_i, posedge rst_i ) begin
      if( rst_i )
        s_sel_reg <= {Nb{1'b0}};
      else
        s_sel_reg <= s_sel;
   end

   //route
   integer j;
   always @* begin
      for (j=0; j<N_SLAVES; j=j+1)
        if( j == s_sel_reg )
          m_resp_o[`rdata(0)]  = s_resp_i[`rdata(j)];
          m_resp_o[`rvalid(0)] = s_resp_i[`rvalid(j)];
          m_resp_o[`ready(0)]  = s_resp_i[`ready(j)];
   end

endmodule
