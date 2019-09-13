module clockDivider (clockIn, clockOut);

parameter clockPeriod = 32'd10;
parameter initLevel = 1'b0;

// reg[15:0] period = clockPeriod;
input clockIn;
output clockOut;
reg clockOut;
reg [31:0] counter = 32'b0;

initial begin
  clockOut = initLevel;
end

always @ (posedge clockIn) begin
  counter <= counter + 1'b1;
  if (counter == clockPeriod-1) begin
    clockOut <= ~clockOut;
    counter <= 32'b0;
  end
end


endmodule
