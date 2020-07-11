module tb_top (
);

wire spi_cs_n;
wire spi_clk;
wire spi_mosi;
wire spi_miso;
wire cpu_clk;
wire cpu_rst;

spi_traffic_gen 
spi_traffic_gen (
  .miso           (spi_miso),
  .mosi           (spi_mosi),
  .sclk           (spi_clk),
  .ss_n           (spi_cs_n),
  .sys_rst        (cpu_rst),
  .data_rx        (),
  .data_rx_valid  ()
);

clk_gen 
clk_gen (
  .system_clk (cpu_clk)
);

rst_gen 
rst_gen (
  .system_rst (cpu_rst)
);

cpu_top
dut (
  .clock              (cpu_clk),
  .rst_n              (~cpu_rst),
  .spi_cs_n           (spi_cs_n),
  .spi_sck            (spi_clk),
  .spi_si             (spi_mosi),
  .spi_so             (spi_miso)
);

endmodule
