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

module memory #(
    parameter MEM_ADDR_WIDTH = 8,
    parameter MEM_DATA_WIDTH = 8
  )
  (
    input   wire                          clock,

    input   wire [MEM_ADDR_WIDTH - 1 : 0] address_spi_inf,
    input   wire [MEM_DATA_WIDTH - 1 : 0] data_in_spi_inf,
    input   wire                          rnw_spi_inf,

    input   wire [MEM_ADDR_WIDTH - 1 : 0] address_cpu,
    input   wire [MEM_DATA_WIDTH - 1 : 0] data_in_cpu,
    input   wire                          rnw_cpu,

    output  wire [MEM_DATA_WIDTH - 1 : 0] data_out_spi_inf,

    output  wire [MEM_DATA_WIDTH - 1 : 0] data_out_cpu
  );

  wire  [MEM_DATA_WIDTH - 1 : 0]  data_out0_cpu;
  wire  [MEM_DATA_WIDTH - 1 : 0]  data_out1_cpu;
  wire  ram_rnw;

  rom_128x8_sync #(
      .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH - 1),
      .MEM_DATA_WIDTH(MEM_DATA_WIDTH)
    )
  rom
  (
    .clock      (clock),
    .address0   (address_spi_inf[MEM_ADDR_WIDTH - 2 : 0]),
    .address1   (address_cpu[MEM_ADDR_WIDTH - 2 : 0]),
    .data_in0   (data_in_spi_inf),
    .rnw0       (rnw_spi_inf),
    .data_out0  (data_out_spi_inf),
    .data_out1  (data_out0_cpu)
  );

  assign  ram_rnw = rnw_cpu | ~address_cpu[MEM_ADDR_WIDTH - 1];

  ram_sync #(
    .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH - 1),
    .MEM_DATA_WIDTH(MEM_DATA_WIDTH)
  )
  ram
  (
    .clock    (clock),
    .address  (address_cpu[MEM_ADDR_WIDTH - 2 : 0]),
    .data_in  (data_in_cpu),
    .rnw      (ram_rnw),
    .data_out (data_out1_cpu)
  );

  assign  data_out_cpu  = (address_cpu[MEM_ADDR_WIDTH - 1])? data_out1_cpu: data_out0_cpu;
endmodule
