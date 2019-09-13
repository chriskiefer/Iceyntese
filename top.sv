/*
(c) Chris Kiefer 2019
Licensed under CERN OHL v.1.2 or later”
*/

module top (
    // input hardware clock (12 MHz)
    input hwclk,
    // all LEDs
    output led1,
    output led2,
    output led8,
    // UART lines
    output ftdi_tx
    );

    wire dummy_out1, dummy_out2, int_clk;
    wire bypass, lock1;
    wire nrst;

    assign nrst = 1'b1;
    assign bypass = 1'b0;

    //high res clock for high speed uart
    SB_PLL40_CORE #(.FEEDBACK_PATH("SIMPLE"), .PLLOUT_SELECT("GENCLK"),
 		   .DIVR(4'b0000), .DIVF(7'b1001111), .DIVQ(3'b011),
 		   .FILTER_RANGE(3'b001)
    ) mypll1 (.REFERENCECLK(hwclk),
 	    .PLLOUTGLOBAL(dummy_out1), .PLLOUTCORE(int_clk), .LOCK(lock1),
 	    .RESETB(nrst), .BYPASS(bypass));


    audioEngine audio(
      .clk(int_clk),
      .led1(led1),
      .led2(led2),
      .led8(led8),
      .ftdi_tx(ftdi_tx)
      );


endmodule
