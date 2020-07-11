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

module ram_sync #(
    parameter MEM_ADDR_WIDTH = 8,
    parameter MEM_DATA_WIDTH = 8
  )
  (
    input   wire                          clock,
    input   wire [MEM_ADDR_WIDTH - 1 : 0] address,
    input   wire [MEM_DATA_WIDTH - 1 : 0] data_in,
    input   wire                          rnw,
    output  wire [MEM_DATA_WIDTH - 1 : 0] data_out
  );

  localparam MEM_DEPTH = 2 ** MEM_ADDR_WIDTH;

  reg [MEM_DATA_WIDTH - 1 : 0] memory [0: MEM_DEPTH - 1];

  reg [MEM_DATA_WIDTH - 1 : 0] data_out_int;

  reg data_out_valid_int;

  always @(posedge clock) begin : ram_sync_mem_write_proc
    if(!rnw) begin
      memory[address] <= data_in;
    end
  end

  always @(posedge clock) begin : ram_sync_mem_read_proc
    data_out_int        <=  memory[address];
  end

  assign data_out       =  data_out_int;

endmodule
