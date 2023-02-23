`timescale 1ns / 1ps

`include "iob_lib.vh"

module iob_split
  #(
    parameter DATA_W = 21,
    parameter ADDR_W = 21,
    parameter N_SLAVES = 2, //number of slaves
    parameter P_SLAVES = `REQ_W-2 //slave select word msb position
  )
  (
    input                            clk_i,
    input                            arst_i,

    //masters interface
    input [`REQ_W-1:0]               m_req_i,
    output [`RESP_W-1:0]             m_resp_o,

    //slave interface
    output reg [N_SLAVES*`REQ_W-1:0] s_req_o,
    input [N_SLAVES*`RESP_W-1:0]     s_resp_i
    );

  localparam  Nb=$clog2(N_SLAVES)+($clog2(N_SLAVES)==0);


  //slave select word
  wire [Nb-1:0] s_sel;
  assign s_sel = m_req_i[P_SLAVES -:Nb];

  //route master request to selected slave
  always @* begin
      s_req_o = {(`REQ_W*N_SLAVES){1'b0}};
      s_req_o[`REQ(s_sel)] = m_req_i;
  end

  //
  //route response from previously selected slave to master
  //

  //register the slave selection
  reg [Nb-1:0] s_sel_reg;
  always @( posedge clk_i, posedge arst_i ) begin
    if( arst_i )
      s_sel_reg <= {Nb{1'b0}};
    else
      s_sel_reg <= s_sel;
  end

  //route
  assign m_resp_o  = {s_resp_i[`RDATA(s_sel_reg)], s_resp_i[`RVALID(s_sel_reg)], s_resp_i[`READY(s_sel_reg)]};

endmodule
