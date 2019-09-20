module seq3 (
  input clk,
  input signed [`BITS-1:0] l0,
  input signed [`BITS-1:0] l1,
  input signed [`BITS-1:0] l2,
  input signed [23:0] len,
  output reg signed [`BITS-1:0] sigOut = 0
  );


reg [23:0] counter = 0;
reg [1:0] step = 0;

always @(posedge clk) begin
  counter <= counter + 1;
  case(step)
    2'd0: sigOut <= l0;
    2'd1: sigOut <= l1;
    2'd2: sigOut <= l2;
    default: sigOut <= l0;
  endcase
  if (counter ==  len) begin
    counter <= 0;
    if (step == 2) begin
      step <= 0;
    end else begin
      step <= step +1;
    end
  end
end


endmodule
