   //address write
   `INPUT(s_axil_awid,    `AXI_ID_W),     //Address write channel ID
   `INPUT(s_axil_awaddr,   AXIL_ADDR_W),  //Address write channel address
   `INPUT(s_axil_awprot,  `AXI_PROT_W),   //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
   `INPUT(s_axil_awqos,   `AXI_QOS_W),    //Address write channel quality of service
   `INPUT(s_axil_awvalid,  1),            //Address write channel valid
   `OUTPUT(s_axil_awready, 1),            //Address write channel ready

   //write
   `INPUT(s_axil_wid,     `AXI_ID_W),     //Write channel ID
   `INPUT(s_axil_wdata,    AXIL_DATA_W),  //Write channel data
   `INPUT(s_axil_wstrb,    AXIL_DATA_W/8),//Write channel write strobe
   `INPUT(s_axil_wvalid,   1),            //Write channel valid
   `OUTPUT(s_axil_wready,  1),            //Write channel ready

   //write response
   `OUTPUT(s_axil_bid,    `AXI_ID_W),     //Write response channel ID
   `OUTPUT(s_axil_bresp,  `AXI_RESP_W),   //Write response channel response
   `OUTPUT(s_axil_bvalid,  1),            //Write response channel valid
   `INPUT(s_axil_bready,   1),            //Write response channel ready
  
   //address read
   `INPUT(s_axil_arid,    `AXI_ID_W),     //Address read channel ID
   `INPUT(s_axil_araddr,   AXIL_ADDR_W),  //Address read channel address
   `INPUT(s_axil_arprot,  `AXI_PROT_W),   //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
   `INPUT(s_axil_arqos,   `AXI_QOS_W),    //Address read channel quality of service
   `INPUT(s_axil_arvalid,  1),            //Address read channel valid
   `OUTPUT(s_axil_arready, 1),            //Address read channel ready

   //read
   `OUTPUT(s_axil_rid,    `AXI_ID_W),     //Read channel ID
   `OUTPUT(s_axil_rdata,   AXIL_DATA_W),  //Read channel data
   `OUTPUT(s_axil_rresp,  `AXI_RESP_W),   //Read channel response
   `OUTPUT(s_axil_rvalid,  1),            //Read channel valid
   `INPUT(s_axil_rready,   1),            //Read channel ready
