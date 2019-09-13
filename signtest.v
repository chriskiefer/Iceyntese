`timescale 10ns/1ns

module test;

  reg signed [7:0] a = 126;
  reg signed [7:0] b = -120;
  reg signed [7:0] c;

  localparam x = $signed(2**4);

  initial begin
      $display("Signed tests");

      c = b-x;
      $display("%d", c);

      c = b>>2;
      $display("%d", c);

      c = b>>>2;
      $display("%d", c);

      c = a > x;
      $display("%d", c);


  end


endmodule // test
