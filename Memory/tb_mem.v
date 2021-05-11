module tb;
reg clk,rst;
reg [6:0] addr;
reg [7:0] wdata;
wire [7:0] rdata;
reg wr_en, rd_en;
integer i;

memory dut(clk,rst,addr,wdata,rdata,wr_en,rd_en);

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end


initial begin 
	rst = 1; // when rst, all reg shuld be in rst value.
	wr_en = 0;
	rd_en = 0;
	wdata = 0;
	//#20;
	repeat (2) @(posedge clk);
	rst = 0;
	// generate stimulous
	//write operation
	for (i = 0; i <=127; i = i+1) begin
		@(posedge clk)
		addr = i;
		wr_en = 1;
		wdata = $random;
	end
	@(posedge clk)
		addr = 0;
		wr_en = 0;
		wdata = 0;
		
	// read operation
	for (i = 0; i <=127; i = i+1) begin
			@(posedge clk)
			addr = i;
			rd_en = 1;
	end
	@(posedge clk)
		addr = 0;
		rd_en = 0;
end

initial begin
#3500;
$finish;
end
endmodule
	 
	
		
	

	


