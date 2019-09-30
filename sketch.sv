module sketch (
  input dspclk,
  output reg signed [`BITS-1:0] sig
);

`CX noise_g, noise_u;
LFSR_Plus #(.W(`BITS), .V(18), .g_type(0), .u_type(1)) noiseGen
  (
    .g_noise_out(noise_g),
    .u_noise_out(noise_u),
    .clk(dspclk),
    .n_reset(1'b1),
    .enable(1'b1)
  );

reg[31:0] t=0;
always @(posedge dspclk) t <= t + 1;

reg[`BITS-1:0] w, a,b,c,d,e,f, g,h,i,j,k,l,m,n,o,p,q,r,s,u,v,x,y,z, pw=0;

always @* begin

  a = (t[17:4]) << 1;
  b= t << (a >> 8);
  c = {16{b[11]}};

  d = (t[15:2]) << 5;
  e= t << (d >> 6);
  f = {16{e[11]}};

  u = (255-t[12:5]);
  v= t << (u >> 6);
  y = (v & 12'b01011010110) << 4;
  x = (y[11:0])<< 4;


  g = |(t[15:10] & 6'b101001);
  h = ~t[15:10] <<8;
  i = (g * h) * (t[9:0] << 4);

  p = ((x>>2) & (|t[16:13]<< 10)) + (c>>2) + (f>>2) + (i>>2);

  r = {4{t[15:12]}};
  u = (p>>12) << 12;

  w = (u & r) + (x & ~r);
end

always @* begin
  // sig = ~(w) + 1;
  sig = w - 2**(`BITS-1);
end

always @(posedge dspclk) begin
  pw <= w;
end

// assign sig = w;
endmodule
