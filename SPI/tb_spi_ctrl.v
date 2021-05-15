`include "spi_ctrl.v"

module tb;

parameter MAX_TRANSFER=8;
parameter NO_SLAVE=4;
parameter WR = 1;
parameter RD = 0;
parameter S_ADDR = 2'b00;
parameter S_DATA = 2'b01;
reg pclk_i,prst_i,penable_i,pwrite_i;
reg [7:0] paddr_i;
reg [7:0] pwdata_i;
wire [7:0] prdata_o;
wire pready_o;
wire pslverr_o;
reg sclk_i;
wire sclk_o;
reg miso;
wire mosi;
wire [NO_SLAVE-1:0] ss;
reg [7:0] addr_t;
reg [7:0] data_t;
reg [1:0] state, next_state;
reg wr_rd_f;
integer i,count;
spi_controller dut(pclk_i, prst_i, paddr_i, pwdata_i, prdata_o, pwrite_i, penable_i, pready_o, pslverr_o, sclk_i, sclk_o, miso,mosi,ss);

initial begin
	pclk_i = 0;
	forever #5 pclk_i =  ~pclk_i;
end
always @(next_state) begin //this block always used in state machine to make next state as curretn state
	state = next_state;
end
initial begin
	sclk_i = 0;
	forever #1 sclk_i =  ~sclk_i;
end

initial begin
	prst_i = 1; // al input should be rst 
	paddr_i = 0;
	pwdata_i = 0;
	pwrite_i = 0;
	penable_i = 0;
	miso = 1;
	wr_rd_f = 0;
	state = 0;
	next_state = 0;
	count = 0;
	repeat (2) @(posedge pclk_i);
	prst_i = 0;
	count = 0;
	//program registers
	//address reg is being filled , its start from 0 to 8 and 53 to next 8 location
	for (i=0; i<MAX_TRANSFER; i=i+1) begin
		wr_rd_f = 1;
		addr_t = 8'h53+i;
		addr_t[7] = wr_rd_f;
		reg_write (i, addr_t); // address reg is from 53,54,55 so on...
	end
		//data reg is being filled
	for (i=0; i<MAX_TRANSFER; i=i+1) begin
		reg_write (8'h10+i,8'h46+i); // data from 46 to 8 and stored at location 8'h10 to next 8
	end
	
	//ctrl_reg
	reg_write (8'h20,{1'b0,3'b0,3'h2,1'b1}); // trigger tranfer and do 3 transfer, as 2 it consider 2+1
	#300;
	reg_write (8'h20,{1'b0,3'b0,3'h3,1'b1});
	#1000;
	$finish;
end
task reg_write(input [7:0] addr, input [7:0] data);
begin
	@(posedge pclk_i);
	paddr_i = addr;//1 to 2 to 3 so on
	pwdata_i = data; // priority value same as i, 15-i is reverse priorty
	pwrite_i= 1;
	penable_i = 1;
	wait (pready_o ==1);
	@(posedge pclk_i);
	paddr_i = 0;//1 to 2 to 3 so on
	pwdata_i = 0; // priority value same as i, 15-i is reverse priorty
	pwrite_i= 0;
	penable_i = 0;
end
endtask
endmodule