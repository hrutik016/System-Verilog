module async_fifo(wr_clk,rd_clk,rst_i,wr_en,wdata_i,full_o, rd_en, rdata_o,empty_o,error_o);

parameter WIDTH = 8;
parameter DEPTH = 16;
parameter ptr_WIDTH = 4;
input wr_clk,rd_clk,rst_i,wr_en,rd_en;
input [WIDTH-1:0] wdata_i;
output reg [WIDTH-1:0] rdata_o;
output reg full_o,empty_o,error_o;
integer i;


reg wr_toggle_rd, rd_toggle_wr;
reg wr_toggle_f, rd_toggle_f;
reg [ptr_WIDTH-1:0] wr_ptr,rd_ptr;
reg [ptr_WIDTH-1:0] wr_ptr_rd_clk,rd_ptr_wr_clk;
reg [WIDTH-1:0] mem [DEPTH-1:0];

always @(posedge wr_clk) begin
	if (rst_i==1) begin // all reg variable need to be reset to reset value(not always 0 but reset value
		full_o = 0;
		empty_o = 1; // 1 mean its empty
		error_o = 0;
		wr_ptr = 0;
		wr_ptr_rd_clk = 0;
		rd_ptr = 0;
		rd_ptr_wr_clk = 0;
		rdata_o = 0;
		wr_toggle_f = 0;
		wr_toggle_rd = 0;
		rd_toggle_wr = 0;
		rd_toggle_f = 0;
		for (i = 0; i < DEPTH-1 ; i=i+1) begin
			mem[i] = 0;
		end
	end
	else begin	
	error_o = 0;
		if (wr_en == 1) begin
			if ( full_o == 1) begin
				error_o = 1;
				$display("Error : writing to the full FIFO");				
			end
			else begin
				mem[wr_ptr] = wdata_i; //FIFO writing
				if (wr_ptr == DEPTH-1) begin //last pointer location
					wr_toggle_f = ~wr_toggle_f; // toggle when fifo is full 
					wr_ptr = 0; // going back to the begining
				end
				else begin  
					wr_ptr = wr_ptr + 1; // moving to next location
				end			
			end
		end
	end
end

always @(posedge rd_clk) begin
	if (rst_i == 0) begin
		error_o = 0;
		if (rd_en ==1) begin
			if (empty_o ==1) begin
				error_o = 1;
				$display("error:fifo is reading in empty");
			end
			else begin
			
				rdata_o = mem[rd_ptr]; //reading FIFO
				//rd_ptr = 0;	
				rd_ptr = rd_ptr+1;
								
			if(rd_ptr == DEPTH-1) begin //rd_ptr is at last location
					rd_toggle_f = ~rd_toggle_f;
					rd_ptr = 0;
				end
				//else begin
				//end
			end
		end
end
end

always@(posedge wr_clk) begin
rd_ptr_wr_clk <= rd_ptr;
rd_toggle_wr <= rd_toggle_f;
end

always@(posedge rd_clk) begin
wr_ptr_rd_clk <= wr_ptr;
wr_toggle_rd <= wr_toggle_f;
end
//generating empty and full condition
always @(wr_ptr or rd_ptr_wr_clk) begin

	if (wr_ptr == rd_ptr_wr_clk && wr_toggle_f != rd_toggle_wr) begin  //both pointer are at same position and toggle flag are not same mean MSB mismatch so fifo is full, u cant write any more
	full_o = 1;
	end
	else begin
	full_o = 0;
	end
	
end
always @(rd_ptr or wr_ptr_rd_clk) begin
	if (wr_ptr_rd_clk == rd_ptr && wr_toggle_rd == rd_toggle_f) begin //both pointer are at same position and toggle flag also same mean MSB match so fifo is empty u cant read any more
	empty_o = 1;
	end
	else begin
	empty_o = 0;
	end
	end
endmodule
