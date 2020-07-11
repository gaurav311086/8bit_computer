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

module rom_128x8_sync 
 #(
    parameter MEM_ADDR_WIDTH = 7,
    parameter MEM_DATA_WIDTH = 8
  )
  (
    input   wire                          clock,

    input   wire [MEM_ADDR_WIDTH - 1 : 0] address0,
    input   wire [MEM_DATA_WIDTH - 1 : 0] data_in0,
    input   wire                          rnw0,

    input   wire [MEM_ADDR_WIDTH - 1 : 0] address1,

    output  wire [MEM_DATA_WIDTH - 1 : 0] data_out0,

    output  wire [MEM_DATA_WIDTH - 1 : 0] data_out1
  );

drsw_ram_sync 
 #(
    .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH),
    .MEM_DATA_WIDTH(MEM_DATA_WIDTH)
  )
drsw_ram_sync_0
  (
    .clock      (clock),
    .address0   (address0),
    .address1   (address1),
    .data_in0   (data_in0),
    .rnw0       (rnw0),
    .data_out0  (data_out0),
    .data_out1  (data_out1)
  );

endmodule
