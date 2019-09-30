module bitseq #(
  parameter DEPTH = 4
)(
  input clk,       //clock signal
  input ena,       //enable signal
  input [DEPTH-1:0] seq,   //input
  input [23:0] len,
  output seqOut  //output
);

  reg trigger=1;
  reg [23:0] counter=0;
  reg seq_out=0;
  reg [DEPTH-1:0] bitmask = 1'b1 << DEPTH-1;


  //clock divider, output a trigger for the sequencer
  always @(posedge clk) begin
    if (ena) begin
      trigger <= (counter == len-1);
      counter <= counter + 1;
      if (counter == len - 1) begin
        counter <= 0;
      end
    end
  end


  always @(posedge trigger) begin
    seq_out <= (seq & bitmask) > 0;
    if (bitmask == 1) begin
      bitmask <= 1'b1 << DEPTH-1;
    end else begin
      bitmask <= bitmask >> 1;
    end
  end

  assign seqOut = seq_out & trigger;

endmodule
