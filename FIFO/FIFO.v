module sync_fifo(clk,rst,wr_valid,data_i,fifo_full, rd_valid, data_o,fifo_empty,error);

parameter width = 8;
parameter depth = 16;
parameter ptr_width = 4;
input clk,rst,wr_valid,rd_valid;
input [width-1:0] data_i;
output reg [width-1:0] data_o;
output reg fifo_full,fifo_empty,error;
integer i;

reg wr_toggle_f, rd_toggle_f;
reg [ptr_width-1:0] wr_ptr,rd_ptr;
reg [width-1:0] mem [depth-1:0];

always @(posedge clk) begin
if (rst==1) begin // all reg variable need to be reset to reset value(not always 0 but reset value
	fifo_full = 0;
	fifo_empty = 1; // 1 mean its empty
	error = 0;
	wr_ptr = 0;
	rd_ptr = 0;
	data_o = 0;
	wr_toggle_f = 0;
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
		if (rd_valid ==1) begin
			if (fifo_empty ==1) begin
				error = 1;
				$display("error:fifo is reading in empty");
			end
			else begin
				data_o = mem[rd_ptr]; //reading FIFO
				if(rd_ptr == depth-1) begin //rd_ptr is at last location
					rd_ptr = 0;
					rd_toggle_f = ~rd_toggle_f;
				end
				else begin
					rd_ptr = rd_ptr+1;
				end
			end
		end
	end
end
//generating empty and full condition
always @(wr_ptr or rd_ptr) begin
fifo_empty = 0;
fifo_full = 0;
	if (wr_ptr == rd_ptr && wr_toggle_f == rd_toggle_f) begin //both pointer are at same position and toggle flag also same mean MSB match so fifo is empty u cant read any more
		fifo_empty = 1;
		fifo_full = 0;
	end
	if (wr_ptr == rd_ptr && wr_toggle_f != rd_toggle_f) begin //both pointer are at same position and toggle flag are not same mean MSB mismatch so fifo is full, u cant write any more
		fifo_empty = 0;
		fifo_full = 1;
	end
end
endmodule
