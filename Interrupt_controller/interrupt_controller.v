
module interrupt_controller(

//processor

pclk_i, prst_i, paddr_i, pwdata_i, prdata_o, pwrite_i, penable_i, pready_o, pslverr_o, 
 
intr_to_service_o, intr_valid_o, intr_serviced_i,

//peripheral intr_valid_o is use to say that whatever data processor receive untill this bit is given data is fake, else 
its interrupt

//when no intr, intr_to_service_o has always 0 mean processor assume that there is intr from 0 reg/student always and 
consider to serviced
// so intr_valid_o required to tell when this come than only intr is active
//peripheral

intr_active_i);
parameter NUM_INTR=16;
parameter S_NO_INTR=3'b000;
parameter S_INTR_ACTIVE=3'b001;
parameter S_INTR_GIVEN_TO_PROCESS=3'b010;
parameter S_INTR_SERVICED=3'b011;

//parameter S_ERROR=3'b100;
//parameter S_NO_INTR=3'b000;

input pclk_i,prst_i,penable_i,pwrite_i;
input [7:0] paddr_i;
input [7:0] pwdata_i;
output reg [7:0] prdata_o;
output reg pready_o;
output reg pslverr_o;
output reg [3:0] intr_to_service_o;
output reg intr_valid_o;
input intr_serviced_i;

input [NUM_INTR-1:0] intr_active_i;
reg [3:0] priority_regA [NUM_INTR-1:0]; //array of vector,location are number of intr and venctor is for assigned priority 
reg [2:0] state, next_state;
integer i;
reg first_match_f;
reg [3:0] highest_priority;
reg [3:0] interrupt_with_highest_priorty;

always @(next_state) begin //this block always used in state machine to make next state as curretn state
	state = next_state;
end

//two process
//programing register
always @(posedge pclk_i) begin
	if (prst_i == 1) begin//rst all reg variable
		prdata_o = 0;
		pready_o = 0;
		pslverr_o = 0;
		intr_to_service_o = 0;
		intr_valid_o = 0;
		first_match_f = 0;
		highest_priority = 0;
		interrupt_with_highest_priorty = 0;
		for(i = 0; i < NUM_INTR; i=i+1) begin
			priority_regA[i] = 0;
		end
		state = S_NO_INTR;
		next_state = S_NO_INTR;
	end
	else begin
		if(penable_i == 1) begin //enable is given by processor 
			pready_o = 1; //INTC say ready
			if (pwrite_i == 1) begin //pwrite_i =1 for write and 0 for ready
				priority_regA[paddr_i] = pwdata_i;
			end
			else begin
				prdata_o = priority_regA[paddr_i];
			end
		end
	end
end
// 2nd process: interrupthandling , actual functionality of INTC
always @(posedge pclk_i) begin
	if (prst_i != 1) begin
		case(state)
		S_NO_INTR : begin
			if (intr_active_i != 0) begin//intr_active_i is not 0 mean intr_active_i is active with any value
				first_match_f = 1;
				next_state = S_INTR_ACTIVE;
			end
		end
		
		S_INTR_ACTIVE : begin
			//figure out interrupt with highest priority
			for (i=0; i<NUM_INTR; i=i+1) begin
				if (intr_active_i[i]) begin
					if (first_match_f == 1) begin // this will always enter in this loop as first_match_f is 1 from rst and make this interrupt as reference priority 
						highest_priority = priority_regA[i];
						interrupt_with_highest_priorty = i;
						first_match_f = 0;  //this is to make first interrupt with highest priority and as reference of this check other interrupt's priority and finalize which is highest 
					end
					else begin
						if (highest_priority < priority_regA[i]) begin
							highest_priority = priority_regA[i];
							interrupt_with_highest_priorty = i;
						end
					end
				end
			end
			next_state = S_INTR_GIVEN_TO_PROCESS;
		end
		
		S_INTR_GIVEN_TO_PROCESS : begin
			intr_to_service_o = interrupt_with_highest_priorty;
			intr_valid_o = 1;
			first_match_f = 1;
			next_state = S_INTR_SERVICED;
		end
		
		S_INTR_SERVICED : begin
			if (intr_serviced_i == 1) begin
				intr_to_service_o = 0;
				intr_valid_o = 0;
				//first_match_f = 1;
				highest_priority =  0;
				interrupt_with_highest_priorty = 0;
				if (intr_active_i != 0) begin
					next_state = S_INTR_ACTIVE;
				end
				else begin
					next_state = S_NO_INTR;
				end
			end
			else begin
				next_state = S_INTR_SERVICED;
			end
		end
		endcase
	end
end
endmodule