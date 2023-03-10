`timescale 1ns / 1ps

`include "iob_lib.vh"
`include "axi.vh"

`define CLK_PER 10

module axis2axi_tb;

   // Change this parameters between tests to check.
   // 
   parameter ADDR_W = 24;
   parameter DATA_W = 32;
   parameter BURST_W = 3; // Change burst size. A BURST_W of 0 is allowed, the AXI interface sends one value at a time

   // Change this parameters to add a delay, either to the AXI stream or to the AXI connection (0 is valid and will not add any delay)
   parameter DELAY_AXIS_IN = 3;
   parameter DELAY_AXIS_OUT = 3;
   parameter DELAY_AXI_READ = 5;
   parameter DELAY_AXI_WRITE = 5;

   // Do not change these
   localparam AXI_ADDR_W = ADDR_W;
   localparam AXI_DATA_W = DATA_W;

   // Clock
   reg clk = 1;
   always #(`CLK_PER/2) clk = ~clk;

   // Reset
   reg rst = 0;

   // Control I/F
   reg [ADDR_W-1:0] addr_in;
   reg set_in_config;
   reg [ADDR_W-1:0] addr_out;
   reg [ADDR_W-1:0] out_length;
   reg set_out_config;

   // AXI Stream in
   reg [DATA_W-1:0] axis_in_data;
   reg axis_in_valid;
   wire axis_in_ready;

   // AXI Stream out
   wire [DATA_W-1:0] axis_out_data;
   wire non_delayed_axis_out_valid;
   wire non_delayed_axis_out_ready;

   wire delayed_axis_out_valid;
   reg delayed_axis_out_ready;

   // AXI-4 full master I/F
   `IOB_WIRE(ddr_axi_awid, 1) //Address write channel ID
   `IOB_WIRE(ddr_axi_awaddr, AXI_ADDR_W) //Address write channel address
   `IOB_WIRE(ddr_axi_awlen, 8) //Address write channel burst length
   `IOB_WIRE(ddr_axi_awsize, 3) //Address write channel burst size. This signal indicates the size of each transfer in the burst
   `IOB_WIRE(ddr_axi_awburst, 2) //Address write channel burst type
   `IOB_WIRE(ddr_axi_awlock, 1) //Address write channel lock type
   `IOB_WIRE(ddr_axi_awcache, 4) //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
   `IOB_WIRE(ddr_axi_awprot, 3) //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
   `IOB_WIRE(ddr_axi_awqos, 4) //Address write channel quality of service
   `IOB_WIRE(ddr_axi_awvalid, 1) //Address write channel valid
   `IOB_WIRE(ddr_axi_awready, 1) //Address write channel ready
   `IOB_WIRE(ddr_axi_wid, 1) //Write channel ID
   `IOB_WIRE(ddr_axi_wdata, AXI_DATA_W) //Write channel data
   `IOB_WIRE(ddr_axi_wstrb, (AXI_DATA_W/8)) //Write channel write strobe
   `IOB_WIRE(ddr_axi_wlast, 1) //Write channel last word flag
   `IOB_WIRE(ddr_axi_bid, 1) //Write response channel ID
   `IOB_WIRE(ddr_axi_bresp, 2) //Write response channel response
   `IOB_WIRE(ddr_axi_bvalid, 1) //Write response channel valid
   `IOB_WIRE(ddr_axi_bready, 1) //Write response channel ready
   `IOB_WIRE(ddr_axi_arid, 1) //Address read channel ID
   `IOB_WIRE(ddr_axi_araddr, AXI_ADDR_W) //Address read channel address
   `IOB_WIRE(ddr_axi_arlen, 8) //Address read channel burst length
   `IOB_WIRE(ddr_axi_arsize, 3) //Address read channel burst size. This signal indicates the size of each transfer in the burst
   `IOB_WIRE(ddr_axi_arburst, 2) //Address read channel burst type
   `IOB_WIRE(ddr_axi_arlock, 1) //Address read channel lock type
   `IOB_WIRE(ddr_axi_arcache, 4) //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
   `IOB_WIRE(ddr_axi_arprot, 3) //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
   `IOB_WIRE(ddr_axi_arqos, 4) //Address read channel quality of service
   `IOB_WIRE(ddr_axi_arvalid, 1) //Address read channel valid
   `IOB_WIRE(ddr_axi_arready, 1) //Address read channel ready
   `IOB_WIRE(ddr_axi_rid, 1) //Read channel ID
   `IOB_WIRE(ddr_axi_rdata, AXI_DATA_W) //Read channel data
   `IOB_WIRE(ddr_axi_rresp, 2) //Read channel response
   `IOB_WIRE(ddr_axi_rlast, 1) //Read channel last word

   // Iterators
   integer            i, seq_ini;

   initial begin

