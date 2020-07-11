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

module cpu #(
    parameter MEM_ADDR_WIDTH = 8,
    parameter MEM_DATA_WIDTH = 8
  )
  (
    input   wire                          clock,
    input   wire                          rst_n,
    input   wire [MEM_DATA_WIDTH - 1 : 0] mem_data_out,
    output  wire [MEM_DATA_WIDTH - 1 : 0] mem_data_in,
    output  wire [MEM_ADDR_WIDTH - 1 : 0] mem_address,
    output  wire                          write_ena
  );

endmodule
