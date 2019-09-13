module dsp_invert (
  input [7:0] sigIn,
  output [7:0] sigOut
  );

assign sigOut = - sigIn;

endmodule
