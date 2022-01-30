	       //CPU native interface
               `INPUT(valid,   1),  //Native CPU interface valid signal
	       `INPUT(address, ADDR_W),  //Native CPU interface address signal
               `INPUT(wdata,   WDATA_W), //Native CPU interface data write signal
	       `INPUT(wstrb,   DATA_W/8),  //Native CPU interface write strobe signal
	       `OUTPUT(rdata,  DATA_W), //Native CPU interface read data signal
	       `OUTPUT(ready,  1),  //Native CPU interface ready signal
