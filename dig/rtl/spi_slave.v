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

module spi_slave #(
    parameter PARA_DATA_WIDTH = 8)
(
  input   wire  spi_cs_n,
  input   wire  spi_sck,
  input   wire  spi_si,
  
  output  wire  spi_so,

  input   wire  spi_slv_rst,
  
  input   wire  [PARA_DATA_WIDTH - 1 : 0]  spi_txdata,

  output  wire  spi_txdata_strobe,
  output  wire  [PARA_DATA_WIDTH - 1 : 0]  spi_rxdata,
  output  wire  spi_rxdata_valid

);

localparam  MOD8_CNT_VAL6 = 3'b110;
localparam  MOD8_CNT_VAL7 = 3'b111;

reg [3 : 0] mod8_cnt_spi_sck;
reg         mod8_cnt_val_is_7nxt;

reg [7 : 0] spi_rxdata_int_tmp;
reg [7 : 0] spi_rxdata_int;
reg         spi_rxdata_vld;
reg         spi_txdata_latched;

reg [7 : 0] spi_txdata_int_tmp;
reg [7 : 0] spi_txdata_load;

wire        spi_slv_rst_spi_sck;

//reset rx data only
gen_rst_sync
gen_rst_sync_0
(
  .async_rst  (spi_slv_rst), 
  .clk        (spi_sck),
  .sync_rst   (spi_slv_rst_spi_sck)
);


always @ (posedge spi_sck, posedge spi_cs_n ) begin
  if( spi_cs_n ) begin
    mod8_cnt_spi_sck      <=  4'h0;
    mod8_cnt_val_is_7nxt  <=  1'b0;
  end
  else begin
    mod8_cnt_spi_sck      <=  mod8_cnt_spi_sck[2:0] + 3'h1;
    mod8_cnt_val_is_7nxt  <=  1'b0;
    if(mod8_cnt_spi_sck[2:0] == MOD8_CNT_VAL6) begin
      mod8_cnt_val_is_7nxt  <= 1'b1;
    end
  end
end

always @ (posedge spi_sck, posedge spi_cs_n ) begin
  if( spi_cs_n ) begin
    spi_rxdata_int_tmp  <=  8'h00;
    spi_rxdata_vld      <=  1'b0;
  end
  else begin
    spi_rxdata_int_tmp  <=  {spi_rxdata_int_tmp[6:0],spi_si};
    spi_rxdata_vld      <=  1'b0;
    if (mod8_cnt_val_is_7nxt ) begin
      spi_rxdata_vld  <=  1'b1;
    end
  end
end

always @ (posedge spi_sck, posedge spi_slv_rst_spi_sck ) begin
  if( spi_slv_rst_spi_sck ) begin
    spi_rxdata_int      <=  8'h00;
  end
  else begin
    spi_rxdata_int      <=  spi_rxdata_int;
    if (mod8_cnt_val_is_7nxt ) begin
      spi_rxdata_int  <=  {spi_rxdata_int_tmp[6:0],spi_si};
    end
  end
end

always @ (posedge spi_sck, posedge spi_cs_n ) begin
  if( spi_cs_n ) begin
    spi_txdata_latched  <=  1'b0;
  end
  else begin
    if(mod8_cnt_spi_sck[3]) begin
      spi_txdata_latched  <=  1'b1;
    end
    else begin
      spi_txdata_latched  <=  1'b0;
    end
  end
end

always @ (negedge spi_sck, posedge spi_cs_n ) begin
  if ( spi_cs_n ) begin
    spi_txdata_load     <=  8'h01;
    spi_txdata_int_tmp  <=  8'h00;
  end
  else begin
    spi_txdata_load <=  {spi_txdata_load[6:0],spi_txdata_load[7]};
    if (spi_txdata_load[7]) begin
      spi_txdata_int_tmp  <=  spi_txdata;
    end
    else begin
      spi_txdata_int_tmp  <= {spi_txdata_int_tmp[6:0],1'b0};
    end
  end
end

assign spi_so                   = spi_txdata_int_tmp[7];
assign spi_rxdata               = spi_rxdata_int;
assign spi_rxdata_valid         = spi_rxdata_vld;
assign spi_txdata_strobe        = spi_txdata_latched;

endmodule
