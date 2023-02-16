`timescale 1ns/1ps
`include "iob_lib.vh"

module iob_fifo_sync
  #(
    parameter
    W_DATA_W = 0,
    R_DATA_W = 0,
    ADDR_W = 0, //higher ADDR_W lower DATA_W
    //determine W_ADDR_W and R_ADDR_W
    MAXDATA_W = `IOB_MAX(W_DATA_W, R_DATA_W),
    MINDATA_W = `IOB_MIN(W_DATA_W, R_DATA_W),
    N = MAXDATA_W/MINDATA_W,
    MINADDR_W = ADDR_W-$clog2(N),//lower ADDR_W (higher DATA_W)
    W_ADDR_W = (W_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W,
    R_ADDR_W = (R_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W
    )
   (
    `IOB_INPUT(clk_i, 1),
    `IOB_INPUT(arst_i, 1),
    `IOB_INPUT(cke_i, 1),

    `IOB_INPUT(rst_i, 1),

    //write port
    `IOB_OUTPUT(ext_mem_w_en_o, N),
    `IOB_OUTPUT(ext_mem_w_addr_o, (MINADDR_W*N)),
    `IOB_OUTPUT(ext_mem_w_data_o, (MINDATA_W*N)),
    //read port
    `IOB_OUTPUT(ext_mem_r_en_o, 1),
    `IOB_OUTPUT(ext_mem_r_addr_o, (MINADDR_W*N)),
    `IOB_INPUT(ext_mem_r_data_i, (MINDATA_W*N)),

    //read port
    `IOB_INPUT(r_en_i, 1),
    `IOB_OUTPUT(r_data_o, R_DATA_W),
    `IOB_OUTPUT(r_empty_o, 1),
    //write port
    `IOB_INPUT(w_en_i, 1),
    `IOB_INPUT(w_data_i, W_DATA_W),
    `IOB_OUTPUT(w_full_o, 1),

    //FIFO level
    `IOB_OUTPUT(level_o, (ADDR_W+1))
    );

   localparam ADDR_W_DIFF = $clog2(N);
   localparam [ADDR_W:0] FIFO_SIZE = (1 << ADDR_W); //in bytes

   //effective write enable
   wire                   w_en_int = (w_en_i & (~w_full_o));

   //write address
   `IOB_WIRE(w_addr, W_ADDR_W)
   iob_counter
     #(
       .DATA_W(W_ADDR_W),
       .RST_VAL({W_ADDR_W{1'd0}})
       )
   w_addr_cnt0
     (
      .clk_i    (clk_i),
      .arst_i   (arst_i),
      .cke_i    (cke_i),

      .rst_i    (rst_i),
      .en_i     (w_en_int),
      .data_o   (w_addr)
      );

   //effective read enable
   wire                   r_en_int  = (r_en_i & (~r_empty_o));

   //read address
   `IOB_WIRE(r_addr, R_ADDR_W)
   iob_counter
     #(
       .DATA_W(R_ADDR_W),
       .RST_VAL({R_ADDR_W{1'd0}})
       )
   r_addr_cnt0
     (
      .clk_i    (clk_i),
      .arst_i   (arst_i),
      .cke_i    (cke_i),

      .rst_i    (rst_i),
      .en_i     (r_en_int),
      .data_o   (r_addr)
      );

   //assign according to assymetry type
   localparam [ADDR_W-1:0] W_INCR = (W_DATA_W > R_DATA_W) ? 1'b1 << ADDR_W_DIFF : 1'b1 ;
   localparam [ADDR_W-1:0] R_INCR = (R_DATA_W > W_DATA_W) ? 1'b1 << ADDR_W_DIFF : 1'b1 ;
   
   //FIFO level
   reg [ADDR_W:0]         level_nxt;
   wire [ADDR_W:0]        level_int;
   iob_reg_r
     #(
       .DATA_W(ADDR_W+1),
       .RST_VAL({(ADDR_W+1){1'd0}})
       )
   level_reg0
     (
      .clk_i  (clk_i),
      .arst_i (arst_i),
      .cke_i  (cke_i),

      .rst_i  (rst_i),

      .data_i (level_nxt),
      .data_o (level_int)
      );

   `IOB_VAR(level_incr, (ADDR_W+1))
   `IOB_COMB begin
      level_incr = level_int + W_INCR;
      level_nxt = level_int;
      if(w_en_int && (!r_en_int))
        level_nxt = level_incr;
      else if(w_en_int && r_en_int)
        level_nxt = level_incr - R_INCR;
      else if (r_en_int) // (!w_en_int) && r_en_int
        level_nxt = level_int - R_INCR;
   end
   
   assign level_o = level_int;

   //FIFO empty
   `IOB_WIRE(r_empty_nxt, 1)
   assign r_empty_nxt = level_nxt < R_INCR;
   iob_reg
     #(
       .DATA_W(1),
       .RST_VAL(1'd1)
       )
   r_empty_reg0
     (
      .clk_i  (clk_i),
      .arst_i (arst_i),
      .cke_i  (cke_i),

      .data_i (r_empty_nxt),
      .data_o (r_empty_o)
      );

   //FIFO full
   `IOB_WIRE(w_full_nxt, 1)
   assign w_full_nxt = level_nxt > (FIFO_SIZE - W_INCR);
   iob_reg
     #(
       .DATA_W(1),
       .RST_VAL(1'd0)
       )
   w_full_reg0
     (
      .clk_i  (clk_i),
      .arst_i (arst_i),
      .cke_i  (cke_i),

      .data_i (w_full_nxt),
      .data_o (w_full_o)
      );

   //FIFO memory
   generate
      if (W_DATA_W > R_DATA_W) begin
         iob_ram_2p_asym_wgtr
           #(
             .W_DATA_W  (W_DATA_W),
             .R_DATA_W  (R_DATA_W),
             .ADDR_W    (ADDR_W)
             )
         iob_ram_2p_asym0
           (
            .clk_i            (clk_i),

            .ext_mem_w_en_o   (ext_mem_w_en_o),
            .ext_mem_w_data_o (ext_mem_w_data_o),
            .ext_mem_w_addr_o (ext_mem_w_addr_o),
            .ext_mem_r_en_o   (ext_mem_r_en_o),
            .ext_mem_r_addr_o (ext_mem_r_addr_o),
            .ext_mem_r_data_i (ext_mem_r_data_i),

            .w_en_i           (w_en_int),
            .w_addr_i         (w_addr),
            .w_data_i         (w_data_i),

            .r_en_i           (r_en_int),
            .r_addr_i         (r_addr),
            .r_data_o         (r_data_o)
            );
      end else begin
         iob_ram_2p_asym_wler
           #(
             .W_DATA_W  (W_DATA_W),
             .R_DATA_W  (R_DATA_W),
             .ADDR_W    (ADDR_W)
             )
         iob_ram_2p_asym0
           (
            .ext_mem_w_en_o   (ext_mem_w_en_o),
            .ext_mem_w_data_o (ext_mem_w_data_o),
            .ext_mem_w_addr_o (ext_mem_w_addr_o),
            .ext_mem_r_en_o   (ext_mem_r_en_o),
            .ext_mem_r_addr_o (ext_mem_r_addr_o),
            .ext_mem_r_data_i (ext_mem_r_data_i),

            .w_en_i           (w_en_int),
            .w_addr_i         (w_addr),
            .w_data_i         (w_data_i),

            .r_en_i           (r_en_int),
            .r_addr_i         (r_addr),
            .r_data_o         (r_data_o)
            );
      end
   endgenerate

endmodule
