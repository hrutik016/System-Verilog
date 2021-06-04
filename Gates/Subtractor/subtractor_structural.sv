module hal_subtractor_structural( A, B, Diff, Borrow
    );

output Diff, Borrow;
input A, B;
wire abar;
xor(Diff, A, B);
not(abar,A);
and(Borrow,abar,B);

endmodule
