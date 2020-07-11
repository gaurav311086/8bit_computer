`timescale 1ns/1ns

module rst_gen (
  output wire system_rst
);

reg system_rst_int;

initial begin
  system_rst_int = 1'b0;
  repeat(4) begin
    #10 system_rst_int = 1'b1;
  end
  forever begin
    #50 system_rst_int = 1'b0;
  end
end

assign system_rst = system_rst_int;

endmodule
