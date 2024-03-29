module dsp_lowp (
  input clk,
  input signed [`BITS-1:0] sigIn,
  input signed [`BITS-1:0] cutoff,
  output reg signed [`BITS-1:0] sigOut=0
  );

reg signed [`BITS-1:0] prev = 0;

reg signed [`BITS-1:0] y=0;

wire signed [`BITS-1:0] invCutoff;

assign invCutoff = `FPF(1.0) - cutoff;

wire [`BITS-1:0] p1, p2;

dsp_mult m1 (
  .x(sigIn),
  .y(cutoff),
  .prod(p1)
  );

dsp_mult m2 (
  .x(prev),
  .y(invCutoff),
  .prod(p2)
  );

`CX addOut;
dsp_addcl addcl_addOut (
  .x(p1),
  .y(p2),
  .sum(addOut)
  );

always @(posedge clk) begin
  y <= addOut;
  prev <= addOut;
  sigOut <= addOut;
end


endmodule
