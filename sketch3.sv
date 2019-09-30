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
  // e = (t<< (t[14:12])) ;
  // // w = (a[9:0] << 3) | {3{t[10..8]}} ;
  // a = e[9:0] << 4;
  // // a = {4{e[8:6]}} ^ {4{t[2:0]}};
  // // b = a * ((t[13] & t[12]) | ~t[11]);
  // b = a * ((t[12] & t[10]) | ~t[9] );
  // //
  // w = b ^ {2{t[5:0]}};

  // w = b;

  // b = |(t[15:11] & 5'b10101);
  // c = ~t[15:11] <<9;
  // a = (b * c) * (t[9:0] << 4);
  //
  // d = |(t[15:11] & 5'b01100);
  // e = ~t[15:11] <<9;
  // f = (e * d) & (t[9:0] << 4);
  //
  // // g = (t>> (t[14:12])) ;
  // // h = g[9:0] << 4;
  // g = (t <<  {t[15], t[13],t[10]}) ;
  // h = g[9:0] << 4;
  //
  // // w = (a + ~f ^ (h>>2));
  // // w = h + a;
  //
  // i = ({3{t[8],t[2],t[1]}} | {3{t[9],t[4],t[3]}}) <<4;
  // j = |(t[14:10] & 5'b01010);
  //
  // // w = ((i * j) >> 12) << 12;
  // u = (((noise_u + i)* j)>>2) + h + f;


  // u = {16{t[11]}};
  //arp octaves up
  // u = t[17:4] << 1;
  // v= t << (u >> 8);
  // x = v[10:0] << 5;

  //sqr wave arpeg
  a = (t[17:4]) << 1;
  b= t << (a >> 8);
  c = {16{b[11]}};

  d = (t[15:2]) << 5;
  e= t << (d >> 6);
  f = {16{e[11]}};

  u = (255-t[12:5]);
  v= t << (u >> 6);
  // x = (v[10:0] & 11'b10111001010)<< 5;
  x = (v[10:0])<< 5;

  w = (c>>2) + (x>>2) + (f>>2);

  g = |(t[15:11] & 5'b10101);
  h = ~t[15:11] <<9;
  i = (g * h) * (t[9:0] << 4);

  p=(i >> 2) + (x>>2) + (f>>2) + (c>>2);

  // w = (p | {2{p[7:0]}} >> 12) << 12;
  q = (p >> 12) << 12;
  // r = {16{t[15]}};
  // w = (p & r) + (x & ~r);
  w = q;


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
