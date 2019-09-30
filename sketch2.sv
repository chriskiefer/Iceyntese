module sketch (
  input dspclk,
  output signed [`BITS-1:0] sig
);


`CX squareWave;
osc_square sqosc_squareWave (
  .clk(dspclk),
  .waveLen(`FREQ(0.99)),
  .sigOut(squareWave)
  );


`CX lp1;
dsp_lowp lowp_lp1(
  .clk(dspclk),
  .sigIn(squareWave),
  .cutoff(`FPF(0.001)),
  .sigOut(lp1)
  );

wire seq1;
bitseq #(.DEPTH(8)) bitseq_seq1
(
  .clk(dspclk),
  .ena(1'b1),
  .seq(8'b10000100),
  .len(`MS(100)),
  .seqOut(seq1)
);

`CX envseq_es1;
envseq #(.DEPTH(4), .LEN(4), .TSCALE(300)) envseq_qes1 (
  .clk(dspclk),
  .trigger(seq1),     //1'b
  .ena(1'b1),
  .rst(1'b0),
  .levels(16'hFB20),      //LEN levels
  .times(12'h437),       //LEN-1 times
  .envOut(envseq_es1)
  );

`CX m2;
dsp_mult mult_m2 (
  .x(envseq_es1),
  .y(squareWave),
  .prod(m2)
  );

assign sig = m2;
endmodule
