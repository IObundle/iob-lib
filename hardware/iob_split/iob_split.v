`timescale 1ns / 1ps

`include "iob_lib.vh"

module iob_split #(
    parameter DATA_W = 32,
    parameter ADDR_W = 32,
    parameter N_SLAVES = 2, //number of slaves
    parameter P_SLAVES = `REQ_W-2 //slave select word msb position
    ) (
    input                            clk_i,
    input                            arst_i,
    input                            cke_i,

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

    wire sel_reg_en = s_resp_i[`ready(0)];
    reg [Nb-1:0] s_sel_reg;
    iob_reg #(1,0) sel_reg (clk_i, arst_i, cke_i, s_sel, s_sel_reg);

    iob_demux #(`REQ_W,N_SLAVES) req_demux (s_sel_reg, m_req_i, s_req_o);
    iob_mux #(`RESP_W,N_SLAVES) resp_mux (s_sel_reg, s_resp_i, m_resp_o);

endmodule
