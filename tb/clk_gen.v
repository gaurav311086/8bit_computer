`timescale 1ns/1ns

module clk_gen (
  output wire system_clk
);

reg system_clk_int;

initial begin
  system_clk_int = 1'b0;
end

always @ (*) begin
  forever begin
    #5 system_clk_int = ~system_clk_int;
  end
end

assign system_clk = system_clk_int;

endmodule
