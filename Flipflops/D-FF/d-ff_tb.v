`timescale 1ns/1ns
`include "d-ff_s.v"

module dff_tb;

    reg D = 0, CLK = 0;
    wire Q;

    dff DUT(D, CLK, Q);

    always begin
        CLK = ~CLK;
        #10;
    end

    initial begin
        $dumpfile("d-ff_tb.vcd");
        $dumpvars(0,dff_tb);
        D = 1; #40;
        D = 0; #40;
        $finish;
    end

endmodule