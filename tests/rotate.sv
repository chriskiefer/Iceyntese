`timescale 10ns/1ns

module bitrotate #(
  parameter DEPTH = 16
)(
  input clk,       //clock signal
  input ena,       //enable signal
  input rst,       //reset signal
  input [DEPTH-1:0] data_in,   //input
  output data_out  //output
);

  reg [REG_DEPTH-1:0] data;

  initial begin
    data = data_in;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin //asynchronous reset
      // data_reg <= {REG_DEPTH{1'b0}}; //load REG_DEPTH zeros
      data <= data_in;
    end else if (enable) begin
      data <= {data[REG_DEPTH-2:0], data[REG_DEPTH-1]};
    end
  end

  assign data_out = data[REG_DEPTH-1]; //MSB is an output bit

endmodule

module test;

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #1 clk = !clk;

  wire seqOut;

  bitrotate #(.DEPTH(4)) r1 (
    .clk(clk),
    .ena(1'b1),
    .rst(1'b0),
    .data_in(4'b1010),
    .data_out(seqOut)
    );

  initial begin
      $dumpfile("osc_test.vcd");
      $dumpvars(0,test);
  end

  initial begin
      $display("Rotate test");
     # 100 $finish;
  end


endmodule // test
