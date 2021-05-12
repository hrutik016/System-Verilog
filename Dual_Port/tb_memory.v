module tb;

parameter WIDTH = 8;
parameter DEPTH = 512;
parameter ADD_WIDTH = 9;

reg clk,rst;
reg [ADD_WIDTH-1:0] wr_addr;
reg [ADD_WIDTH-1:0] rd_addr;
reg [WIDTH-1:0] wdata;
wire [WIDTH-1:0] rdata;
reg wr_en, rd_en;

reg [20*8:1] testname; //it can store upto 20 characters of

integer i;
//connection by port , this is prone to error
//dual_port dut(clk,rst,wr_addr,rd_addr,wdata,rdata,wr_en,rd_en);


//connection by name 
dual_port #(.WIDTH(WIDTH), .DEPTH(DEPTH),.ADD_WIDTH(ADD_WIDTH)) 
			dut(.clk(clk),.rst(rst),.rd_addr(rd_addr),.wr_addr(wr_addr),
			  .wdata(wdata),.rdata(rdata),.wr_en(wr_en),.rd_en(rd_en));

//connection by default 
//dual_port dut(*);


initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

task fd_write();
 begin
	for (i=0;i < DEPTH;i=i+1) begin
	@(posedge clk)
	wr_addr = i;
	wr_en = 1;
	wdata = $random;
end
@(posedge clk)
	wr_addr = 0;
	wr_en = 0;
	wdata = 0;
end
endtask

task fd_read();
begin
	for (i=0;i < DEPTH; i=i+1) begin
		@(posedge clk)
			rd_addr = i;
			rd_en = 1;
		end
		@(posedge clk)
			rd_addr = 0;
			rd_en = 0;
end
endtask

task bd_write();
 begin
	$readmemh ("image.hex", dut.mem); // backdoor memory write,load memory into dut 
	//$readmemh ("image_1.hex", dut.mem); // load specific location (ex 40 address) with specific value
	//$readmemh ("image_2.hex", dut.mem, 70); // load specific value from location 70 decimal
	//$readmemh ("image_2.hex", dut.mem, 70,72); // load specific value from location 70 to 73  decimal but file has 4 value and we upload 3 only
end
endtask

task bd_read();
 begin
	$writememh ("abc.hex", dut.mem);//backdoor memory read
	//$writememh ("abc_1.hex", dut.mem, 10,19);//backdoor memory read, for specific location from 10 to 19 in decimal
end
endtask


initial begin
	$value$plusargs("testname=%s", testname);
	rst = 1;
	wr_en = 0;
	rd_en = 0;
	#20;
rst =0;
case (testname)
"test_bd_wr_bd_rd" : begin
 bd_write ();
 bd_read ();
end
	
"test_fd_wr_fd_rd" : begin
fd_write();
fd_read();
end

"test_fd_wr_bd_rd" : begin
fd_write();
 bd_read ();
end

"test_bd_wr_fd_rd" : begin
bd_write ();
fd_read();
end

endcase
	#100;
	$finish;
end
endmodule