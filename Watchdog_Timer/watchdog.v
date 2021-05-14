module watchdog_timer(
//processor
pclk_i, prst_i, paddr_i, pwdata_i, prdata_o, pwrite_i, penable_i, pready_o, pslverr_o,
//system interface
activity_i, systm_rst_o);

parameter NUM_INTR=16;
parameter S_RST=2'b00;
parameter S_NO_ACTIVITY=2'b01;
parameter S_ACTIVITY=2'b10;
parameter S_THRESHHOLD_TIMEOUT	=2'b11;

//parameter S_ERROR=3'b100;
//parameter S_NO_INTR=3'b000;

input pclk_i,prst_i,penable_i,pwrite_i;
input [7:0] paddr_i;
input [7:0] pwdata_i;
output reg [7:0] prdata_o;
output reg pready_o;
output reg pslverr_o;
input activity_i;
output reg systm_rst_o;

reg [7:0] threshold_timer_reg;
reg [1:0] state, next_state;
integer i;
integer no_activity_count ;

always @(next_state) begin //this block always used in state machine to make next state as curretn state
	state = next_state;
end

always @(posedge pclk_i) begin
	if (prst_i == 1) begin
		prdata_o = 0;
		pready_o = 0;
		pslverr_o = 0;
		state = S_RST;
		next_state = S_RST;
		systm_rst_o = 0;
		no_activity_count = 0;
	end
	else begin
		if(penable_i == 1) begin //enable is given by processor 
			pready_o = 1; //INTC say ready
			if (pwrite_i == 1) begin //pwrite_i =1 for write and 0 for ready
			threshold_timer_reg = pwdata_i;
			end
			else begin
			prdata_o = threshold_timer_reg;
			end
		end
	end
end

always @(posedge pclk_i) begin
case (state) 
	S_RST : begin
		if (activity_i == 1) begin
			next_state = S_ACTIVITY;
		end
		else begin
		next_state = S_NO_ACTIVITY;
		no_activity_count = no_activity_count + 1;
		end
	end
	
	S_NO_ACTIVITY : begin
		systm_rst_o = 0;
		if (activity_i == 0) begin
			no_activity_count = no_activity_count + 1;
			if (no_activity_count == threshold_timer_reg) begin
			next_state = S_THRESHHOLD_TIMEOUT;
			end
		end
		else begin 
			next_state = S_ACTIVITY;
		end
	end
	
	S_ACTIVITY : begin
		systm_rst_o = 0;
		no_activity_count = 0;
		if (activity_i == 1) begin
			next_state = S_ACTIVITY;
		end
		else begin 
			next_state = S_NO_ACTIVITY;
		end
	end
	
	S_THRESHHOLD_TIMEOUT : begin
		systm_rst_o = 1;
		next_state = S_NO_ACTIVITY;
		no_activity_count = 0;
	end
endcase
end

endmodule
