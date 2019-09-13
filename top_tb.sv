`timescale 10ns/1ns
`define SIM

module test;


  initial begin
     # 150000 $finish;
  end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #1 clk = !clk;

  wire led1, led2, led8, ftdi;
  audioEngine testmod  (
    .clk(clk),
    // all LEDs
    .led1(led1),
    .led2(led2),
    .led8(led8),
    // UART lines
    .ftdi_tx(ftdi)
  );

  initial begin
     // $monitor("At time %t, clk = %b, clkout = %b",
              // $time, clk, clockOut);
    $dumpfile("top_test.lxt");
    $dumpvars(0,test);
  end


endmodule // test
