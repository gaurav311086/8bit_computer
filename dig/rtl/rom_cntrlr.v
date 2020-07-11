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

module rom_cntrlr #(
    parameter MEM_ADDR_WIDTH = 8,
    parameter MEM_DATA_WIDTH = 8,
    parameter ADDR_BYTES_EXPECTED = 3,
    parameter DATA_BYTES_PER_WORD = 0
)
(
  input   wire  spi_cs_n,
  input   wire  spi_sck,
  input   wire  spi_si,
  
  output  wire  spi_so,
  
  input   wire  sys_clk,
  input   wire  sys_rst,
  input   wire  [MEM_DATA_WIDTH - 1 : 0]  sys_bus_rdata,
  
  output  wire  [MEM_ADDR_WIDTH - 1 : 0]  sys_bus_addr,
  output  wire  [MEM_DATA_WIDTH - 1 : 0]  sys_bus_wdata,
  output  wire  sys_bus_wr_ena

);

wire  [7:0] spi_txdata_spi_sck;
wire        spi_txdata_strobe_spi_sck;
wire  [7:0] spi_txdata_sys_clk;
wire        spi_txdata_strobe_sys_clk;
wire  [7:0] spi_rxdata_spi_sck;
wire        spi_rxdata_valid_spi_sck;
wire  [7:0] spi_rxdata_sys_clk;
wire        spi_rxdata_valid_sys_clk;
reg         spi_rxdata_valid_sys_clk_ds1;
reg         spi_rxdata_valid_sys_clk_pedge;
reg         spi_rxdata_valid_sys_clk_pedge_ds1;
reg         spi_rxdata_valid_sys_clk_pedge_ds2;
reg         spi_txdata_strobe_sys_clk_ds1;
reg         spi_txdata_strobe_sys_clk_pedge;


reg   [31:0] spi_txdata;

wire        rst_sys_clk;

wire        sys_rst_or_spi_cs_n;
wire        rst_spi_sck;
wire        spi_cs_n_sys_clk;
reg         sys_rst_deasserted;

localparam  SM_IDLE = 2'd0;
localparam  SM_OPER = 2'd1;
localparam  SM_ADDR = 2'd2;
localparam  SM_DATA = 2'd3;

localparam  INS_WR   = 8'd2;
localparam  INS_READ = 8'd3;

localparam  DATA_BYTES_PER_WORD_PLUS1 = DATA_BYTES_PER_WORD + 1;

localparam  MEM_DATA_BITS_TRUNCATE  = 32 - MEM_DATA_WIDTH;

reg   [1:0] curr_state;
reg   [1:0] nxt_state;
reg   [1:0] addr_bytes_rcvd;
wire  [2:0] addr_bytes_rcvd_nxt;
reg   [1:0] data_bytes_xchgd;
wire  [2:0] data_bytes_xchgd_nxt;

reg   [7:0] slv_instruction;
reg         slv_instruction_vld;
reg         slv_instr_read;
reg         slv_instr_write;

reg   [31:0]  mem_address;
reg           mem_address_ovrflw;
reg   [31:0]  mem_write_data;
reg           mem_write_data_ena;

genvar  gi;


spi_slave
spi_slave_0
(
  .spi_cs_n           (spi_cs_n),
  .spi_sck            (spi_sck),
  .spi_si             (spi_si),
  
  .spi_so             (spi_so),
  
  .spi_slv_rst        (sys_rst),

  .spi_txdata         (spi_txdata_spi_sck),

  .spi_txdata_strobe  (spi_txdata_strobe_spi_sck),
  .spi_rxdata         (spi_rxdata_spi_sck),
  .spi_rxdata_valid   (spi_rxdata_valid_spi_sck)

);

gen_bus_sync #(
  .BUS_WIDTH  (8)
)
gen_bus_sync_0
(
  .async_in (spi_rxdata_spi_sck),
  .clk      (sys_clk),
  .rst      (rst_sys_clk),
  .sync_out (spi_rxdata_sys_clk)
);

gen_sync
gen_sync_0
(
  .async_in (spi_rxdata_valid_spi_sck),
  .clk      (sys_clk),
  .rst      (rst_sys_clk),
  .sync_out (spi_rxdata_valid_sys_clk)
);

gen_bus_sync #(
  .BUS_WIDTH  (8)
)
gen_bus_sync_1
(
  .async_in (spi_txdata_sys_clk),
  .clk      (spi_sck),
  .rst      (rst_spi_sck),
  .sync_out (spi_txdata_spi_sck)
);

gen_sync
gen_sync_1
(
  .async_in (spi_txdata_strobe_spi_sck),
  .clk      (sys_clk),
  .rst      (rst_sys_clk),
  .sync_out (spi_txdata_strobe_sys_clk)
);

