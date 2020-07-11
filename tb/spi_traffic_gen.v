`timescale 1ns/1ns

module spi_traffic_gen (
  input  wire sys_rst,

  input  wire miso,

  output wire mosi,
  output wire sclk,
  output wire ss_n,

  output wire [7:0] data_rx,
  output wire data_rx_valid
);


reg opclk;

reg mosi_int;
reg sclk_int;
reg ss_n_int;

reg [7:0] data_i;

reg data_i_vld;

reg [7:0] data_rx_int;
reg       data_rx_vld_int;

reg prog_done;

reg [3:0] bit_cnt;

reg [7:0] word_cnt;

task spi_chipselect_low;
  input   sys_rst;
  output  ss_n_int;
  begin
    ss_n_int  = 1'b1;
    wait (sys_rst === 1'b0) begin
      #1000;
    end
    #1000 ss_n_int  = 1'b0;
  end
endtask

task spi_chipselect_high;
  output  ss_n_int;
  begin
    @ (posedge opclk);
    data_i_vld  = 1'b0;
    #500 ss_n_int  = 1'b1;
  end
endtask

task spi_io_onebit;
  input   [7:0] data_o;
  begin
      mosi_int    = data_o[bit_cnt];
      sclk_int    = 1'b0;
      @ (posedge opclk);
      sclk_int     = 1'b1;
      data_i[bit_cnt]   = miso;
      if(bit_cnt == 4'd7) begin
        data_i_vld  = 1'b0;
      end
      if(bit_cnt == 4'd0) begin
        data_i_vld  = 1'b1;
      end
      @ (negedge opclk);
      sclk_int    = 1'b0;
  end
endtask

task spi_io;
  input   [7:0] data_o;
  begin
    bit_cnt = 4'd7;
    spi_io_onebit(data_o);
    bit_cnt = 4'd6;
    spi_io_onebit(data_o);
    bit_cnt = 4'd5;
    spi_io_onebit(data_o);
    bit_cnt = 4'd4;
    spi_io_onebit(data_o);
    bit_cnt = 4'd3;
    spi_io_onebit(data_o);
    bit_cnt = 4'd2;
    spi_io_onebit(data_o);
    bit_cnt = 4'd1;
    spi_io_onebit(data_o);
    bit_cnt = 4'd0;
    spi_io_onebit(data_o);
  end
endtask

initial begin
  opclk     = 1'b0;
  sclk_int  = 1'b0;
  ss_n_int  = 1'b1;
  mosi_int  = 1'b0;
  prog_done = 1'b0;
  word_cnt  = 8'h00;
  data_i    = 8'h00;
  data_i_vld  = 1'b0;
  bit_cnt     = 8'h00;
end

always @(*) begin
  forever begin
    if(ss_n_int) begin
      #1 opclk = 1'b0;
    end
    else begin
      #100  opclk = ~opclk;
    end
  end
end

always @(*) begin
  forever begin
    if (!prog_done) begin
      spi_chipselect_low(sys_rst,ss_n_int);
      //write command
      spi_io(8'h02);
      //write address 32'h04030201
      spi_io(8'h04);
      spi_io(8'h03);
      spi_io(8'h02);
      spi_io(8'h01);
      word_cnt = 8'h01;
      //write data
      repeat(50) begin
        spi_io(word_cnt);
        word_cnt  = word_cnt + 8'h01;
      end
      prog_done = 1'b1;
      spi_chipselect_high(ss_n_int);

      #10000;

      spi_chipselect_low(sys_rst,ss_n_int);
      //read command
      spi_io(8'h03);
      //read address 32'h04030201
      spi_io(8'h04);
      spi_io(8'h03);
      spi_io(8'h02);
      spi_io(8'h01);
      //dummy read... 
      spi_io(8'h00);
      word_cnt = 8'h01;
      repeat(50) begin
        spi_io(word_cnt);
        word_cnt  = word_cnt + 8'h01;
      end
      spi_chipselect_high(ss_n_int);
    end
    else begin
      #1000;
    end
  end
end


always @(posedge opclk, posedge ss_n_int) begin
  if(ss_n_int) begin
    data_rx_int <=  8'h00;
    data_rx_vld_int <=  1'b0;
  end
  else begin
    data_rx_vld_int <=  data_i_vld;
    if(data_i_vld) begin
      data_rx_int <=  data_i;
    end
  end
end

assign mosi = mosi_int;
assign sclk = sclk_int;
assign ss_n = ss_n_int;
assign data_rx  = data_rx_int;
assign data_rx_valid  = data_rx_vld_int;
endmodule
