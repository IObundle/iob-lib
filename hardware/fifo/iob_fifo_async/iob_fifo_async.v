`timescale 1ns/1ps

`include "iob_lib.vh"

module iob_fifo_async
  #(parameter
    W_DATA_W = 0,
    R_DATA_W = 0,
    ADDR_W = 0 //higher ADDR_W lower DATA_W
    )
   (
    
    //read port
    input                 r_clk_i,
    input                 r_arst_i,
    input                 r_rst_i,
    input                 r_clk_en_i,
    input                 r_en_i,
    output [R_DATA_W-1:0] r_data_o,
    output                r_empty_o,
    output                r_full_o,
    output [ADDR_W-1:0]   r_level_o,

    //write port
    input                 w_clk_i,
    input                 w_arst_i,
    input                 w_rst_i,
    input                 w_clk_en_i,
    input                 w_en_i,
    input [W_DATA_W-1:0]  w_data_i,
    output                w_empty_o,
    output                w_full_o,
    output [ADDR_W-1:0]   w_level_o

    );

    //determine W_ADDR_W and R_ADDR_W
   localparam MAXDATA_W = `IOB_MAX(W_DATA_W, R_DATA_W);
   localparam MINDATA_W = `IOB_MIN(W_DATA_W, R_DATA_W);
   localparam R = MAXDATA_W/MINDATA_W;
   localparam ADDR_W_DIFF = $clog2(R);
   localparam MINADDR_W = ADDR_W-$clog2(R);//lower ADDR_W (higher DATA_W)
   localparam W_ADDR_W = (W_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W;
   localparam R_ADDR_W = (R_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W;
   localparam FIFO_SIZE = 1'b1 << ADDR_W; //in bytes

   //read/write increments
   wire [ADDR_W-1:0]          r_incr;
   wire [ADDR_W-1:0]          w_incr;

   //binary read addresses on both domains
   wire [R_ADDR_W:0]        r_raddr_bin;
   wire [R_ADDR_W:0]        w_raddr_bin;
   wire [W_ADDR_W:0]        r_waddr_bin;
   wire [W_ADDR_W:0]        w_waddr_bin;

   //normalized binary addresses (for narrower data side)
   wire [ADDR_W:0]          r_raddr_bin_n;
   wire [ADDR_W:0]          r_waddr_bin_n;
   wire [ADDR_W:0]          w_waddr_bin_n;
   wire [ADDR_W:0]          w_raddr_bin_n;

   //assign according to assymetry type
   generate
      if (W_DATA_W > R_DATA_W) begin
         assign r_incr = 1'b1;
         assign w_incr = 1'b1 << ADDR_W_DIFF;
         assign w_waddr_bin_n = w_waddr_bin<<ADDR_W_DIFF;
         assign w_raddr_bin_n = w_raddr_bin;
         assign r_raddr_bin_n = r_raddr_bin;
         assign r_waddr_bin_n = r_waddr_bin<<ADDR_W_DIFF;
      end else if (R_DATA_W > W_DATA_W) begin
         assign w_incr = 1'b1;
         assign r_incr = 1'b1 << ADDR_W_DIFF;
         assign w_waddr_bin_n = w_waddr_bin;
         assign w_raddr_bin_n = w_raddr_bin<<ADDR_W_DIFF;
         assign r_raddr_bin_n = r_raddr_bin<<ADDR_W_DIFF;
         assign r_waddr_bin_n = r_waddr_bin;
      end else begin
         assign r_incr = 1'b1;
         assign w_incr = 1'b1;
         assign w_raddr_bin_n = w_raddr_bin;
         assign w_waddr_bin_n = w_waddr_bin;
         assign r_waddr_bin_n = r_waddr_bin;
         assign r_raddr_bin_n = r_raddr_bin;
      end
   endgenerate


   //sync write gray address to read domain
   wire [W_ADDR_W:0]        w_waddr_gray;
   wire [W_ADDR_W:0]        r_waddr_gray;
   iob_sync
     #(
       .DATA_W(W_ADDR_W+1),
       .RST_VAL(0)
       )
   w_waddr_gray_sync0
     (
      .clk_i    (r_clk_i),
      .arst_i   (r_arst_i),
      .signal_i (w_waddr_gray),
      .signal_o (r_waddr_gray)
      );

   //sync read gray address to write domain
   wire [R_ADDR_W:0]        r_raddr_gray;
   wire [R_ADDR_W:0]        w_raddr_gray;
   iob_sync
     #(
       .DATA_W(R_ADDR_W+1),
       .RST_VAL(0)
       )
   r_raddr_gray_sync0
     (
      .clk_i    (w_clk_i),
      .arst_i   (w_arst_i),
      .signal_i (r_raddr_gray),
      .signal_o (w_raddr_gray)
      );


   //READ DOMAIN FIFO LEVEL
   `IOB_WIRE(r_level_int, (ADDR_W+2))
   assign r_level_int = r_waddr_bin_n - r_raddr_bin_n;
   assign r_level_o = r_level_int[ADDR_W-1:0];
   
   //READ DOMAIN EMPTY AND FULL FLAGS
   assign r_empty_o = (r_level_int < r_incr);
   `IOB_WIRE(r_full_limit, (ADDR_W+2))
   assign r_full_limit = FIFO_SIZE-r_incr;
   assign r_full_o = (r_level_int > r_full_limit);

   //WRITE DOMAIN FIFO LEVEL
   `IOB_WIRE(w_level_int, (ADDR_W+2))
   assign w_level_int = w_waddr_bin_n - w_raddr_bin_n;
   assign w_level_o = w_level_int[ADDR_W-1:0];
 
   //WRITE DOMAIN EMPTY AND FULL FLAGS
   assign w_empty_o = (w_level_int < w_incr);
   `IOB_WIRE(w_full_limit, (ADDR_W+2))
   assign w_full_limit = FIFO_SIZE-w_incr;
   assign w_full_o = (w_level_int > w_full_limit);

   
   //read address gray code counter
   wire r_en_int  = (r_en_i & (~r_empty_o)) & r_clk_en_i;
   iob_gray_counter
     #(
       .W(R_ADDR_W+1)
       )
   r_raddr_gray_counter
     (
      .clk_i  (r_clk_i),
      .arst_i (r_arst_i),
      .rst_i  (r_rst_i),
      .en_i   (r_en_int),
      .data_o (r_raddr_gray)
      );

   //write address gray code counter
   wire w_en_int = (w_en_i & (~w_full_o)) & w_clk_en_i;
   iob_gray_counter
     #(
       .W(W_ADDR_W+1)
       )
   w_waddr_gray_counter
     (
      .clk_i  (w_clk_i),
      .arst_i (w_arst_i),
      .rst_i  (w_rst_i),
      .en_i   (w_en_int),
      .data_o (w_waddr_gray)
      );

   //convert gray read address to binary
   iob_gray2bin
     #(
       .DATA_W(R_ADDR_W+1)
       )
   gray2bin_r_raddr
     (
      .gr_i  (r_raddr_gray),
      .bin_o (r_raddr_bin)
      );

   //convert synced gray write address to binary
   iob_gray2bin
     #(
       .DATA_W(W_ADDR_W+1)
       )
   gray2bin_r_raddr_sync
     (
      .gr_i  (r_waddr_gray),
      .bin_o (r_waddr_bin)
      );

   //convert gray write address to binary
   iob_gray2bin
     #(
       .DATA_W(W_ADDR_W+1)
       )
   gray2bin_w_waddr
     (
      .gr_i  (w_waddr_gray),
      .bin_o (w_waddr_bin)
      );

   //convert synced gray read address to binary
   iob_gray2bin
     #(
       .DATA_W(R_ADDR_W+1)
       )
   gray2bin_w_raddr_sync
     (
      .gr_i  (w_raddr_gray),
      .bin_o (w_raddr_bin)
      );

   // FIFO memory
   iob_ram_t2p_asym
     #(
       .W_DATA_W(W_DATA_W),
       .R_DATA_W(R_DATA_W),
       .ADDR_W(ADDR_W)
       )
   t2p_asym_ram
     (
      .w_clk_i  (w_clk_i),
      .w_en_i   (w_en_int),
      .w_data_i (w_data_i),
      .w_addr_i (w_waddr_bin[W_ADDR_W-1:0]),

      .r_clk_i  (r_clk_i),
      .r_en_i   (r_en_int),
      .r_addr_i (r_raddr_bin[R_ADDR_W-1:0]),
      .r_data_o (r_data_o)
      );

endmodule
