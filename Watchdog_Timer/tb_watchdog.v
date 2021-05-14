module tb;
  
reg pclk_i,prst_i,penable_i,pwrite_i;
reg [7:0] paddr_i;
reg [7:0] pwdata_i;
wire [7:0] prdata_o;
wire pready_o;
wire pslverr_o;
reg activity_i;
wire systm_rst_o;

watchdog_timer dut (
//processor
pclk_i, prst_i, paddr_i, pwdata_i, prdata_o, pwrite_i, penable_i, pready_o, pslverr_o,
//system interface
activity_i, systm_rst_o);

initial begin
	pclk_i = 0;
	forever #5 pclk_i =  ~pclk_i;
end

initial begin
	prst_i = 1;
	paddr_i = 0;
	pwdata_i = 0;
	pwrite_i = 0;
	penable_i = 0;
	activity_i = 0;
	repeat (2) @(posedge pclk_i);
	prst_i = 0;
	reg_write (0,200);
	#2000;
	activity_i = 1;
	#10;
	activity_i = 0;
	#1000;
	activity_i = 1;
	# 10; 
	activity_i = 0;
	#3000;
	$finish;
end
task reg_write(input [7:0] addr, input [7:0] data);
begin
	@(posedge pclk_i);
	paddr_i = addr;//1 to 2 to 3 so on
	pwdata_i = data; // priority value same as i, 15-i is reverse priorty
	pwrite_i= 1;
	penable_i = 1;
	wait (pready_o == 1);
	@(posedge pclk_i);
	paddr_i = 0;//1 to 2 to 3 so on
	pwdata_i = 0; // priority value same as i, 15-i is reverse priorty
	pwrite_i= 0;
	penable_i = 0;
end
endtask	
endmodule