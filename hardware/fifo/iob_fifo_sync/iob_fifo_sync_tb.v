`timescale 1ns / 1ps
`include "iob_lib.vh"

//test defines
`define ADDR_W 4
`define TESTSIZE 256 //bytes


module iob_fifo_sync_tb;

   localparam TESTSIZE = `TESTSIZE; //bytes
   localparam W_DATA_W = `W_DATA_W;
   localparam R_DATA_W = `R_DATA_W;
   localparam MAXDATA_W = `IOB_MAX(W_DATA_W, R_DATA_W);
   localparam MINDATA_W = `IOB_MIN( W_DATA_W, R_DATA_W );
   localparam ADDR_W = `ADDR_W;
   localparam R=MAXDATA_W/MINDATA_W;
   localparam MINADDR_W = ADDR_W-$clog2(R);//lower ADDR_W (higher DATA_W)
   localparam W_ADDR_W = W_DATA_W == MAXDATA_W? MINADDR_W : ADDR_W;
   localparam R_ADDR_W = R_DATA_W == MAXDATA_W? MINADDR_W : ADDR_W;
   localparam N = MAXDATA_W/MINDATA_W;
   
   reg reset = 0;
   reg arst = 0;
   reg                 clk = 0;
   reg                 cke = 1;

   //write port
   reg                 w_en = 0;
   reg [W_DATA_W-1:0]  w_data;
   wire                w_full;

   //read port
   reg                 r_en = 0;
   wire [R_DATA_W-1:0] r_data;
   wire                r_empty;

   //FIFO level
   wire [ADDR_W:0]     level;

   parameter clk_per = 10; // clk period = 10 timeticks
   always
     #(clk_per/2) clk = ~clk;

   integer             i,j; //iterators

   reg [TESTSIZE*8-1:0] test_data;
   reg [TESTSIZE*8-1:0] read;

   //FIFO memory
   wire [N-1:0]		ext_mem_w_en;
   wire [MINDATA_W*N-1:0]	ext_mem_w_data;
   wire [MINADDR_W*N-1:0]	ext_mem_w_addr;
   wire	ext_mem_r_en;
   wire [MINADDR_W*N-1:0]  ext_mem_r_addr;
   wire [MINDATA_W*N-1:0]  ext_mem_r_data;
   
   //
   //WRITE PROCESS
   //
   reg                  w_r_en = 0;//disable reads initially

   initial begin

      if(W_DATA_W > R_DATA_W)
        $display("W_DATA_W > R_DATA_W");
      else if (W_DATA_W < R_DATA_W)
        $display("W_DATA_W < R_DATA_W");
      else
        $display("W_DATA_W = R_DATA_W");

      $display("W_DATA_W=%d", W_DATA_W);
      $display("W_ADDR_W=%d", W_ADDR_W);
      $display("R_DATA_W=%d", R_DATA_W);
      $display("R_ADDR_W=%d", R_ADDR_W);

      //create the test data bytes
      for (i=0; i < TESTSIZE; i=i+1)
        test_data[i*8 +: 8] = i;

      // optional VCD
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif
      repeat(4) @(posedge clk) #1;


      //reset FIFO
      #clk_per;
      @(posedge clk) #1;
      reset = 1;
      arst = 1;
      repeat (4) @(posedge clk) #1;
      reset = 0;
      arst = 0;

      //fill up the FIFO
      for(i = 0; i < 2**W_ADDR_W; i = i + 1) begin
         w_en = 1;
         w_data = test_data[i*W_DATA_W +: W_DATA_W];
         @(posedge clk) #1;
      end
      w_en = 0;

      if(w_full != 1) begin
         $display("ERROR: write proc: expecting w_full=1");
         $finish;
      end
      $display("INFO: write proc: w_full=1 as expected");

      if(level != 2**ADDR_W) begin
        $display("ERROR: write proc: expecting level = %.0f, but got level=%d", 2**ADDR_W, level);
         $finish;
      end
      $display("INFO: write proc: level = %.0f as expected", 2**ADDR_W);

      //enable reads and wait for empty
      w_r_en = 1;
      while (!r_empty) @(posedge clk) #1;
      $display("INFO: write proc: r_empty=1 as expected");

      //write test data continuously to the FIFO
      for(i = 0; i < ((TESTSIZE*8)/W_DATA_W); i = i + 1) begin
         while(w_full)  @(posedge clk) #1;
         w_en = 1;
         w_data = test_data[i*W_DATA_W +: W_DATA_W];
         @(posedge clk) #1;
         w_en = 0;
      end

      $display("INFO: write proc: test data written");
   end

   //
   // READ PROCESS
   //

   initial begin

      //wait for reset to be de-asserted
      @(negedge reset) repeat(4) @(posedge clk) #1;
      while(!w_r_en) @(posedge clk) #1;

      //wait for FIFO full
      while (!w_full)  @(posedge clk) #1;
      $display("INFO: read proc: w_full=1 as expected");

      //read data from the entire FIFO
      for(j = 0; j < 2**R_ADDR_W; j = j + 1) begin
         while(r_empty) @(posedge clk) #1;
         r_en = 1;
         @(posedge clk) #1;
         read[j*R_DATA_W +: R_DATA_W] = r_data;
         r_en = 0;
      end

      while(!r_empty)  @(posedge clk) #1;
      $display("INFO: read proc: r_empty = 1 as expected");

      if(level != 0) begin
         $display("ERROR: read proc: expecting level = 0, but got level=%d", level);
         $finish;
      end
      $display("INFO: read proc: level = 0 as expected");

      //read data continuously from the FIFO
      for(j = 0; j < ((TESTSIZE*8)/R_DATA_W); j = j + 1) begin
         while(r_empty) @(posedge clk) #1;
         r_en = 1;
         @(posedge clk) #1;
         read[j*R_DATA_W +: R_DATA_W] = r_data;
         r_en = 0;
      end

      if(read !== test_data) begin
        $display("ERROR: read proc: data read does not match the test data.");
        $display("read proc: data read XOR test data: %x", read^test_data);
      end
      $display("INFO: read proc: data read matches test data as expected");

      #(5*clk_per) $finish;
   end

   // Instantiate the Unit Under Test (UUT)
   iob_fifo_sync
     #(
       .W_DATA_W(W_DATA_W),
       .R_DATA_W(R_DATA_W),
       .ADDR_W(ADDR_W),
       .N(N)
       )
   uut
     (
      .clk_i            (clk),
      .arst_i           (arst),
      .cke_i            (cke),
      .rst_i            (reset),

      .ext_mem_w_en_o   (ext_mem_w_en),
      .ext_mem_w_addr_o (ext_mem_w_addr),
      .ext_mem_w_data_o (ext_mem_w_data),
      .ext_mem_r_en_o   (ext_mem_r_en),
      .ext_mem_r_addr_o (ext_mem_r_addr),
      .ext_mem_r_data_i (ext_mem_r_data),

      .r_en_i           (r_en),
      .r_data_o         (r_data),
      .r_empty_o        (r_empty),

      .w_en_i           (w_en),
      .w_data_i         (w_data),
      .w_full_o         (w_full),
      .level_o          (level)
      );
   
   genvar p;
   generate for(p = 0;p < N; p = p + 1) begin
      wire mem_w_en;
      wire [MINDATA_W-1:0]	mem_w_data;
      wire [MINADDR_W-1:0]	mem_w_addr;
      wire mem_r_en;
      wire [MINADDR_W-1:0]  mem_r_addr;
      wire [MINDATA_W-1:0]  mem_r_data;
      
      assign mem_w_en = ext_mem_w_en[p];
      assign mem_w_addr = ext_mem_w_addr[p*MINADDR_W +: MINADDR_W];
      assign mem_w_data = ext_mem_w_data[p*MINDATA_W +: MINDATA_W];
      assign mem_r_en = ext_mem_r_en;
      assign mem_r_addr = ext_mem_r_addr[p*MINADDR_W +: MINADDR_W];
      
      iob_ram_2p
      #(
      .DATA_W(MINDATA_W),
      .ADDR_W(MINADDR_W)
      )
      iob_ram_2p_inst
      (
      .clk_i     (clk),
      .w_en_i    (mem_w_en),
      .w_addr_i  (mem_w_addr),
      .w_data_i  (mem_w_data),
      .r_en_i    (mem_r_en),
      .r_addr_i  (mem_r_addr),
      .r_data_o  (mem_r_data)
      );
      
      assign ext_mem_r_data[p*MINDATA_W +: MINDATA_W] = mem_r_data ;
   end endgenerate

endmodule // iob_sync_fifo_asym_tb
