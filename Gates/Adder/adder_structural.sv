nmodule half_adder_structural(
    input A,
    input B,
    output Sum,
    output Carry
    );

xor2 x1(A, B , Sum);
and2 a1(.I1(A),.I2(B),.Out_A(Carry));
endmodule

module xor2(input I1, input I2, output Out_X);
assign Out_X = I1 ^ I2;
endmodule

module and2(input I1, input I2, output Out_A);
assign out_A = I1 & I2;
endmodule
