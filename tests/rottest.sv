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
    .seq(4'b1000),   //input
    .len(24'd20),
    .seqOut(seqOut)  //output
  );

  reg signed [`BITS-1:0] envVal;
  envseq #(.DEPTH(4), .LEN(3), .TSCALE(5)) env1 (
    .clk(clk),
    .trigger(seqOut),
    .ena(1'b1),       //enable signal
    .rst(1'b0),       //reset signal
    .levels(12'hF25),
    .times(8'h34),
    .envOut(envVal)
    );


  initial begin
      $dumpfile("rot_test.lxt");
      $dumpvars(0,test);
      $display("Rotate Seq test");
     # 500 $finish;
  end



endmodule // test
