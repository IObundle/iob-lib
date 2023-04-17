headers = [
    "axi_m_port",
    "axi_m_write_port",
    "axi_m_read_port",
    "axi_m_m_write_portmap",
    "axi_m_m_read_portmap",
]
modules = [
    "axis2axi.v",
    "axis2axi_in.v",
    "axis2axi_out.v",
    "iob_fifo_sync",
    "iob_counter",
    "iob_reg_r",
    "iob_reg_re",
    "iob_asym_converter",
]
sim_modules = ["AxiDelay.v", "axi_ram", "iob_ram_t2p"]
sim_headers = []
