module xor_gate(a1, b1, c1);
	input a1, b1;
	output c1;
	assign c1 = a1 ^ b1;
endmodule

module and_gate(a2, b2, c2);
	input a2, b2;
	output c2;
	assign c2 = a2 & b2;
endmodule

module or_gate(a4, b4, c4);
	input a4, b4;
	output c4;
	assign c4 = a4 | b4;
endmodule

module not_gate(a3, b3);
	input a3;
	output b3;
	assign b3 = ~ a3;
endmodule

module half_subtractor(A, B, Diff,Borrow);
	input A, B;
	output Diff, Borrow;
	wire x;
	xor_gate u1(A, B, Diff);
	and_gate u2(x, B, Borrow);
	not_gate u3(A, x);
endmodule

module full_subtractor_structural(A,B,C,Diff,Borrow);
	input A, B ,C;
	output Diff, Borrow;
	wire x1, x2 ,x3;
	half_subtractor u4(A, B, x1, x2);
	half_subtractor u5(x1, C, Diff, x3);
	or_gate u6(x3,x2,borr);
endmodule
