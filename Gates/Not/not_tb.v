`include "not.v"

module not_tb();

    reg a;
    wire out;

    not_gate N1(a, out);

    initial begin
        
        $dumpfile("not_tb.vcd");
        $dumpvars(0, not_tb);

        a = 0; #10;
        a = 1; #10;

    end

endmodule