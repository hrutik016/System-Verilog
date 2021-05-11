module tb;
parameter width = 8;
parameter depth = 16;
parameter ptr_width = 4;
reg wr_clk,rd_clk,rst,wr_valid,rd_valid;
reg [width-1:0] data_i;
wire [width-1:0] data_o;
wire fifo_full,fifo_empty,error;
integer i;
integer wr_delay, rd_delay;
reg [40*8:1] testname; //40 ascii character cand hold

async_fifo #(.width(width), .depth(depth), .ptr_width(ptr_width)) dut(wr_clk,rd_clk,rst,wr_valid,data_i,fifo_full, rd_valid, data_o,fifo_empty,error);

initial begin
	wr_clk = 0;
	forever #10 wr_clk = ~wr_clk;
end

initial begin
	rd_clk = 0;
	forever #11 rd_clk = ~rd_clk;
end

initial begin 
$value$plusargs("testname=%s",testname);
	rst = 1;
	#20;//
	repeat (2) @(posedge wr_clk);
	rst = 0;
	
	//apply stimulus 
case (testname)

"test_fifo_full_error" : begin //make error on fifo full
	for (i = 0; i < depth+1; i=i+1) begin //now write from FIFO
	@(posedge wr_clk)
		wr_valid = 1;
		data_i = $random;
	end
	@(posedge wr_clk)
		wr_valid = 0;
		data_i = 0;
end

//in real write.read may not happen at concecutive clk, it may happen at some delays. so add delay for concurrent wr_rd
"test_fifo_concurrent_wr_rd" : begin  //fork join concept us used for concurrent
fork
begin
	for (i = 0; i < 150; i=i+1) begin //now write from FIFO, depth is increased to 100 for more operation

	@(posedge wr_clk) //all write will happen in concecutive clk edges
		wr_valid = 1;
		data_i = $random;
	end
	@(posedge wr_clk)
		wr_valid = 0;
		data_i = 0;
end

begin 	//now read from FIFO
	for (i = 0; i < 150; i=i+1) begin //depth is increased to 100 for more operation
		@(posedge rd_clk) //all read will happen in concecutive clk edges
		rd_valid = 1;
	end
		@(posedge rd_clk)
		rd_valid = 0;
end
join
end

"test_fifo_concurrent_wr_rd_delay" : begin  //fork join concept us used for concurrent
fork
begin
	for (i = 0; i < 500; i=i+1) begin //now write from FIFO, depth is increased to 100 for more operation

		@(posedge wr_clk) //all write will happen in concecutive clk edges
		wr_valid = 1;
		data_i = $random;
		wr_delay = $urandom_range(1,10); 
		@(posedge wr_clk)
		wr_valid = 0;
		data_i = 0;
		repeat(wr_delay) @(posedge wr_clk);
	end
end

begin 	//now read from FIFO
	for (i = 0; i < 500; i=i+1) begin //depth is increased to 100 for more operation
		@(posedge rd_clk) //all read will happen in concecutive clk edges
		rd_valid = 1;
		rd_delay = $urandom_range(1,10); 
		@(posedge rd_clk)
		rd_valid = 0;
		repeat(rd_delay) @(posedge rd_clk);
		
	end
end
join
end

"test_fifo_empty_error" : begin //read happen afer depth also so error print,write should be done before read, 
//now write from FIFO
	for (i = 0; i < depth; i=i+1) begin
	@(posedge wr_clk)
		wr_valid = 1;
		data_i = $random;
	end
	@(posedge wr_clk)
		wr_valid = 0;
		data_i = 0;
	//now read from FIFO
	for (i = 0; i < depth+1; i=i+1) begin
		@(posedge rd_clk)
		rd_valid = 1;
	end
		@(posedge rd_clk)
		rd_valid = 0;	
end
"test_fifo_wr_rd" : begin
//now write from FIFO
	for (i = 0; i < depth; i=i+1) begin
	@(posedge wr_clk)
		wr_valid = 1;
		data_i = $random;
	end
	@(posedge wr_clk)
		wr_valid = 0;
		data_i = 0;
	//now read from FIFO
	for (i = 0; i < depth; i=i+1) begin
		@(posedge rd_clk)
		rd_valid = 1;
	end
		@(posedge rd_clk)
		rd_valid = 0;
end
endcase
 
		#1000;
$finish;	
end

endmodule