gen_rst_sync
gen_rst_sync_0
(
  .async_rst  (sys_rst),
  .clk        (sys_clk),
  .sync_rst   (rst_sys_clk)
);

assign sys_rst_or_spi_cs_n = sys_rst | spi_cs_n;

gen_rst_sync
gen_rst_sync_1
(
  .async_rst  (sys_rst_or_spi_cs_n),
  .clk        (spi_sck),
  .sync_rst   (rst_spi_sck)
);

gen_sync  #(
  .RST_VAL  (1'b1)
)
gen_sync_2
(
  .async_in (spi_cs_n),
  .clk      (sys_clk),
  .rst      (rst_sys_clk),
  .sync_out (spi_cs_n_sys_clk)
);

always @(posedge sys_clk, posedge rst_sys_clk) begin
  if(sys_rst) begin
    sys_rst_deasserted  <=  1'b0;
  end
  else begin
    if(!sys_rst_deasserted && spi_cs_n_sys_clk ) begin
      sys_rst_deasserted  <=  1'b1;
    end
  end
end


always @(*) begin
  nxt_state = curr_state;
  case (curr_state)
    SM_IDLE : begin
      if(!spi_cs_n_sys_clk && sys_rst_deasserted) begin
        nxt_state = SM_OPER;
      end
    end
    SM_OPER : begin
      if(spi_cs_n_sys_clk) begin
        nxt_state = SM_IDLE;
      end
      else if(spi_rxdata_valid_sys_clk_pedge_ds2) begin
        nxt_state = SM_ADDR;
      end
    end
    SM_ADDR : begin
      if(spi_cs_n_sys_clk) begin
        nxt_state = SM_IDLE;
      end
      else if(spi_rxdata_valid_sys_clk_pedge_ds2 && (addr_bytes_rcvd == ADDR_BYTES_EXPECTED[1:0])) begin
        nxt_state = SM_DATA;
      end
      else if(slv_instruction != INS_READ && slv_instruction != INS_WR) begin
        nxt_state = SM_OPER;
      end
    end
    SM_DATA : begin
      if(spi_cs_n_sys_clk) begin
        nxt_state = SM_IDLE;
      end
    end
    default : begin
      nxt_state = SM_IDLE;
    end
  endcase
end

always @(posedge sys_clk, posedge rst_sys_clk) begin
  if ( sys_rst) begin
    curr_state  <=  SM_IDLE;
  end
  else begin
    curr_state  <=  nxt_state;
  end
end

always @(posedge sys_clk, posedge rst_sys_clk) begin
  if ( sys_rst) begin
    addr_bytes_rcvd  <=  2'd0;
  end
  else begin
    addr_bytes_rcvd  <=  addr_bytes_rcvd_nxt;
  end
end

