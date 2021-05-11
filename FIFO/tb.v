module tb;
parameter width = 8;
parameter depth = 16;
parameter ptr_width = 4;
reg clk,rst,wr_valid,rd_valid;
reg [width-1:0] data_i;
wire [width-1:0] data_o;
wire full_fifo,fifo_empty,error;
integer i;

sync_fifo dut(clk,rst,wr_valid,data_i,full_fifo, rd_valid, data_o,fifo_empty,error);

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin 
	rst = 1;
	#20;//
//	repeat (2) @(posedge clk);
	rst = 0;
	//apply stimulus 
	//make fifo full;
	for (i = 0; i < depth; i=i+1) begin
	@(posedge clk)
		wr_valid = 1;
		data_i = $random;
	end
	@(posedge clk)
		wr_valid = 0;
		data_i = 0;
	
	for (i = 0; i < depth; i=i+1) begin
		@(posedge clk)
		rd_valid = 1;
	end
		@(posedge clk)
		rd_valid = 0;
		#1000;
$finish;	
end

endmodule
