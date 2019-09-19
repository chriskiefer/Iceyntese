module bitrotate #(
  parameter DEPTH = 16
)(
  input clk,       //clock signal
  input ena,       //enable signal
  input rst,       //reset signal
  input [DEPTH-1:0] data_in,   //input
  output data_out  //output
);

  reg [DEPTH-1:0] data;

  initial begin
    data = data_in;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin //asynchronous reset
      // data_reg <= {REG_DEPTH{1'b0}}; //load REG_DEPTH zeros
      data <= data_in;
    end else if (ena) begin
      data <= {data[DEPTH-2:0], data[DEPTH-1]};
    end
  end

  assign data_out = data[DEPTH-1]; //MSB is an output bit

endmodule