assign  addr_bytes_rcvd_nxt = (curr_state == SM_ADDR)? 
                                ((spi_rxdata_valid_sys_clk_pedge_ds2)?
                                  (addr_bytes_rcvd[1:0] + 2'd1) :
                                  {1'b0,addr_bytes_rcvd}) 
                                : 2'd0;


always @(posedge sys_clk, posedge rst_sys_clk) begin
  if ( sys_rst) begin
    data_bytes_xchgd <=  2'd0;
  end
  else begin
    data_bytes_xchgd  <=  data_bytes_xchgd_nxt;
  end
end

assign  data_bytes_xchgd_nxt = (curr_state == SM_DATA)? 
                                (((spi_rxdata_valid_sys_clk_pedge && slv_instr_write) || (spi_txdata_strobe_sys_clk_pedge && slv_instr_read))?
                                  (data_bytes_xchgd[1:0] + 2'd1) :
                                  {1'b0,data_bytes_xchgd}) 
                                : 2'd0;



always @(posedge sys_clk, posedge rst_sys_clk) begin
  if ( sys_rst) begin
    slv_instruction     <=  8'd0;
    slv_instruction_vld <=  1'b0;
    slv_instr_read      <=  1'b0;
    slv_instr_write     <=  1'b0;
  end
  else begin
    slv_instruction_vld <=  1'b0;
    if(spi_rxdata_valid_sys_clk_pedge && (curr_state == SM_OPER) ) begin
      slv_instruction     <=  spi_rxdata_spi_sck;
      slv_instruction_vld <=  1'b1;
      slv_instr_read      <=  (spi_rxdata_spi_sck == INS_READ);
      slv_instr_write     <=  (spi_rxdata_spi_sck == INS_WR);
    end
  end
end

always @(posedge sys_clk, posedge rst_sys_clk) begin
  if ( sys_rst) begin
    mem_address         <=  32'h0000;
    mem_address_ovrflw  <=  1'b0;
  end
  else begin
    if(spi_rxdata_valid_sys_clk_pedge_ds2 && (curr_state == SM_ADDR) ) begin
      mem_address  <=  {mem_address[23:0],spi_rxdata_spi_sck};
    end
    else if(spi_rxdata_valid_sys_clk_pedge_ds2 && (curr_state == SM_DATA) ) begin
      {mem_address_ovrflw,mem_address}  <= mem_address + DATA_BYTES_PER_WORD_PLUS1[2:0];
    end
  end
end

always @(posedge sys_clk, posedge rst_sys_clk) begin
  if ( sys_rst) begin
    mem_write_data      <=  32'h0000;
    mem_write_data_ena  <=  1'b0;
  end
  else begin
    mem_write_data_ena  <=  1'b0;
    if(spi_rxdata_valid_sys_clk_pedge_ds1 && (curr_state == SM_DATA) &&  slv_instr_write) begin
      mem_write_data      <=  {mem_write_data[23:0],spi_rxdata_spi_sck};
      if(DATA_BYTES_PER_WORD[1:0] == 2'b00) begin
        mem_write_data_ena  <=  1'b1;
      end
      else if(DATA_BYTES_PER_WORD[1:0] == 2'b01) begin
        mem_write_data_ena  <=  data_bytes_xchgd[1];
      end
      else if(DATA_BYTES_PER_WORD[1:0] == 2'b11) begin
        mem_write_data_ena  <=  (data_bytes_xchgd == 2'b11);
      end
      else begin
        mem_write_data_ena  <=  1'b1;
      end
    end
  end
end



always @(posedge sys_clk, posedge rst_sys_clk) begin
  if(sys_rst) begin
    spi_txdata [MEM_DATA_WIDTH - 1 : 0] <=  MEM_DATA_WIDTH'(0);
    spi_txdata_strobe_sys_clk_ds1       <=  1'b0;
    spi_txdata_strobe_sys_clk_pedge     <=  1'b0;
    spi_rxdata_valid_sys_clk_ds1        <=  1'b0;
    spi_rxdata_valid_sys_clk_pedge      <=  1'b0;
    spi_rxdata_valid_sys_clk_pedge_ds1  <=  1'b0;
    spi_rxdata_valid_sys_clk_pedge_ds2  <=  1'b0;
  end
  else begin
    if(spi_txdata_strobe_sys_clk_pedge && (curr_state == SM_DATA) &&  slv_instr_read) begin
      spi_txdata[MEM_DATA_WIDTH - 1 : 0]  <=  sys_bus_rdata;
    end
    spi_txdata_strobe_sys_clk_ds1       <=  spi_txdata_strobe_sys_clk;
    spi_txdata_strobe_sys_clk_pedge     <=  spi_txdata_strobe_sys_clk & ~spi_txdata_strobe_sys_clk_ds1;
    spi_rxdata_valid_sys_clk_ds1        <=  spi_rxdata_valid_sys_clk;
    spi_rxdata_valid_sys_clk_pedge      <=  (spi_rxdata_valid_sys_clk & ~spi_rxdata_valid_sys_clk_ds1);
    spi_rxdata_valid_sys_clk_pedge_ds1  <=  spi_rxdata_valid_sys_clk_pedge;
    spi_rxdata_valid_sys_clk_pedge_ds2  <=  spi_rxdata_valid_sys_clk_pedge_ds1;
  end
end

generate
  if(MEM_DATA_WIDTH < 32 ) begin : extra_bit_zeroes
    for(gi = 31; gi > MEM_DATA_WIDTH - 1; gi=gi-1) begin
      if(gi > MEM_DATA_WIDTH + 1 ) begin
        always @(posedge sys_clk, posedge rst_sys_clk) begin
          if(sys_rst) begin
            spi_txdata[gi] <= 1'b0;
          end
          else begin
            spi_txdata[gi] <= spi_txdata[gi - 1];
          end
        end
      end
      else begin
        always @(posedge sys_clk, posedge rst_sys_clk) begin
          if(sys_rst) begin
            spi_txdata[gi] <= 1'b0;
          end
          else begin
            spi_txdata[gi] <= spi_txdata[31];
          end
        end
      end
    end
  end
endgenerate 

assign spi_txdata_sys_clk = spi_txdata[MEM_DATA_WIDTH - 1 -:8];

assign sys_bus_addr   = mem_address[MEM_ADDR_WIDTH - 1 : 0];

assign sys_bus_wdata  = mem_write_data[MEM_DATA_WIDTH - 1 : 0];
assign sys_bus_wr_ena = mem_write_data_ena;
endmodule
