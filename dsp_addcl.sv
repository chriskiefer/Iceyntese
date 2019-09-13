module dsp_addcl (
  input signed [`BITS-1:0] x,
  input signed [`BITS-1:0] y,
  output reg signed [`BITS-1:0] sum
  );

reg signed [`BITS:0] total;
localparam maxSigned = ((2** `BITS) / 2) -1;
localparam minSigned = ((2** `BITS) / -2);

always @* begin
  total = x + y;
  if (total > maxSigned) begin
    sum = maxSigned;
  end else
  if (total < minSigned) begin
    sum = minSigned;
  end else begin
    sum = total;
  end
end

endmodule