`ifdef VCD
   $dumpfile("uut.vcd");
   $dumpvars();
`endif

   //
   // Init signals
   //
   addr_in = 0;
   set_in_config = 0;
   axis_in_data = 0;
   axis_in_valid = 0;
   delayed_axis_out_ready = 0;
   addr_out = 0;
   out_length = 0;
   set_out_config = 0;

   // Assert reset
   #100 rst = 1;

   // Deassert rst
   repeat (10) @(posedge clk) #1;
   rst = 0;

   // Wait an arbitray (10) number of cycles
   repeat (10) @(posedge clk) #1;

   // Axi In Tests
   $display("=== AXI Stream In ===");
   AxiStreamInRun(16'h0000,0,4);
   AxiStreamInRun(16'h0100,0,16);
   AxiStreamInRun(16'h0ffc,0,1);
   AxiStreamInRun(16'h1ffc,0,2);
   AxiStreamInRun(16'h2ffc,0,10);
   AxiStreamInRun(16'h3fd8,0,40);

   repeat (100) @(posedge clk) #1;
   // Axi Out Tests
   $display("=== AXI Stream Out ===");
   AxiStreamOutRun(16'h0000,4);
   AxiStreamOutRun(16'h0100,16);
   AxiStreamOutRun(16'h0ffc,1);
   AxiStreamOutRun(16'h1ffc,2);
   AxiStreamOutRun(16'h2ffc,10);
   AxiStreamOutRun(16'h3fd8,40);

   repeat (100) @(posedge clk) #1;

   $finish;
end

task AxiStreamInRun(input[31:0] address, startValue,runLength);
begin
   $display("Making an AXI Stream In run from %h to %h",address,address + runLength  * 4);
   
   addr_in = address;
   set_in_config = 1;

   @(posedge clk) #1;

   set_in_config = 0;

   @(posedge clk) #1;

   axis_in_valid = 1;
   axis_in_data = startValue;
   for(i = 0; i < runLength; i = i + 1) begin
      while(!axis_in_ready) @(posedge clk) #1;
      
      @(posedge clk) #1;
      axis_in_data = axis_in_data + 1;
   end
   axis_in_valid = 0;

   repeat(100) @(posedge clk) #1;
   $display("");
end
endtask

task AxiStreamOutRun(input[31:0] address,runLength);
begin
   $display("Making an AXI Stream Out run from %h to %h",address,address + runLength * 4);
   
   addr_out = address;
   out_length = runLength;
   set_out_config = 1;

   @(posedge clk) #1;

   set_out_config = 0;

   @(posedge clk) #1;

   delayed_axis_out_ready = 1;
   $write("Values read:");
   for(i = 0; i < runLength; i = i + 1) begin
      while(!delayed_axis_out_valid) @(posedge clk) #1;
      
      $write(" %02d",axis_out_data);

      @(posedge clk) #1;
   end

   repeat(100) @(posedge clk) #1;
   $display("\n");
end
endtask

// Detect writes and store them for display
reg [4:0] writeCounter;
reg [31:0] writtenData[7:0];
reg [23:0] writtenAddr;
integer writeCounterIndex;
always @(posedge clk)
begin
   if(ddr_axi_awvalid && ddr_axi_awready) begin
      writeCounter = 0;
      writtenAddr = ddr_axi_awaddr;
   end

   if(s_wvalid && s_wready) begin
      writtenData[writeCounter] = ddr_axi_wdata;
      writeCounter = writeCounter + 1;
      if(ddr_axi_wlast) begin
         $write("Written to address %h:",ddr_axi_awaddr);
         for(writeCounterIndex = 0;writeCounterIndex < writeCounter;writeCounterIndex = writeCounterIndex+1) begin
            $write(" %02d",writtenData[writeCounterIndex]);
         end
         writeCounter = 0;
         $display("");
      end
   end
end

// External memory instantiation
wire ext_mem_w_en,ext_mem_r_en;
wire [31:0] ext_mem_w_data,ext_mem_r_data;
wire [BURST_W:0] ext_mem_w_addr,ext_mem_r_addr; 

   iob_ram_t2p #(
      .DATA_W(32),
      .ADDR_W(BURST_W + 1)
   ) memory (
      .w_clk_i(clk),
      .w_en_i(ext_mem_w_en),
      .w_addr_i(ext_mem_w_addr),
      .w_data_i(ext_mem_w_data),

      .r_clk_i(clk),
      .r_en_i(ext_mem_r_en),
      .r_addr_i(ext_mem_r_addr),
      .r_data_o(ext_mem_r_data)
   );

// Insert delays between AXI like handshake interfaces
wire m_rvalid,m_rready,s_rvalid,s_rready;
AxiDelayRead #(
   .MAX_DELAY(DELAY_AXI_READ)
) delayRead (
   // Connect directly to the same named axi read wires in the master interface
   .m_rvalid(m_rvalid),
   .m_rready(m_rready),

   // Connect directly to the same named axi read wires in the slave interface
   .s_rvalid(s_rvalid),
   .s_rready(s_rready),

   .clk(clk),
   .rst(rst)
);

wire m_wvalid,m_wready,s_wvalid,s_wready;
AxiDelayWrite #(
   .MAX_DELAY(DELAY_AXI_WRITE)
) delayWrite (
   // Connect directly to the same named axi write wires in the master interface
   .m_wvalid(m_wvalid),
   .m_wready(m_wready),

   // Connect directly to the same named axi write wires in the slave interface
   .s_wvalid(s_wvalid),
   .s_wready(s_wready),

   .clk(clk),
   .rst(rst)
);

wire delayed_axis_in_valid,delayed_axis_in_ready;
AxiDelay #(
   .MAX_DELAY(DELAY_AXIS_IN)
) delayIn (
   // Master interface. Connect to a slave interface
   .m_valid(delayed_axis_in_valid),
   .m_ready(delayed_axis_in_ready),

   // Slave interface. Connect to a master interface
   .s_valid(axis_in_valid),
   .s_ready(axis_in_ready),

   .clk(clk),
   .rst(rst)
);

AxiDelay #(
   .MAX_DELAY(DELAY_AXIS_OUT)
) delayOut (
   // Master interface. Connect to a slave interface
   .m_valid(delayed_axis_out_valid),
   .m_ready(delayed_axis_out_ready),

   // Slave interface. Connect to a master interface
   .s_valid(non_delayed_axis_out_valid),
   .s_ready(non_delayed_axis_out_ready),

   .clk(clk),
   .rst(rst)
);

   axis2axi
   #(
      .AXI_ADDR_W(ADDR_W),
      .AXI_DATA_W(DATA_W),
      .BURST_W(BURST_W)
   )
   uut
   (
   // Memory interface
   .ext_mem_w_en_o(ext_mem_w_en),
   .ext_mem_w_data_o(ext_mem_w_data),
   .ext_mem_w_addr_o(ext_mem_w_addr),
   .ext_mem_r_en_o(ext_mem_r_en),
   .ext_mem_r_addr_o(ext_mem_r_addr),
   .ext_mem_r_data_i(ext_mem_r_data),

   //
   // Control I/F
   //
   .addr_in_i(addr_in),
   .set_in_config_i(set_in_config),
   .addr_out_i(addr_out),
   .out_length_i(out_length),
   .set_out_config_i(set_out_config),

   // AXI Stream In
   .axis_in_data_i(axis_in_data),
   .axis_in_valid_i(delayed_axis_in_valid),
   .axis_in_ready_o(delayed_axis_in_ready),

   // AXI Stream Out
   .axis_out_data_o(axis_out_data),
   .axis_out_valid_o(non_delayed_axis_out_valid),
   .axis_out_ready_i(non_delayed_axis_out_ready),

   //
   // AXI-4 full master I/F
   //
   .m_axi_awid(ddr_axi_awid), //Address write channel ID
   .m_axi_awaddr(ddr_axi_awaddr), //Address write channel address
   .m_axi_awlen(ddr_axi_awlen), //Address write channel burst length
   .m_axi_awsize(ddr_axi_awsize), //Address write channel burst size. This signal indicates the size of each transfer in the burst
   .m_axi_awburst(ddr_axi_awburst), //Address write channel burst type
   .m_axi_awlock(ddr_axi_awlock), //Address write channel lock type
   .m_axi_awcache(ddr_axi_awcache), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
   .m_axi_awprot(ddr_axi_awprot), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
   .m_axi_awqos(ddr_axi_awqos), //Address write channel quality of service
   .m_axi_awvalid(ddr_axi_awvalid), //Address write channel valid
   .m_axi_awready(ddr_axi_awready), //Address write channel ready
   .m_axi_wid(ddr_axi_wid), //Write channel ID
   .m_axi_wdata(ddr_axi_wdata), //Write channel data
   .m_axi_wstrb(ddr_axi_wstrb), //Write channel write strobe
   .m_axi_wlast(ddr_axi_wlast), //Write channel last word flag
   .m_axi_wvalid(m_wvalid), //Write channel valid
   .m_axi_wready(m_wready), //Write channel ready
   .m_axi_bid(ddr_axi_bid), //Write response channel ID
   .m_axi_bresp(ddr_axi_bresp), //Write response channel response
   .m_axi_bvalid(ddr_axi_bvalid), //Write response channel valid
   .m_axi_bready(ddr_axi_bready), //Write response channel ready
   .m_axi_arid(ddr_axi_arid), //Address read channel ID
   .m_axi_araddr(ddr_axi_araddr), //Address read channel address
   .m_axi_arlen(ddr_axi_arlen), //Address read channel burst length
   .m_axi_arsize(ddr_axi_arsize), //Address read channel burst size. This signal indicates the size of each transfer in the burst
   .m_axi_arburst(ddr_axi_arburst), //Address read channel burst type
   .m_axi_arlock(ddr_axi_arlock), //Address read channel lock type
   .m_axi_arcache(ddr_axi_arcache), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
   .m_axi_arprot(ddr_axi_arprot), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
   .m_axi_arqos(ddr_axi_arqos), //Address read channel quality of service
   .m_axi_arvalid(ddr_axi_arvalid), //Address read channel valid
   .m_axi_arready(ddr_axi_arready), //Address read channel ready
   .m_axi_rid(ddr_axi_rid), //Read channel ID
   .m_axi_rdata(ddr_axi_rdata), //Read channel data
   .m_axi_rresp(ddr_axi_rresp), //Read channel response
   .m_axi_rlast(ddr_axi_rlast), //Read channel last word
   .m_axi_rvalid(m_rvalid), //Read channel valid
   .m_axi_rready(m_rready), //Read channel ready

   .clk_i       (clk),
   .cke_i       (1'b1),
   .rst_i       (rst)
   );

   axi_ram
    #(
      .ID_WIDTH   (1),
      .DATA_WIDTH (AXI_DATA_W),
      .ADDR_WIDTH (AXI_ADDR_W)
      )
   axi_ram0
    (
     .clk_i            (clk),
     .rst_i            (rst),

     //
     // AXI-4 full master interface
     //

     // Address write
     .axi_awid_i     (ddr_axi_awid),
     .axi_awaddr_i   (ddr_axi_awaddr),
     .axi_awlen_i    (ddr_axi_awlen),
     .axi_awsize_i   (ddr_axi_awsize),
     .axi_awburst_i  (ddr_axi_awburst),
     .axi_awlock_i   ({1'b1,ddr_axi_awlock}),
     .axi_awprot_i   (ddr_axi_awprot),
     .axi_awcache_i  (ddr_axi_awcache),
     .axi_awvalid_i  (ddr_axi_awvalid),
     .axi_awready_o  (ddr_axi_awready),

     // Write
     .axi_wvalid_i   (s_wvalid),
     .axi_wdata_i    (ddr_axi_wdata),
     .axi_wstrb_i    (ddr_axi_wstrb),
     .axi_wlast_i    (ddr_axi_wlast),
     .axi_wready_o   (s_wready),

     // Write response
     .axi_bid_o      (ddr_axi_bid),
     .axi_bvalid_o   (ddr_axi_bvalid),
     .axi_bresp_o    (ddr_axi_bresp),
     .axi_bready_i   (ddr_axi_bready),

     // Address read
     .axi_arid_i     (ddr_axi_arid),
     .axi_araddr_i   (ddr_axi_araddr),
     .axi_arlen_i    (ddr_axi_arlen),
     .axi_arsize_i   (ddr_axi_arsize),
     .axi_arburst_i  (ddr_axi_arburst),
     .axi_arlock_i   ({1'b1,ddr_axi_arlock}),
     .axi_arcache_i  (ddr_axi_arcache),
     .axi_arprot_i   (ddr_axi_arprot),
     .axi_arvalid_i  (ddr_axi_arvalid),
     .axi_arready_o  (ddr_axi_arready),

     // Read
     .axi_rid_o      (ddr_axi_rid),
     .axi_rvalid_o   (s_rvalid),
     .axi_rdata_o    (ddr_axi_rdata),
     .axi_rlast_o    (ddr_axi_rlast),
     .axi_rresp_o    (ddr_axi_rresp),
     .axi_rready_i   (s_rready)
     );

endmodule
