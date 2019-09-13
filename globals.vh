`define BITS 12
`define FPWIDTH 9  // range +/- 3.999
`define FPF(n) (n * (2.0 ** `FPWIDTH))
`define MAXR (((2**`BITS)/2)-1)
`define FREQ(f) (`MAXR * f)
// `define CX wire [`BITS-1:0]



// module globals ();
// parameter BD = 8;
// parameter FP = 7;
// endmodule
