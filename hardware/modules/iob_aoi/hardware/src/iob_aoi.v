`timescale 1ns / 1ps

module iob_aoi(
	input a,
	input b,
	input c,
	input d,
	output y
);

	wire aad, cad;

	assign aad = a & d;
	assign cad = c & d;

	assign y = ~(aad | cad);

endmodule
