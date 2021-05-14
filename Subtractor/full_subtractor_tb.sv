`timescale 1ns / 1ps
module full_subtractor_tb;

// Inputs

reg a;
reg b
reg c;

// Outputs

wire diff;
wire borr;

// Instantiate the Unit Under Test (UUT)

full_subtractor uut (
.a(a),
.b(b),
.c(c),
.diff(diff),
.borr(borr)
);

initial begin

// Initialize Inputs

a = 0;
b = 0;
c = 0;

#10;

a = 1;
b = 0;
c = 0;

#10;

a = 0;
b = 1;
c = 0;

#10;

a = 1;
b = 1;
c = 0;

#10;

a = 0;
b = 0;
c = 1;

#10;

a = 1;
b = 0;
c = 1;

#10;

a = 0;
b = 1;
c = 1;

#10;

a = 1;
b = 1;
c = 1;
#10;

// Add stimulus here

end
endmodule
