module spi_controller(
//processor
pclk_i, prst_i, paddr_i, pwdata_i, prdata_o, pwrite_i, penable_i, pready_o, pslverr_o, 

//SPI signals

sclk_i, sclk_o, miso,mosi,ss);
parameter MAX_TRANSFER=8;
parameter NO_SLAVE=4;
parameter WR =1;
parameter RD =0;
parameter S_IDLE=3'b000;
parameter S_ADDR=3'b001;
parameter S_IDLE_BW_ADDR_AND_DATA=3'b010;
parameter S_DATA=3'b011;
parameter S_IDLE_TRANSFER_PENDING=3'b100;

//parameter S_ERROR=3'b100;
//parameter S_NO_INTR=3'b000;

input pclk_i,prst_i,penable_i,pwrite_i;
input [7:0] paddr_i;
input [7:0] pwdata_i;
output reg [7:0] prdata_o;
output reg pready_o;
output reg pslverr_o;
input sclk_i;
output reg sclk_o;
input miso;
output reg mosi;
integer count;
output reg [NO_SLAVE-1:0] ss;

reg sclk_gated_f;
reg [2:0] num_tfrs;
reg [2:0] last_tfrs_idx;

reg [7:0] addr_regA[MAX_TRANSFER-1:0]; // reg to store addr for 8 tranfer here addr will be from 0 to MAX_TRANSFER-1(7), 8 to 15 are reserved
reg [7:0] data_regA[MAX_TRANSFER-1:0];// reg for 8 data_regA , from 8'h10 to 8'h10+MAX_TRANSFER-1(23), 23 to 31 are reserved
reg [7:0] ctrl_regA; //to controll and store information regardin tranfer and pending and last tranfer at 32 location
reg [7:0] addr_t, data_t;
reg [2:0] state, next_state;
integer i;

always @(next_state) begin //this block always used in state machine to make next state as curretn state
	state = next_state;
end

//two process
//programing register
always @(posedge pclk_i) begin
	if (prst_i == 1) begin
		prdata_o = 0;
		pready_o = 0;
		pslverr_o = 0;
		//mosi = 1;
		ss = 0;
		sclk_gated_f = 1;
		num_tfrs = 0;
		last_tfrs_idx = 0;
		for(i = 0; i < MAX_TRANSFER; i=i+1) begin
			addr_regA[i] = 0;
			data_regA[i] = 0;
		end
		ctrl_regA = 0;
		state = S_IDLE;
		next_state = S_IDLE;
	end
	else begin
	if(penable_i == 1) begin //enable is given by processor 
		pready_o = 1; //INTC say ready
			if (pwrite_i == 1) begin //pwrite_i =1 for write and 0 for read
				if (paddr_i >= 8'h00 && paddr_i < 8'h00+MAX_TRANSFER-1) begin 
					addr_regA[paddr_i] = pwdata_i;
				end
				if (paddr_i >= 8'h10 && paddr_i < 8'h10+MAX_TRANSFER-1) begin 
					data_regA[paddr_i-16] = pwdata_i;
				end
				if (paddr_i == 8'h20) begin
					ctrl_regA[3:0] = pwdata_i[3:0];  // 7 to 4 are external 
				end
			end
			else begin
			if (paddr_i >= 8'h00 && paddr_i < 8'h00+MAX_TRANSFER-1) begin 
				prdata_o = addr_regA[paddr_i];
			end
			if (paddr_i >= 8'h10 && paddr_i < 8'h10+MAX_TRANSFER-1) begin 
				prdata_o = data_regA[paddr_i-16];
			end
			if (paddr_i == 8'h20) begin
				prdata_o = ctrl_regA;
			end
			end
	end
end
end
//SPI timing diagram implementation

//ctrl_regA[0] indicate whent to start tranfer 
//ctrl_regA [3:1] indicate how many tranfer to do(0 to 7 +1 mean 1 to 8 )(+1 mapping ,mean if its 3, do 4 tranfer)
//ctrl_regA [6:4] indicate last transfer status and which are pending, current position
//ctrl_regA[7] indicate status , error or anything else . 

always @(posedge sclk_i) begin
	if (prst_i == 0) begin
		mosi = 1;
		case(state)
			S_IDLE : begin
				sclk_gated_f = 1;
				mosi = 1;
				if(ctrl_regA[0] == 1) begin // controll reg LSB say when transition will start
					next_state = S_ADDR;
					count = 0;
					num_tfrs = ctrl_regA[3:1] +1;
					last_tfrs_idx = ctrl_regA[6:4];
					addr_t = addr_regA[last_tfrs_idx];// addr to drive
					data_t = data_regA[last_tfrs_idx];//data to drive or collect
					ctrl_regA[0] = 0;
				end
			end
	
			S_ADDR : begin
				sclk_gated_f = 0;
				mosi = addr_t[count];//LSB first
				ss[0] = 1;
				count = count + 1;
				if (count == 8) begin
					next_state = S_IDLE_BW_ADDR_AND_DATA;
					count = 0;
				end
			//$display("addr_t = %h",addr_t);
			end
	
			S_IDLE_BW_ADDR_AND_DATA : begin
				sclk_gated_f = 1;
				mosi = 1;
				count = count + 1; //if 4 clock cycle ideal time for addr and data
				if (count == 3) begin
					next_state = S_DATA;
					count = 0;
				end
			end
	
			S_DATA : begin
				sclk_gated_f = 0;
				if (addr_t[7] == WR) begin// i find error here addr_regA wrriten instead of addr_t
					mosi = data_t[count];
		//WR = 0 ;
				end
				else begin
					data_t[count] = miso;
				end
				count = count+1;
				if (count == 8) begin
					count = 0;
					num_tfrs = num_tfrs - 1;
					last_tfrs_idx = last_tfrs_idx +1;
					ctrl_regA[6:4] = last_tfrs_idx;
					addr_t = 0; // if this line is not written, when u run after some time, it will run from start but we want to start from where it left. 
					data_t = 0;
					if (num_tfrs == 0) begin
						next_state = S_IDLE;
					end
					else begin
						next_state = S_IDLE_TRANSFER_PENDING;
					end
				end
		//$display("data_t = %h",data_t);
			end 
 
	
			S_IDLE_TRANSFER_PENDING : begin
				ss[0] = 0;
				mosi = 1;
				sclk_gated_f = 1;
				count = count + 1; //if 4 clock cycle ideal time for addr and data
				if (count == 8) begin
					next_state = S_ADDR;
					addr_t = addr_regA[last_tfrs_idx];// addr to drive
					data_t = data_regA[last_tfrs_idx];
					count = 0;
				end
			end
		endcase
	end
end

always @(sclk_i) begin
	if (sclk_gated_f == 1) sclk_o = 1;
	else sclk_o = sclk_i;
end

endmodule