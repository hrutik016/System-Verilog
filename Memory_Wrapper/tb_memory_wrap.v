module tb;

parameter width = 8;
parameter depth = 128;
parameter addr_width = 7;
parameter mem_number = 4;

reg clk, rst;
reg [addr_width-1:0] addr;
reg [width*mem_number-1:0] wdata;
wire [width*mem_number-1:0] rdata;
reg wr_en, rd_en;
reg [20*8:1] testname; 
integer i;

memory_wrapper #(.width(width), .depth(depth), .addr_width(addr_width), .mem_number(mem_number))  dut(.clk(clk), .rst(rst), .addr(addr), .wdata(wdata), .rdata(rdata), .wr_en(wr_en), .rd_en(rd_en));

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

task fd_write();
 begin
	for (i=0;i<=depth;i=i+1) begin
	@(posedge clk)
	addr = i;
	wr_en = 1;
	//wdata = $random; //it generate only 32 bit , if total data width is more than 32 bit , msb will be all ffff or 000000
	wdata = {(width*mem_number/32){$random}}; //right for above problem
end
@(posedge clk)
	addr = 0;
	wr_en = 0;
	wdata = 0;
end
endtask

task fd_read();
begin
	for (i=0;i<=depth;i=i+1) begin
@(posedge clk)
	addr = i;
	rd_en = 1;
end
@(posedge clk)
	addr = 0;
	rd_en = 0;
end
endtask

task bd_write();
 begin
	$readmemh ("image.hex", dut.mem); // backdoor memory write,load memory into dut 
	$readmemh ("image_1.hex", dut.mem); // load specific location (ex 40 address) with specific value
	$readmemh ("image_2.hex", dut.mem, 70); // load specific value from location 70 decimal
	$readmemh ("image_2.hex", dut.mem, 70,72); // load specific value from location 70 to 73  decimal but file has 4 value and we upload 3 only 
end
endtask

task bd_read();
 begin
 	$writememh ("abc.hex", dut.mem);//backdoor memory read
	$writememh ("abc_1.hex", dut.mem, 10,19);//backdoor memory read, for specific location from 10 to 19 in decimal 
end
endtask


initial begin
	$value$plusargs("testname=%s", testname);
	rst =1;
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