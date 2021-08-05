`include "SR_ff.v"

module srff_tb;

    //inputs
    reg s, r, clk, clr, preset;

    //outpts
    wire q, qbar;

    //instantiate UUT
    srff uut(
        .q(q),
        .qbar(qbar),
        .s(s),
        .r(r),
        .clk(clk),
        .clr(clr),
        .preset(preset) 
    );

    initial begin
      s = 0;
      r = 0; 
      clk = 0;
      clr = 1'b1;
      #10 preset = 1'b1;
      #10 preset = 1'b0;

      $dumpfile("SR_ff_tb.vcd");
      $dumpvars(0,srff_tb);
    end

    always #2 {s, r} = {s, r} + 1'b1;
    
    always #1 clk = ~clk;
    
    initial  #10 clk = ~clk;

    initial #10 clr = 1'b0;

    initial #200 $finish;

endmodule