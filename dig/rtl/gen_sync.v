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

module gen_sync #(
  parameter  RST_VAL  = 1'b0
)
(
  input   wire  async_in,
  input   wire  clk,
  input   wire  rst,
  output  wire  sync_out
);

reg d_s0;
reg d_s1;
reg d_s2;


  always @( posedge clk, posedge rst) begin
    if(rst) begin
      d_s0  <=  RST_VAL;
      d_s1  <=  RST_VAL;
      d_s2  <=  RST_VAL;
    end
    else begin
      d_s0  <=  async_in;
      d_s1  <=  d_s0;
      d_s2  <=  d_s1;
    end
  end

  assign sync_out = d_s2;

endmodule


