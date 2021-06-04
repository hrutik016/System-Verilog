module half_subtractor_dataflow(A,B,Diff,Borrow);
    input A, B;
	 output Diff, Borrow;
	 assign Diff = A ^ B;
	 assign Borrow = ~A & B;
endmodule


module full_subtractor_dataflow(A,B,C,Diff,Borrow);
    input A, B,C;
	 output Diff, Borrow;
	 wire x1,x2,x3;	

	 half_subtractor_dataflow h1(A,B,x1,x2);
	 half_subtractor_dataflow h2(x1,C,Diff,x3);
	 assign Borrow = x3 | x2;
endmodule
