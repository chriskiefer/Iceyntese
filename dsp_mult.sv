module dsp_mult (
  input signed [`BITS-1:0] x,
  input signed [`BITS-1:0] y,
  output reg signed [`BITS-1:0] prod
  );

reg signed[(`BITS*2)-1:0] result;

always @* begin
  result = x * y;
  prod = result >> `FPWIDTH;
end

endmodule
