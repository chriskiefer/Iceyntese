`include "../globals.vh"

`timescale 10ns/1ns

// `define BITS 12
// `define MAXR (((2**`BITS)/2)-1)

module test;

  reg signed [7:0] a;
  reg signed [7:0] b;
  reg signed [7:0] c;
  reg signed [15:0] ab;  // large enough for product

  localparam fp = 4;
  localparam sf = 2.0**-fp;  // Qx.fp scaling factor is 2^-fp
  localparam uf = 2.0 ** fp;

  reg signed [8:0] d;
  reg signed [`BITS-1:0] e;

  reg x;


  initial begin
      $display("Fixxed Point Examples");

      // a = 8'b0011_1010;  // 3.6250
      a = $rtoi(1.49 * uf);  // 3.6250
      b = $rtoi(0.5 * uf);  // 4.0625
      c = a + b;         // 0111.1011 = 7.6875
      $display("%f + %f = %f", $itor(a)*sf, $itor(b)*sf, $itor(c)*sf);

      a = $rtoi(0.125 * uf);  // 3.6250
      b = $rtoi(0.25 * uf);  // 0.5
      c = a + b;         //
      $display("%f + %f = %f", $itor(a)*sf, $itor(b)*sf, $itor(c)*sf);

      a = $rtoi(4 * uf);  // 3.6250
      b = $rtoi(1.9 * uf);  // 0.5
      ab = a * b;         //
      c = ab >> fp;
      $display("%f * %f = %f", $itor(a)*sf, $itor(b)*sf, $itor(c)*sf);

      a = -8'sd100;
      d = a;
      $display("%d %d", a, d);

      d = -120;
      a = d;

      $display("%d %d", d, a);

      d = -9'sd250;
      x = d < 130;

      $display("%d %d", d, x);

      e = ($rtoi($floor(0.9 * `MAXR)));

      $display("%d", e);

  end


endmodule // test
