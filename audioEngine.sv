/*
synth module list:
oscillators: square, pulse, saw, tri, impulse, sine, wavetable, (blep)
white noise
mixer
amplifier
adder
decimator
distortion
envelope: AD, ASR,
FM
RBN

*/
`include "globals.vh"

module audioEngine (
    // input hardware clock (12 MHz)
    clk,
    // all LEDs
    led1,
    led2,
    led8,
    // UART lines
    ftdi_tx
    );

    // parameter FP = 7;
    // parameter FPfrom = 2.0**-FP;  //scale float from fp number
    // parameter FPscale = 2.0 ** FP; //scale float to FP number

    /* Clock input */
    input clk;

    /* LED outputs */
    output led1;
    reg led1;
    output led2;
    output led8;

    /* FTDI I/O */
    output ftdi_tx;

    `ifdef SIM
    parameter pllClockHz = 10000000;
    `else
    parameter pllClockHz = 120000000;
    `endif

    //audio engine
    parameter sampleRate = 16'd44100; //Hz
    parameter bufferSize = 16'd32; //warning: max buffer size
    reg [7:0] buffer [0:bufferSize-1];


    wire bufferStartClock;
    clockDivider #(
      .clockPeriod($rtoi(pllClockHz /  (sampleRate/bufferSize) / 2)),
      .initLevel(1'b1)) dspBufferStartClock  (
      // clockDivider #(.clockPeriod(hx8kInternalClockHz /  (sampleRate/bufferSize) / 2)) dspBufferStartClock  (
        .clockIn(clk),
        .clockOut(bufferStartClock)
    );

    assign led8 = bufferStartClock;


    /* UART registers */
    reg [7:0] uart_txbyte = 8'd0;
    reg uart_send = 1'b0;
    wire uart_txed;

    reg [7:0] bufferPosition = 8'd0;



    /* UART transmitter module designed for
       8 bits, no parity, 1 stop bit.
    */
    wire uartClockOut;
    // clockDivider #(.clockPeriod($rtoi(pllClockHz /  115200 / 2))) uartClock  (
      clockDivider #(.clockPeriod(pllClockHz /  921600 / 2)) uartClock  (
        .clockIn(clk),
        .clockOut(uartClockOut)
    );

    uart_tx_8n1 transmitter (
        // 9600 baud rate clock
        .clk (uartClockOut),
        // byte to be transmitted
        .txbyte (uart_txbyte),
        // trigger a UART transmit on baud clock
        .senddata (uart_send),
        // input: tx is finished
        .txdone (uart_txed),
        // output UART tx pin
        .tx (ftdi_tx)
    );


    wire dspClock;
    clockDivider #(
      .clockPeriod($rtoi(pllClockHz /  500000 / 2))
      ) dspSynthesisClock  (
        .clockIn(clk),
        .clockOut(dspClock)
    );


    reg dspEnabled = 0;
    wire dspClockWtEnable;
    assign dspClockWtEnable = dspEnabled && dspClock;
    reg dspBufferReady=1'd0;

    // reg [15:0] wl = 16'd600;
    wire signed [`BITS-1:0] squareWave;
    wire signed [`BITS-1:0] squareWave2, saw1, saw2, seqOut;
    wire [`BITS-1:0] inverted;
    wire [`BITS-1:0] w;



    seq3 sq (
      .clk(dspClockWtEnable),
      .l0(`FREQ(0.5)),
      .l1(`FREQ(0.7)),
      .l2(`FREQ(0.2)),
      .sigOut(seqOut)
      );

    osc_square sqosc (
      .clk(dspClockWtEnable),
      .waveLen(seqOut),
      .sigOut(squareWave)
      );

    osc_square sqosc2 (
      .clk(dspClockWtEnable),
      .waveLen(`FREQ(0.31)),
      .sigOut(squareWave2)
      );
    //
    // osc_saw sawOsc2 (
    //   .clk(dspClockWtEnable),
    //   .phaseInc(16'd),
    //   .sigOut(saw2)
    //   );
    //
    // osc_saw saw (
    //   .clk(dspClockWtEnable),
    //   .phaseInc(`BITS'sd20),
    //   .sigOut(saw1)
    //   );

    wire [`BITS-1:0] addClOut;
    dsp_addcl addcl (
      .x(squareWave),
      .y(squareWave2),
      .sum(addClOut)
      );

    // wire [`BITS-1:0] m1;
    // dsp_mult mult (
    //   .x(addClOut),
    //   .y(`FPF(0.5)),
    //   .prod(m1)
    //   );


    // wire [`BITS-1:0] lowpOut;
    // dsp_lowp lowp(
    //   .clk(dspClockWtEnable),
    //   .sigIn(addClOut),
    //   .cutoff(`FPF(0.005)),
    //   .sigOut(lowpOut)
    //   );

    wire [`BITS-1:0] highpOut;
    dsp_highp highp(
      .clk(dspClockWtEnable),
      .sigIn(addClOut),
      .cutoff(`FPF(0.1)),
      .sigOut(highpOut)
      );

    // wire [`BITS-1:0] noiseGOut, noiseUOut;
    // LFSR_Plus #(.W(`BITS), .V(18), .g_type(0), .u_type(1)) noiseGen
    // 	(
    // 		.g_noise_out(noiseGOut),
    // 		.u_noise_out(noiseUOut),
    // 		.clk(dspClockWtEnable),
    // 		.n_reset(1'b1),
    // 		.enable(1'b1)
    // 	);

    assign w = squareWave;

    // wire signed[7:0] mixOut;
    // reg signed[7:0] a1 = $rtoi(0.3 * FPscale);
    // reg signed[7:0] a2 = $rtoi(0.4 * FPscale);
    //
    // dsp_mix2 mixer(
    //   .sigIn1(squareWave),
    //   .amp1(a1),
    //   .sigIn2(squareWave2),
    //   .amp2(a2),
    //   .sigOut(mixOut)
    //   );
    //
    // assign w = mixOut;

    // assign inverted = - squareWave;



    // wire signed [7:0] m1res;
    // reg signed[7:0] scale1 = $rtoi(0.5 * FPscale);
    // dsp_mult m1 (
    //   .x(inverted),
    //   .y(scale1),
    //   .prod(m1res)
    //   );

    // assign w = m1res;

    always @(posedge uart_txed) begin
        led1 <= ~led1;
    end

    parameter DSP_WAITING=8'd0;
    parameter DSP_PROCESSING = 8'd1;
    parameter DSP_DONE = 8'd2;
    reg[7:0] dspState = DSP_WAITING;
    reg[7:0] dspCounter = 0;

    always @(posedge dspClock) begin
      if (dspState == DSP_WAITING && bufferStartClock) begin
        dspState <= DSP_PROCESSING;
        dspEnabled <= 1'b1;
      end else if (dspState == DSP_PROCESSING) begin
        buffer[dspCounter] <= w >>> (`BITS-8);
        dspCounter <= dspCounter + 8'd1;
        if (dspCounter == bufferSize-1) begin
          dspState <= DSP_DONE;
          dspEnabled <= 1'b0;
          dspBufferReady <= 1'd1;
        end
      end else if (dspState == DSP_DONE && !bufferStartClock) begin
        dspState <= DSP_WAITING;
        dspCounter <= 8'd0;
      end
    end

    parameter STATE_WAITING=8'd0;
    parameter STATE_PREPARE=8'd1;
    parameter STATE_SENDING=8'd2;
    parameter STATE_COMPLETED=8'd3;

    /* State variables */
    reg[7:0] state=STATE_WAITING;

    reg[7:0] frameCount = 8'd0;

    always @(negedge uartClockOut) begin
      if (state == STATE_WAITING && (dspState == DSP_DONE || dspState == DSP_WAITING) && dspBufferReady) begin
          state <= STATE_SENDING;
      end
      if (state == STATE_SENDING) begin
        uart_send <= 1'b1;
      end
      if (state == STATE_SENDING && uart_txed) begin
        bufferPosition <= bufferPosition + 8'b1;
        uart_txbyte <= buffer[bufferPosition];
        if (bufferPosition == bufferSize-1) begin
          state <= STATE_COMPLETED;
          uart_send <= 1'b0;
          bufferPosition <= 8'b0;
        end
      end
      if (state == STATE_COMPLETED && bufferStartClock == 1'b0) begin
        state <= STATE_WAITING;
        frameCount <= frameCount + 8'b1;
        // buffer[0] <= frameCount;
      end
    end

endmodule
