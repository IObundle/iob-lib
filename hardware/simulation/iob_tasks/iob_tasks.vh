//
// Tasks for the IOb Native protocol
//

// Write data to IOb Native slave
task iob_write;
   input [ADDR_W-1:0]       iob_addr_task;
   input [DATA_W-1:0]       iob_data_task;
   input [$clog2(DATA_W):0] iob_width_task;

   begin
      iob_valid_i = 1;
      iob_addr_i  = `IOB_WORD_ADDR(iob_addr_task);
      iob_wdata_i = `IOB_GET_WDATA(iob_addr_task, iob_data_task);
      iob_wstrb_i = `IOB_GET_WSTRB(iob_addr_task, iob_width_task);

      while (!iob_ready_o) @(posedge clk) #1;

      @(posedge clk) iob_valid_i = 0;
   end
endtask

// Read data from IOb Native slave
task iob_read;
   input [ADDR_W-1:0]       iob_addr_task;
   output [DATA_W-1:0]      iob_data_task;
   input [$clog2(DATA_W):0] iob_width_task;

   begin
      iob_valid_i = 1;
      iob_addr_i  = `IOB_WORD_ADDR(iob_addr_task);
      iob_wstrb_i = 0;

      @(posedge clk) #1;
      while (!iob_ready_o) @(posedge clk) #1;
      @(posedge clk) iob_valid_i = #1 0;

      while (!iob_rvalid_o) #1;
      iob_data_task = #1 `IOB_GET_RDATA(iob_addr_task, iob_rdata_o, iob_width_task);
   end
endtask
