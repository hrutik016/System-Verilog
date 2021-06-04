module half_adder_tb;
	// Inputs
	reg A;
	reg B;
	
	// Outputs
	
	wire Sum;
	wire Carry;
	
	// Instantiate the Unit Under Test (UUT)
	
	half_adder1 uut (
		.A(A), 
		.B(B), 
		.Sum(Sum), 
		.Carry(Carry)
	);
	
	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;

		// Wait 100 ns for global reset to finish
		#10;
		
		A = 0;
		B = 1;
		#10;
		
		A = 1;
		B = 0;
		#10;
		
		A = 1;
		B = 1;
		#10; 	
		// Add stimulus her
	end
endmodule
