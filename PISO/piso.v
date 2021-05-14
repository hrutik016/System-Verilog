`include "asyn_fifo.v"

module piso(clk_p, clk_s, rst_i,d_i,valid_i,ready_o, d_o,valid_o,ready_i);

parameter WIDTH = 8;
parameter DEPTH = 16;
parameter S_FIFO_EMPTY =  3'b000;
parameter S_READ_FROM_FIFO=  3'b001;
parameter S_TRASMIT_INPROGRESS =  3'b010;
parameter S_TRASMIT_DONE=  3'b011;
//parameter S_FIFO_FULL =  3'b100;

input clk_p, clk_s,rst_i,valid_i,ready_i;
input [WIDTH-1:0] d_i;
output reg d_o,ready_o,valid_o;
reg wr_en_t, rd_en_t;
wire full_t,empty_t,error_t;
wire [WIDTH-1:0] rdata_t;
reg [2:0] state, next_state;
integer count;

always @(next_state) begin
	state = next_state;
end
async_fifo #(.WIDTH(WIDTH), .DEPTH(DEPTH)) fifo_i (.wr_clk(clk_p) ,.rd_clk(clk_s), .rst_i(rst_i),.wr_en(wr_en_t),.wdata_i(d_i), .full_o(full_t), .rd_en(rd_en_t), .rdata_o(rdata_t), .empty_o(empty_t), .error_o(error_t));

/*always @(posedge clk_s) begin
	if (empty_t == 0) begin
	rd_en_t = 1;
end
	else begin
		rd_en_t = 0;
	end 
end*/

always @(posedge clk_s) begin
	if (rst_i == 0) begin
	case (state)
		S_FIFO_EMPTY : begin
			if (empty_t == 0) begin
			//rd_en_t = 1;
			next_state = S_READ_FROM_FIFO;
			end
			else begin
			next_state = S_FIFO_EMPTY;
			end
		end
		
		S_READ_FROM_FIFO : begin
			rd_en_t = 1;
			next_state = S_TRASMIT_INPROGRESS;
			count = 0;
		end
		
		S_TRASMIT_INPROGRESS : begin
			rd_en_t = 0;
			valid_o = 1;
			
			if (ready_i == 1) begin
			d_o = rdata_t[count];
				count = count + 1;
			end
			if (count == WIDTH) begin
				next_state = S_TRASMIT_DONE;
			end
			end
		
		S_TRASMIT_DONE : begin
			
			count = 0;
			d_o = 0;
			valid_o = 0;
			if (empty_t == 1 ) next_state = S_FIFO_EMPTY;
			else next_state = S_READ_FROM_FIFO;
			
		end
	endcase
	end

end

//logic for generating wr_en_t and ready_o

always @(posedge clk_p) begin
	if (rst_i== 1) begin
		state = S_FIFO_EMPTY;
		next_state = S_FIFO_EMPTY;
		count = 0; 
	end
	else begin
		if (full_t == 0 && valid_i == 1) begin
			wr_en_t = 1;
			ready_o = 1;
		end
		else begin
			wr_en_t = 0;
			ready_o = 0;
		end
	end
end
endmodule