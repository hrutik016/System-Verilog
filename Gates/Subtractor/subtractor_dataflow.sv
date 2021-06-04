module half_subtrator_dataflow(
    input A,
    input B,
    output Borrow,
    output Diff
    );

assign Diff = A ^ B;
assign Borrow = ~A & B;

endmodule
