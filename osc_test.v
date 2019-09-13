`timescale 10ns/1ns

module test;

  localparam fp = 7;
  localparam sf = 2.0**-fp;  // Qx.fp scaling factor is 2^-fp
  localparam uf = 2.0 ** fp;


  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #1 clk = !clk;

  reg [15:0] wl = 16'd200;
  wire [7:0] squareWave;

  osc_square sqosc (
    .updateSig(clk),
    .waveLen(wl),
    .sigOut(squareWave)
    );

    initial begin
        $dumpfile("osc_test.vcd");
        $dumpvars(0,test);
    end

    initial begin
        $display("OSC test");
       # 1000 $finish;
    end


endmodule // test
