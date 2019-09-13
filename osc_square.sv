module osc_square (
  input clk,
  input signed [`BITS-1:0] waveLen,
  output reg signed [`BITS-1:0] sigOut = ((2**`BITS)/2)-1
  );

reg signed [`BITS:0] phase = 0;

always @(posedge clk) begin
  if (phase >= ((waveLen)-1)) begin
    sigOut <= sigOut * -1;
    phase <= 0;
  end else begin
    phase <= phase + 1;
  end
end


endmodule
