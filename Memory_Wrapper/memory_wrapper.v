module memory_wrapper(clk,rst,addr,wdata,rdata,wr_en,rd_en);

//input/out

parameter WIDTH = 8;
parameter DEPTH = 128;
parameter ADD_WIDTH = 7;
parameter MEM_NUMBER = 8;

input clk,rst;
input [ADD_WIDTH-1:0] addr;
input [WIDTH*MEM_NUMBER-1:0] wdata;
output reg [WIDTH*MEM_NUMBER-1:0] rdata;
input wr_en, rd_en;

generate
genvar i;
for (i = 0; i < MEM_NUMBER; i= i+1) begin
	memory mem_i1(clk,rst,addr,wdata[(i+1)*WIDTH-1:i*WIDTH],rdata[(i+1)*WIDTH-1:i*WIDTH],wr_en,rd_en); 
end 
endgenerate

endmodule






