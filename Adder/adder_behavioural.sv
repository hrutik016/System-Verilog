module half_adder_behavioural(
    input A,
    input B,
    output reg Sum,
    output reg Carry
    );

always @(A, B)
begin

	case ({A, B})
	2'b00 : begin
			Sum<=0;
			Carry<=0;
			end
	2'b01 : begin
			Sum<=1;
			Carry<=0;
			end
	2'b10 : begin
			Sum<=1;
			Carry<=0;
			end
	2'b11 : begin
			Sum<=1;
			Carry<=1;
			end
	default : begin
			Sum<=1;
			Carry<=1;
			end
	endcase
end
endmodule
module half_adder_behavioural(
    input A,
    input B,
    output reg Sum,
    output reg Carry
    );

always @(A, B)
begin

	case ({A, B})
	2'b00 : begin
			Sum<=0;
			Carry<=0;
			end
	2'b01 : begin
			Sum<=1;
			Carry<=0;
			end
	2'b10 : begin
			Sum<=1;
			Carry<=0;
			end
	2'b11 : begin
			Sum<=1;
			Carry<=1;
			end
	default : begin
			Sum<=1;
			Carry<=1;
			end
	endcase
end
endmodule
