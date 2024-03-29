//iverilog -o rot.vvp rottest.sv ../bitseq.sv; vvp rot.vvp -lxt
//iverilog -g2012 -o env.vvp rottest.sv ../bitseq.sv ../envseq.sv; vvp env.vvp -lxt

`include "../globals.vh"

`timescale 10ns/1ns

module test;

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #1 clk = !clk;

  wire seqOut;

  bitseq #(.DEPTH(4)) r1
  (
    .clk(clk),       //clock signal
    .ena(1'b1),       //enable signal
    .rst(1'b0),       //reset signal
    .data_in(4'b1000),   //input
    .len(24'd1),
    .data_out(seqOut)  //output
  );

  reg signed [`BITS-1:0] envVal;
  env #(.DEPTH(4), .LEN(4), .TSCALE(1)) env1 (
    .clk(clk),
    .trigger(seqOut),
    .ena(1'b1),       //enable signal
    .rst(1'b0),       //reset signal
    .levels(16'hFAF1),
    .times(12'h324),
    .envOut(envVal)
    );


  initial begin
      $dumpfile("rot_test.lxt");
      $dumpvars(0,test);
      $display("Bit Seq test");
     # 300 $finish;
  end



endmodule // test
