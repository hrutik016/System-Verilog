module dual_port(clk,rst,wr_addr,rd_addr,wdata,rdata,wr_en,rd_en);

//input/out

parameter WIDTH = 8;
parameter DEPTH = 128;
parameter ADD_WIDTH = 7;

input clk,rst;
input [ADD_WIDTH-1:0] wr_addr;
input [ADD_WIDTH-1:0] rd_addr;
input [WIDTH-1:0] wdata;
output reg [WIDTH-1:0] rdata;
input wr_en, rd_en;

integer i;
reg [WIDTH-1:0] mem [DEPTH-1:0];

always @(posedge clk) begin
	if (rst == 1) begin // every reg should be reset, not always zero 
		rdata = 0;
		for (i = 0; i <=DEPTH-1; i= i+1) begin 
			mem[i] = 0;
		end
	end
	else begin
		if (wr_en == 1) begin
			mem[wr_addr] = wdata;
		end
		if (rd_en == 1) begin
			rdata = mem[rd_addr];
		end
	end	
end
endmodule




