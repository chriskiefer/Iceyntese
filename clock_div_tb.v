`timescale 10ns/1ns

module test;


  initial begin
     # 200 $finish;
  end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #5 clk = !clk;

  wire clockOut;
  clockDivider #(.clockPeriod(3)) testClock  (
      .clockIn(clk),
      .clockOut(clockOut)
  );

  initial begin
     $monitor("At time %t, clk = %b, clkout = %b",
              $time, clk, clockOut);
    $dumpfile("clock_div_test.lxt");
    $dumpvars(0,test);
  end


endmodule // test
