module async_fifo(wr_clk,rd_clk,rst,wr_valid,data_i,fifo_full, rd_valid, data_o,fifo_empty,error);


parameter width = 8;
parameter depth = 16;
parameter ptr_width = 4;
input wr_clk,rd_clk,rst,wr_valid,rd_valid;
input [width-1:0] data_i;
output reg [width-1:0] data_o;
output reg fifo_full,fifo_empty,error;
integer i;


reg wr_toggle_rd, rd_toggle_wr;
reg wr_toggle_f, rd_toggle_f;
reg [ptr_width-1:0] wr_ptr,rd_ptr;
reg [ptr_width-1:0] wr_ptr_rd_clk,rd_ptr_wr_clk;
reg [width-1:0] mem [depth-1:0];

always @(posedge wr_clk) begin
	if (rst==1) begin // all reg variable need to be reset to reset value(not always 0 but reset value
		fifo_full = 0;
		fifo_empty = 1; // 1 mean its empty
		error = 0;
		wr_ptr = 0;
		wr_ptr_rd_clk = 0;
		rd_ptr = 0;
		rd_ptr_wr_clk = 0;
		data_o = 0;
		wr_toggle_f = 0;
		wr_toggle_rd = 0;
		rd_toggle_wr = 0;
		rd_toggle_f = 0;
		for (i = 0; i < depth-1 ; i=i+1) begin
		mem[i] = 0;
		end
	end
	else begin	
	error = 0;
		if (wr_valid == 1) begin
			if ( fifo_full == 1) begin
				error = 1;
				$display("Error : writing to the full FIFO");				
			end
			else begin
				mem[wr_ptr] = data_i; //FIFO writing
				if (wr_ptr == depth-1) begin //last pointer location
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
	if (rst == 0) begin
		error = 0;
		if (rd_valid ==1) begin
			if (fifo_empty ==1) begin
				error = 1;
				$display("error:fifo is reading in empty");
			end
			else begin
			
				data_o = mem[rd_ptr]; //reading FIFO
				//rd_ptr = 0;			
			if(rd_ptr == depth-1) begin //rd_ptr is at last location
					rd_toggle_f = ~rd_toggle_f;
					rd_ptr = 0;
				end
				else begin
				rd_ptr = rd_ptr+1;
				end
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
	fifo_full = 1;
	end
	else begin
	fifo_full = 0;
	end
	
end
always @(rd_ptr or wr_ptr_rd_clk) begin
	if (wr_ptr_rd_clk == rd_ptr && wr_toggle_rd == rd_toggle_f) begin //both pointer are at same position and toggle flag also same mean MSB match so fifo is empty u cant read any more
	fifo_empty = 1;
	end
	else begin
	fifo_empty = 0;
	end
	end
endmodule
