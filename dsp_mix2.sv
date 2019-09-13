module dsp_mix2 (
  input signed [`BITS-1:0] sigIn1,
  input signed [`BITS-1:0] amp1,
  input signed [`BITS-1:0] sigIn2,
  input signed [`BITS-1:0] amp2,
  output signed [`BITS-1:0] sigOut
  );

//assign sigOut = - sigIn; // finish this

wire signed [`BITS-1:0] mix1, mix2;

dsp_mult m1(
  .x(sigIn1),
  .y(amp1),
  .prod(mix1)
  );

dsp_mult m2(
  .x(sigIn2),
  .y(amp2),
  .prod(mix2)
  );

dsp_addcl adder(
  .x(mix1),
  .y(mix2),
  .sum(sigOut)
  );

endmodule
