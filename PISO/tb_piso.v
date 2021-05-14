`include "piso.v"

module tb;

parameter TP_CLK_P = 4;
parameter TP_CLK_S = 6;
parameter WIDTH = 8;
parameter DEPTH = 16;
reg clk_p, clk_s,rst_i,valid_i,ready_i;
reg [WIDTH-1:0] d_i;
wire d_o,ready_o,valid_o;

piso #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (clk_p, clk_s, rst_i,d_i,valid_i,ready_o, d_o,valid_o,ready_i);

initial begin
	clk_p = 0;
	forever #(TP_CLK_P/2) clk_p = ~clk_p;
end

initial begin
	clk_s = 0;
	forever #(TP_CLK_S/2) clk_s = ~clk_s;
end

initial begin
rst_i = 1;
repeat (2) @(posedge clk_p);
rst_i = 0;
//write in to PISO
 repeat (20) begin
 @(posedge clk_p);
	valid_i = 1;
	wait (ready_o ==1);
	d_i = $random;
	
end
@(posedge clk_p);
	valid_i = 0;
	d_i = 0;
 #1500;
 $finish;
 end
 
 initial begin
 forever begin
	 @(posedge clk_s);
		if (valid_o == 1) begin
		ready_i = 1;
		end
		else begin
		ready_i = 0;
		end
	end
 end
 endmodule
  