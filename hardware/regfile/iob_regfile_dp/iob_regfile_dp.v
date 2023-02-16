`timescale 1 ns / 1 ps

module iob_regfile_dp
  #(
    parameter ADDR_W = 2,
    parameter DATA_W = 21
  )
  (
    input                clk_i,
    input                arst_i,
    input                cke_i,
    input                rst_i,

    // Port A
    input                a_wen_i,
    input [ADDR_W-1:0]   a_addr_i,
    input [DATA_W-1:0]   a_wdata_i,
    output [DATA_W-1 :0] a_rdata_o,

    // Port B
    input                b_wen_i,
    input [ADDR_W-1:0]   b_addr_i,
    input [DATA_W-1:0]   b_wdata_i,
    output [DATA_W-1 :0] b_rdata_o
  );

  reg [DATA_W-1:0]      reg_file [(2**ADDR_W)-1:0];

  wire [ADDR_W-1:0]     addr = a_wen_i? a_addr_i : b_addr_i;
  wire [DATA_W-1:0]     wdata = a_wen_i? a_wdata_i : b_wdata_i;
  wire                  wen = a_wen_i? a_wen_i : b_wen_i;

  //read
  assign a_rdata_o = reg_file[a_addr_i];
  assign b_rdata_o = reg_file[b_addr_i];

  //write
  genvar                pos;
  generate
    for (pos=0; pos < (2**ADDR_W); pos=pos+1) begin: register_file
      wire [ADDR_W-1:0] wire_pos = pos;
      always @(posedge clk_i, posedge arst_i)
        if (arst_i)
          reg_file[pos] <= {DATA_W{1'b0}};
        else if (cke_i) begin
          if (rst_i)
            reg_file[pos] <= {DATA_W{1'b0}};
          else if (wen && (addr == wire_pos))
            reg_file[pos] <= wdata;
        end
    end
  endgenerate

endmodule
