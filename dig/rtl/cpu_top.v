//////////////////////////////////////////////////////////////////////////////
//
//  
//
//  
//
//  Original Author: Gaurav Dubey
//  Current Owner:   Gaurav Dubey 
//
//////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 BlueFLare, Inc.  All rights reserved.
//
// BlueFlare CONFIDENTIAL - This is an unpublished, proprietary work of
// BlueFlare, Inc., and is fully protected under copyright and trade secret
// laws.  You may not view, use, disclose, copy, or distribute this file or
// any information contained herein except pursuant to a valid written
// license agreement. It may not be used, reproduced, or disclosed to others
// except in accordance with the terms and conditions of that agreement.
//
//////////////////////////////////////////////////////////////////////////////

module cpu_top #(
    parameter MEM_ADDR_WIDTH = 8,
    parameter MEM_DATA_WIDTH = 8,
    parameter SPI_ADDR_BYTES_EXPECTED = 3,
    parameter SPI_DATA_BYTES_PER_WORD = 0
  )
  (
    input   wire                          clock,
    input   wire                          rst_n,
    input   wire                          spi_cs_n,
    input   wire                          spi_sck,
    input   wire                          spi_si,
    output  wire                          spi_so
  );

  wire [MEM_DATA_WIDTH -1:0]  rom_rdata;
  wire [MEM_DATA_WIDTH -1:0]  rom_wdata;
  wire [MEM_ADDR_WIDTH -1:0]  spi_inf_saddr;
  wire                        rnw_spi_inf;
  wire                        wr_ena_spi_inf;

memory #(
    .MEM_ADDR_WIDTH (MEM_ADDR_WIDTH),
    .MEM_DATA_WIDTH (MEM_DATA_WIDTH)
  )
cpu_memory
  (
    .clock            (clock),

    .address_spi_inf  (spi_inf_saddr[MEM_ADDR_WIDTH - 1 : 0]),
    .data_in_spi_inf  (rom_wdata),
    .rnw_spi_inf      (rnw_spi_inf),

    .address_cpu      (8'h00),
    .data_in_cpu      (8'h00),
    .rnw_cpu          (1'b1),

    .data_out_spi_inf (rom_rdata),

    .data_out_cpu     ()
  );

rom_cntrlr #(
    .MEM_ADDR_WIDTH       (MEM_ADDR_WIDTH),
    .MEM_DATA_WIDTH       (MEM_DATA_WIDTH),
    .ADDR_BYTES_EXPECTED  (SPI_ADDR_BYTES_EXPECTED),
    .DATA_BYTES_PER_WORD  (SPI_DATA_BYTES_PER_WORD)
)
rom_cntrlr
(
  .spi_cs_n         (spi_cs_n),
  .spi_sck          (spi_sck ),
  .spi_si           (spi_si  ),
  
  .spi_so           (spi_so),
  
  .sys_clk          (clock),
  .sys_rst          (~rst_n),
  .sys_bus_rdata    (rom_rdata),
  
  .sys_bus_addr     (spi_inf_saddr),
  .sys_bus_wdata    (rom_wdata),
  .sys_bus_wr_ena   (wr_ena_spi_inf)

);

assign rnw_spi_inf  = ~wr_ena_spi_inf;

endmodule
