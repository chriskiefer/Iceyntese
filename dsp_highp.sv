module dsp_highp (
  input clk,
  input signed [`BITS-1:0] sigIn,
  input signed [`BITS-1:0] cutoff,
  output reg signed [`BITS-1:0] sigOut=0
  );

reg signed [`BITS-1:0] xm1 = 0;
reg signed [`BITS-1:0] ym1 = 0;

wire [`BITS-1:0] p1;

dsp_mult m1 (
  .x(ym1),
  .y(cutoff),
  .prod(p1)
  );


always @(posedge clk) begin
  ym1 <= sigIn - xm1 + p1;
  xm1 <= sigIn;
  sigOut <= ym1;
end


endmodule
