//iverilog -o rot.vvp rottest.sv ../bitseq.sv; vvp rot.vvp -lxt

`timescale 10ns/1ns

module test;

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #1 clk = !clk;

  wire seqOut;

  bitseq #(.DEPTH(9)) r1
  (
    .clk(clk),       //clock signal
    .ena(1'b1),       //enable signal
    .rst(1'b0),       //reset signal
    .data_in(9'b100011001),   //input
    .len(24'd3),
    .data_out(seqOut)  //output
  );


  initial begin
      $dumpfile("rot_test.lxt");
      $dumpvars(0,test);
      $display("Rotate Seq test");
     # 300 $finish;
  end



endmodule // test
