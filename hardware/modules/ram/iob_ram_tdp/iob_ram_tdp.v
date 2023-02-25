`timescale 1 ns / 1 ps

module iob_ram_tdp
  #(
    parameter HEXFILE = "none",
    parameter DATA_W = 0,
    parameter ADDR_W = 0
    )
   (
    // Port A
    input                     clkA_i,
    input [(DATA_W-1):0]      dA_i,
    input [(ADDR_W-1):0]      addrA_i,
    input                     enA_i,
    input                     weA_i,
    output reg [(DATA_W-1):0] dA_o,

    // Port B
    input                     clkB_i,
    input [(DATA_W-1):0]      dB_i,
    input [(ADDR_W-1):0]      addrB_i,
    input                     enB_i,
    input                     weB_i,
    output reg [(DATA_W-1):0] dB_o
    );

   //this allows ISE 14.7 to work; do not remove
   localparam mem_init_file_int = HEXFILE;

   // Declare the RAM
   reg [DATA_W-1:0]           ram[2**ADDR_W-1:0];

   // Initialize the RAM
   initial
     if(mem_init_file_int != "none")
       $readmemh(mem_init_file_int, ram, 0, 2**ADDR_W - 1);

   //read port
   always @ (posedge clkA_i) begin// Port A
      if (enA_i)
        if (weA_i)
	        ram[addrA_i] <= dA_i;
      `ifdef IOB_MEM_NO_READ_ON_WRITE
        else
      `endif
      dA_o <= ram[addrA_i];
    end

   //write port
   always @ (posedge clkB_i) begin // Port B
      if (enB_i)
        if (weB_i)
	        ram[addrB_i] <= dB_i;
      `ifdef IOB_MEM_NO_READ_ON_WRITE
        else
      `endif
	    dB_o <= ram[addrB_i];
    end
 endmodule
