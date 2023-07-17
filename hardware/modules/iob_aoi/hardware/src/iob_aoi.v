`timescale 1ns / 1ps

module iob_aoi
#(
	parameter W = 1
	parameter N = 2
) (
	input a_i,
	input b_i,
	input c_i,
	input d_i,
	output y_o
);

	wire aab;
	wire cad;
	wire or_out;

	iob_and #(
		.W(W)
		.N(N)
	) iob_and_ab (
		.in_i({a_i,b_i}),
		.out_o(aab)
	);

	iob_and #(
		.W(W)
		.N(N)
	) iob_and_cd (
		.in_i({c_i,d_i}),
		.out_o(cad)
	);

	iob_or #(
		.W(W)
		.N(N)
	) iob_or_abcd (
		.in_i({aab,cad}),
		.out_o(or_out)
	);

	assign y_o = !or_out;

endmodule
