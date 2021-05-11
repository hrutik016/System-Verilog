//ports

module memory(clk,rst,addr,wdata,rdata,wr_en,rd_en);

//input/out
input clk,rst;
input [6:0] addr;
input [7:0] wdata;
output reg [7:0] rdata;
input wr_en, rd_en;
integer i;
reg [7:0] mem [127:0];

always @(posedge clk) begin
	if (rst == 1) begin // every reg should be reset, not always zero 
		rdata = 0;
		for (i = 0; i <=127; i= i+1) begin 
			mem[i] = 0;
		end
	end
	else begin
		if (wr_en ==1) begin
			mem[addr] = wdata;
		end
		if (rd_en == 1) begin
			rdata = mem[addr];
		end
	end	
end
endmodule




