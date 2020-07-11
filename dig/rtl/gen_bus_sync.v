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

module gen_bus_sync #(
  parameter  RST_VAL    = 1'b0,
  parameter  BUS_WIDTH  = 8
)
(
  input   wire  [BUS_WIDTH - 1 : 0 ]  async_in,
  input   wire  clk,
  input   wire  rst,
  output  wire  [BUS_WIDTH - 1 : 0 ]  sync_out
);

genvar gi;

  for (gi = 0; gi < BUS_WIDTH ; gi = gi + 1) begin : gen_sync_bit
    gen_sync
    #( 
      .RST_VAL (RST_VAL)
    )
    gen_sync 
    (
      .async_in (async_in[gi]),
      .clk      (clk),
      .rst      (rst),
      .sync_out (sync_out[gi])
    );
  end

endmodule


