`include "spi_ctrl.v"
module tb;
parameter MAX_TRANSFER					=8;
parameter NO_SLAVE					 	=4;
parameter WR 							= 1;
parameter RD 							= 0;
parameter S_IDLE   						=3'b000;
parameter S_ADDR						=3'b001;
parameter S_IDLE_BW_ADDR_AND_DATA		=3'b010;
parameter S_DATA						=3'b011;
parameter S_IDLE_TRANSFER_PENDING		=3'b100;
parameter S_IDLE_TEMP  						=3'b101;

reg pclk_i,prst_i,penable_i,pwrite_i;
reg [7:0] paddr_i;
reg [7:0] pwdata_i;
wire [7:0] prdata_o;
wire pready_o;
wire pslverr_o;
reg sclk_i;
wire sclk_o;
reg miso;
reg mosi_t;
wire mosi;
wire [NO_SLAVE-1:0] ss;
reg [7:0] addr_t;
reg [7:0] data_rd;
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
always @(posedge sclk_i) begin
	mosi_t = mosi;
end
initial begin
	prst_i = 1; // al input should be rst 
	paddr_i = 0;
	pwdata_i = 0;
	pwrite_i = 0;
	penable_i = 0;
	miso = 1;
	wr_rd_f = 0;
	state = S_IDLE_TEMP;
	next_state = S_IDLE_TEMP;
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
	reg_write (8'h20,{1'b0,3'b0,3'h3,1'b1}); // trigger tranfer and do 3 transfer, as 2 it consider 2+1
	#300;
	reg_write (8'h20,{1'b0,3'b0,3'h2,1'b1});
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
//initial begin 

always	@(posedge sclk_o) begin
	case(state)
	
	S_IDLE_TEMP: begin
		next_state = S_IDLE;
	end
	
	S_IDLE : begin
		next_state = S_ADDR;
		count = 0;
		addr_t[count] = mosi_t;
	end
	
	
	S_ADDR : begin
	count = count +1;
	addr_t[count] = mosi_t;
	if (count == 8 ) begin
	next_state = S_IDLE_BW_ADDR_AND_DATA;
		$display("addr_t = %h",addr_t);
	count = 0;

	end
	end
	
	S_IDLE_BW_ADDR_AND_DATA : begin
	next_state = S_DATA;
	if (addr_t[7] == 0) begin
		data_rd = $random;
		miso = data_rd[count];
	end
	else begin
	data_rd[count] = mosi_t;
	end
	end
	
	S_DATA : begin
		count = count +1;
	if (addr_t[7] == 1) begin
		data_rd[count] = mosi_t;
	end
	else begin
		miso = data_rd[count];
	end
	//count = count +1;
	if (count == 8 ) begin	
	$display("data_rd = %h",data_rd);
	next_state = S_IDLE;		
		count = 0;
	end	
	end
	endcase
end
//end

endmodule
