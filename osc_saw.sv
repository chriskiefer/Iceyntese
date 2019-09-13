module osc_saw (
  input clk,
  input signed [`BITS-1:0] phaseInc, //as proportion of 2^(BITS-2) max phase
  output reg signed [`BITS-1:0] sigOut = 0
  );

// localparam signedBase = -(2 ** (`BITS-1));
localparam signedMax = $signed(2** (`BITS-1));


reg signed [`BITS:0] phase = 0;

always @(posedge clk) begin
  if (phase >= signedMax-1) begin
    phase <= phase - (signedMax-1);
  end else begin
    phase <= phase + phaseInc;
  end
  sigOut <= phase;
end


endmodule
