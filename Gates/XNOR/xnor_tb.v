`include "xnor.v"

module xnor_tb();

    reg a, b;
    wire out;

    xnor_gate G1(a, b, out);

    initial begin

        $dumpfile("xnor_tb.vcd");
        $dumpvars(0,xnor_tb);

        a = 0; b = 0; #10;
        a = 1; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 1; #10;
    end
endmodule