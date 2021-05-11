module tb;
parameter width = 8;
parameter depth = 16;
parameter ptr_width = 4;
reg wr_clk,rd_clk,rst,wr_valid,rd_valid;
reg [width-1:0] data_i;
wire [width-1:0] data_o;
wire fifo_fifo,fifo_empty,error;
integer i;

async_fifo #(.width(width), .depth(depth), .ptr_width(ptr_width)) dut(wr_clk,rd_clk,rst,wr_valid,data_i,fifo_fifo, rd_valid, data_o,fifo_empty,error);

initial begin
	wr_clk = 0;
	forever #8 wr_clk = ~wr_clk;
end
initial begin
	rd_clk = 0;
	forever #7 rd_clk = ~rd_clk;
end
initial begin 
	rst = 1;
	#20;//
	repeat (2) @(posedge wr_clk);
	rst = 0;
	//apply stimulus 
	//make fifo full;
fork
begin
	for (i = 0; i < depth; i=i+1) begin
	@(posedge wr_clk)
		wr_valid = 1;
		data_i = $random;
	end
	@(posedge wr_clk)
		wr_valid = 0;
		data_i = 0;
	
	for (i = 0; i < depth; i=i+1) begin
		@(posedge rd_clk)
		rd_valid = 1;
	end
		@(posedge rd_clk)
		rd_valid = 0;
end
join
#100;
$finish;	
end

endmodule
