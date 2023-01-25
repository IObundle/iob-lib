`timescale 1ns / 1ps

`include "iob_lib.vh"

module iob_merge #(
    parameter N_MASTERS = 2,
    parameter DATA_W = 32,
    parameter ADDR_W = 32
    ) (
    input                              clk_i,
    input                              arst_i,
    input                              cke_i,

    //masters interface
    input [N_MASTERS*`REQ_W-1:0]       m_req_i,
    output reg [N_MASTERS*`RESP_W-1:0] m_resp_o,

    //slave interface
    output reg [`REQ_W-1:0]            s_req_o,
    input [`RESP_W-1:0]                s_resp_i
    );

    localparam Nb=$clog2(N_MASTERS)+($clog2(N_MASTERS)==0);

    //Master select word
    reg [Nb-1:0] m_sel;
    integer k;
    always @* begin
        m_sel={Nb{1'b0}};
        for(k=0; k < N_MASTERS; k = k + 1) begin
            if (m_req_i[`avalid(k)]) m_sel = k[Nb-1:0];
        end
    end

    wire sel_reg_en = s_resp_i[`ready(0)];
    reg [Nb-1:0] m_sel_reg;
    iob_reg #(1,0) sel_reg (clk_i, arst_i, cke_i, m_sel, m_sel_reg);

    iob_mux #(`REQ_W,N_MASTERS) req_mux (m_sel_reg, m_req_i, s_req_o);
    iob_demux #(`RESP_W,N_MASTERS) resp_demux (m_sel_reg, s_resp_i, m_resp_o);

   
endmodule
