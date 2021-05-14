`include "asyn_fifo.v" 

module sipo (rst_i, pclk_i, pdata_i, pvalid_i, pready_o, sclk_i,sdata_o,pvalid_o,sready_i);

parameter WIDTH = 8;
parameter S_IDLE = 2'b00;
parameter S_DATA_TRANSFER = 2'b01;
parameter S_WRITE_FIFO = 2'b10;
parameter P_IDLE = 2'b00;
parameter P_READ_FIFO = 2'b01;
parameter P_READ_PENDING = 2'b10;

input pclk_i,rst_i, pvalid_i;
input [WIDTH-1:0] pdata_i;
output reg sdata_o;
output reg svalid_o, pready_o;
input sclk_i,sready_i;

reg sdata_t;
reg [WIDTH-1:0] wdata_t;
wire full_t,empty_t, error_t;
reg rd_fifo, wr_fifo;
wire [WIDTH-1:0] rddata_t;
reg [1:0] state, next_state;
reg [1:0] pstate, next_pstate;
integer count;


async_fifo async_fifo_i (.wr_clk(pclk_i),.rd_clk(sclk_i),.rst_i(rst_i),.wr_en(wr_fifo), .wdata_i(wdata_t) , .full_o(full_t), .rd_en(rd_fifo), 
.rdata_o(rddata_t), .empty_o(empty_t), .error_o(error_t));

always @(next_state) begin
state = next_state;
end

always @(next_pstate) begin
pstate = next_pstate;
end

always @(posedge pclk_i) begin
	if (rst_i == 1) begin
		sdata_t = 0;
		wdata_t = 0;
		{rd_fifo, wr_fifo} = 0;
		pready_o = 0;
		sdata_o = 0;
		svalid_o = 0;
		state = S_IDLE;
		next_state = S_IDLE;
		pstate = P_IDLE;
		next_pstate = S_IDLE;
		
	end
	else begin
		case (state)
			P_IDLE : begin
			wr_fifo = 0;
			wdata_t = 0;
			if (pvalid_i) begin
				pready_o = 1;
				next_state = S_DATA_TRANSFER;
				sdata_t = rddata_t[count];
				count = 0;					
			end
			end
			
			S_DATA_TRANSFER : begin
			wr_fifo = 0;
			if (pvalid_i) begin
			pready_o = 1;
			sdata_t = rddata_t[count];
			//$display("seriel data = %b", sdata_i);
			end
			count = count +1;
				if (count == WIDTH) begin
				next_state = S_WRITE_FIFO;
				pready_o = 0;
				count = 0;
				end
			end
			
			S_WRITE_FIFO : begin
				if (full_t == 0) begin
					wr_fifo = 1;
					wdata_t = pdata_i;
					pready_o = 0;
					if (pvalid_i) begin
						next_state = S_DATA_TRANSFER;
					end
					else begin
						next_state = S_IDLE;
					end
				end
			end
		endcase
	end
end

always @(posedge pclk_i) begin
	if (rst_i == 0) begin
		case (pstate) 
		
			P_IDLE : begin
				if (empty_t == 0) begin
					rd_fifo = 1;
					next_pstate = P_READ_FIFO; 
				end
			end
			
			P_READ_FIFO : begin
			
				rd_fifo =0;
				next_pstate = P_READ_PENDING;
			end
			
			P_READ_PENDING : begin
				sdata_o = sdata_t;
				svalid_o = 1;
				if (sready_i == 1) begin
				next_pstate = P_IDLE;
				pvalid_o = 0;
				pdata_o = 0;
				//rddata_t = 0;
				end
			end
		endcase
	end
end
endmodule
