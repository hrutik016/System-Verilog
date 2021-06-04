module half_subtractor_behioural(output reg Diff, Borrow, input A, B)
    );

always @(*)
begin
	Diff = A ^ B;
	Borrow = ~A & B;

end
endmodule
