`timescale 1ns / 1ps
`include "iob_lib.vh"

//test defines
`define ADDR_W 4
`define TESTSIZE 256 //bytes


module iob_fifo_async_tb;

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


   //global reset
   reg arst = 0;

   //write reset 
   reg                 w_arst = 0;
   `IOB_RESET_SYNC(w_clk, arst, w_arst)

   //read reset 
   reg                 r_arst = 0;
   `IOB_RESET_SYNC(r_clk, arst, r_arst)

   //write clock
   `IOB_CLOCK(w_clk, 10)

   //read clock
   `IOB_CLOCK(r_clk, 13)

   reg                 r_clk_en = 1;
   reg                 w_clk_en = 1;

   
   //write port
   reg                 w_en = 0;
   reg [W_DATA_W-1:0]  w_data;
   wire                w_empty;
   wire                w_full;
   wire [ADDR_W-1:0]   w_level;

   //read port
   reg                 r_en = 0;
   wire [R_DATA_W-1:0] r_data;
   wire                r_empty;
   wire                r_full;
   wire [ADDR_W-1:0]   r_level;

   integer             i,j; //iterators

   reg [TESTSIZE*8-1:0] test_data;
   reg [TESTSIZE*8-1:0] read;

   //
   // WRITE PROCESS
   //

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

      #10 `IOB_PULSE(arst, 50, 50, 50)

      //fill up the FIFO
      @(posedge w_clk) #1;
      for(i=0; i < 2**W_ADDR_W; i=i+1) begin
         w_en = 1;
         w_data = test_data[i*W_DATA_W +: W_DATA_W];
         @(posedge w_clk) #1;
      end
      w_en = 0;

      if(w_full != 1) begin
         $display("ERROR: write proc: w_full=1 expected");
         $finish;
      end

      if(w_level != 0) begin
         $display("ERROR: write proc: expecting w_level = 0, got %d", w_level);
         $finish;
      end

      while (!w_empty) @(posedge w_clk) #1;
      $display("INFO: write proc: w_empty=1 as expected");

      //write test data continuously to the FIFO
      @(posedge w_clk) #1;
      for(i = 0; i < ((TESTSIZE*8)/W_DATA_W); i = i + 1) begin
         while(w_full)  @(posedge w_clk) #1;
         w_en = 1;
         w_data = test_data[i*W_DATA_W +: W_DATA_W];
         @(posedge w_clk) #1;
         w_en = 0;
      end
   end

   //
   // READ PROCESS
   //

   initial begin

      //wait until fifo is full
      while(r_full !== 1'b1) @(posedge r_clk) #1;
      $display("INFO: read proc: r_full = 1 as expected");
      
      //read all data from full FIFO
      @(posedge r_clk) #1;
      for(j = 0; j < 2**R_ADDR_W; j = j + 1) begin
         r_en = 1;
         @(posedge r_clk) #1;
         read[j*R_DATA_W +: R_DATA_W] = r_data;
         r_en = 0;
      end

      if (!r_empty) begin
         $display("ERROR: read proc: r_empty=1 expected");
         $finish;
      end

      if(r_level != 0) begin
         $display("ERROR: read proc: expect r_level=0, got r_level=%d", r_level);
         $finish;
      end

      //read data continuously from the FIFO
      for(j = 0; j < ((TESTSIZE*8)/R_DATA_W); j = j + 1) begin
         while(r_empty) @(posedge r_clk) #1;
         r_en = 1;
         @(posedge r_clk) #1;
         read[j*R_DATA_W +: R_DATA_W] = r_data;
         r_en = 0;
         if(r_data != test_data[j*R_DATA_W +: R_DATA_W])
            $display("ERROR: read proc: expected r_data=%d, got r_data=%d", test_data[j*R_DATA_W +: R_DATA_W], r_data);
      end

      $display("INFO: TEST PASSED");
      #100 $finish;
   end
   
   `IOB_WIRE(ext_mem_w_clk, 1)
   `IOB_WIRE(ext_mem_w_en, 1)
   `IOB_WIRE(ext_mem_w_addr, ADDR_W)
   `IOB_WIRE(ext_mem_w_data, W_DATA_W
   `IOB_WIRE(ext_mem_r_clk, 1)
   `IOB_WIRE(ext_mem_r_en, 1)
   `IOB_WIRE(ext_mem_r_addr, ADDR_W)
   `IOB_WIRE(ext_mem_r_data, R_DATA_W)
   
   // FIFO memory
   iob_ram_t2p_asym
     #(
       .W_DATA_W(W_DATA_W),
       .R_DATA_W(R_DATA_W),
       .ADDR_W(ADDR_W)
       )
   t2p_asym_ram
     (
      .w_clk_i  (ext_mem_w_clk),
      .w_en_i   (ext_mem_w_en),
      .w_data_i (ext_mem_w_data),
      .w_addr_i (ext_mem_w_addr),

      .r_clk_i  (ext_mem_r_clk),
      .r_en_i   (ext_mem_r_en),
      .r_addr_i (ext_mem_r_addr),
      .r_data_o (ext_mem_r_data)
      );

   // Instantiate the Unit Under Test (UUT)
   iob_fifo_async
     #(
       .W_DATA_W(W_DATA_W),
       .R_DATA_W(R_DATA_W),
       .ADDR_W(ADDR_W)
       )
   uut
     (
     //memory write port
     .ext_mem_w_clk_o (ext_mem_w_clk),
     .ext_mem_w_en_o (ext_mem_w_en),
     .ext_mem_w_addr_o (ext_mem_w_addr),
     .ext_mem_w_data_o (ext_mem_w_data),
     //memory read port
     .ext_mem_r_clk_o (ext_mem_r_clk),
     .ext_mem_r_en_o (ext_mem_r_en),
     .ext_mem_r_addr_o (ext_mem_r_addr),
     .ext_mem_r_data_i (ext_mem_r_data),   
     
      .r_clk_i    (r_clk),
      .r_arst_i   (r_arst),
      .r_rst_i    (1'd0),
      .r_clk_en_i (r_clk_en),
      .r_en_i     (r_en),
      .r_data_o   (r_data),
      .r_empty_o  (r_empty),
      .r_full_o   (r_full),
      .r_level_o  (r_level),

      .w_clk_i    (w_clk),
      .w_arst_i   (w_arst),
      .w_rst_i    (1'd0),
      .w_clk_en_i (w_clk_en),
      .w_en_i     (w_en),
      .w_data_i   (w_data),
      .w_empty_o  (w_empty),
      .w_full_o   (w_full),
      .w_level_o  (w_level)
      );

endmodule
