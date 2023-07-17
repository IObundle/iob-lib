`timescale 1ns / 1ps

module iob_aoi
#(
	parameter W = 21
) (
	input [W-1:0] a_i,
	input [W-1:0] b_i,
	input [W-1:0] c_i,
	input [W-1:0] d_i,
	output [W-1:0] y_o
);

	wire [W-1:0] aab_vec;
	wire [W-1:0] cad_vec;

	genvar i;

	generate 
		for (i = 0; i < W; i = i + 1) begin : and_gen
			assign aab_vec[i] = a_i[i] & b_i[i];
			assign cad_vec[i] = c_i[i] & d_i[i];
			addign y_o[i] = ~(aab_vec[i] | cad_vec[i]);
		end 
	endgenerate

endmodule
