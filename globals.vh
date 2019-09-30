`define BITS 16
`define FPWIDTH 16
`define FPF(n) (n * ((2.0 ** `FPWIDTH)-1))
`define MAXR (((2**`BITS)/2)-1)
`define FREQ(f) (`MAXR * (1.0-f))
`define SR 44100
`define MS(n) $rtoi(`SR/1000 * n)
`define CX wire signed [`BITS-1:0]
