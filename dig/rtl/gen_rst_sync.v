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

module gen_rst_sync #(
  parameter  RST_ACTIVE_HIGH  = 1'b1
)
(
  input   wire  async_rst,
  input   wire  clk,
  output  wire  sync_rst
);

reg d_s0;
reg d_s1;
reg d_s2;


  always @( posedge clk, posedge async_rst) begin
    if(async_rst) begin
      d_s0  <=  RST_ACTIVE_HIGH;
      d_s1  <=  RST_ACTIVE_HIGH;
      d_s2  <=  RST_ACTIVE_HIGH;
    end
    else begin
      d_s0  <=  ~ RST_ACTIVE_HIGH;
      d_s1  <=  d_s0;
      d_s2  <=  d_s1;
    end
  end

  assign sync_rst = d_s2;

endmodule


