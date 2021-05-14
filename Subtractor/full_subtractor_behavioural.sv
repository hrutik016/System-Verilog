module full_subtractor_behavioural
(input [2:0]a,
	output reg [1:0]D);
always @(a)
begin
	case (a )
	3'b000 : D <= 2'b00;
	3'b001 : D <= 2'b11;
	3'b010 : D <= 2'b11;
	3'b011 : D <= 2'b01;
	3'b100 : D <= 2'b10;
	3'b101 : D <= 2'b00;
	3'b110 : D <= 2'b00;
	3'b111 : D <= 2'b11;
endcase
end
endmodule
