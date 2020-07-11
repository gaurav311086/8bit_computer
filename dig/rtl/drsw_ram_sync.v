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

module drsw_ram_sync 
  #(
    parameter MEM_ADDR_WIDTH = 32,
    parameter MEM_DATA_WIDTH = 32
  )
  (
    input   wire                          clock,
    input   wire [MEM_ADDR_WIDTH - 1 : 0] address0,
    input   wire [MEM_ADDR_WIDTH - 1 : 0] address1,
    input   wire [MEM_DATA_WIDTH - 1 : 0] data_in0,
    input   wire                          rnw0,
    output  wire [MEM_DATA_WIDTH - 1 : 0] data_out0,
    output  wire [MEM_DATA_WIDTH - 1 : 0] data_out1
  );

  localparam MEM_DEPTH = 2 ** MEM_ADDR_WIDTH;

  reg [MEM_DATA_WIDTH - 1 : 0] memory0 [0: MEM_DEPTH - 1];
  reg [MEM_DATA_WIDTH - 1 : 0] memory1 [0: MEM_DEPTH - 1];

  reg [MEM_DATA_WIDTH - 1 : 0] data_out_int0;
  reg [MEM_DATA_WIDTH - 1 : 0] data_out_int1;

  always @(posedge clock) begin : ram_sync_mem_write0_proc
    if(!rnw0) begin
      memory0[address0] <= data_in0;
    end
  end

  always @(posedge clock) begin : ram_sync_mem_write1_proc
    if(!rnw0) begin
      memory1[address0] <= data_in0;
    end
  end

  always @(posedge clock) begin : ram_sync_mem_read0_proc
    data_out_int0       <=  memory0[address0];
  end

  always @(posedge clock) begin : ram_sync_mem_read1_proc
    data_out_int1       <=  memory1[address1];
  end

  assign data_out0      = data_out_int0;
  assign data_out1      = data_out_int1;
  assign data_out1      = 8'h00;

endmodule
