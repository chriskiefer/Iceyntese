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

    /* Clock input */
    input clk;

    /* LED outputs */
    output led1;
    reg led1;
    reg led2val = 1'b1;
    output led2;
    assign led2=led2val;
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
    reg signed [7:0] buffer [0:bufferSize-1];


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
    wire dspclk;
    assign dspclk = dspEnabled && dspClock;
    reg dspBufferReady=1'd0;

    // reg [15:0] wl = 16'd600;
    wire signed [`BITS-1:0] squareWave2, saw1, saw2, seqOut;
    wire [`BITS-1:0] inverted;
    wire [`BITS-1:0] w;

    sketch livesketch(
      .dspclk(dspclk),
      .sig(w)
      );

    // `CX seqOut3;
    // seq3 seq3_seqOut3 (
    //   .clk(dspclk),
    //   .l0(`FREQ(0.9)),
    //   .l1(`FREQ(0.5)),
    //   .l2(`FREQ(0.92)),
    //   .len(`MS(200)),
    //   .sigOut(seqOut3)
    //   );
    //
    // `CX seqOut3LP;
    // dsp_lowp lowp_seqOut3(
    //   .clk(dspclk),
    //   .sigIn(seqOut3),
    //   .cutoff(`FPF(0.001)),
    //   .sigOut(seqOut3LP)
    //   );

    // `CX squareWave;
    // osc_square sqosc_squareWave (
    //   .clk(dspclk),
    //   .waveLen(`FREQ(0.5)),
    //   .sigOut(squareWave)
    //   );

    // `CX sqdetune;
    // dsp_mult mult_sqdetune (
    //   .x(seqOut3LP),
    //   .y(`FPF(1.3)),
    //   .prod(sqdetune)
    //   );
    //
    // `CX sqr2;
    // osc_square sqosc_sqr2 (
    //   .clk(dspclk),
    //   .waveLen(sqdetune),
    //   .sigOut(sqr2)
    //   );
    //
    // `CX sqrdet;
    // dsp_addcl addcl_sqrdet (
    //   .x(squareWave),
    //   .y(sqr2),
    //   .sum(sqrdet)
    //   );

    // wire [`BITS-1:0] lowpOut;
    // dsp_lowp lowp(
    //   .clk(dspclk),
    //   .sigIn(addClOut),
    //   .cutoff(`FPF(0.005)),
    //   .sigOut(lowpOut)
    //   );

    // wire [`BITS-1:0] highpOut;
    // dsp_highp highp(
    //   .clk(dspclk),
    //   .sigIn(addClOut),
    //   .cutoff(`FPF(0.1)),
    //   .sigOut(highpOut)
    //   );
    // `CX sqrhp;
    // dsp_highp highp_sqrhp(
    //   .clk(dspclk),
    //   .sigIn(sqrdet),
    //   .cutoff(`FPF(0.1)),
    //   .sigOut(sqrhp)
    //   );

    // wire [`BITS-1:0] noiseGOut, noiseUOut;
    // LFSR_Plus #(.W(`BITS), .V(18), .g_type(0), .u_type(1)) noiseGen
    // 	(
    // 		.g_noise_out(noiseGOut),
    // 		.u_noise_out(noiseUOut),
    // 		.clk(dspclk),
    // 		.n_reset(1'b1),
    // 		.enable(1'b1)
    // 	);
    // `CX noise_g, noise_u;
    // LFSR_Plus #(.W(`BITS), .V(18), .g_type(0), .u_type(1)) noiseGen
    //   (
    //     .g_noise_out(noise_g),
    //     .u_noise_out(noise_u),
    //     .clk(dspclk),
    //     .n_reset(1'b1),
    //     .enable(1'b1)
    //   );
    //
    // wire seqOut2;
    // bitseq #(.DEPTH(8)) r1
    // (
    //   .clk(dspclk),       //clock signal
    //   .ena(1'b1),       //enable signal
    //   .seq(8'b10110001),   //input
    //   .len(`MS(200)),
    //   .seqOut(seqOut2)  //output
    // );
    //
    // wire r1;
    // bitseq #(.DEPTH(8)) bitseq_r1
    // (
    //   .clk(dspclk),       //clock signal
    //   .ena(1'b1),       //enable signal
    //   .seq(8'b10010010),   //input
    //   .len(`MS(10)),
    //   .seqOut(r1)  //output
    // );
    //
    // wire signed [`BITS-1:0] envVal;
    // envseq #(.DEPTH(4), .LEN(4), .TSCALE(200)) env1 (
    //   .clk(dspclk),
    //   .trigger(seqOut2),
    //   .ena(1'b1),       //enable signal
    //   .rst(1'b0),       //reset signal
    //   .levels(16'hFA30),
    //   .times(12'h194),
    //   .envOut(envVal)
    //   );
    //
    // `CX env1
    // envseq #(.DEPTH(4), .LEN(4), .TSCALE(10)) envseq_env1 (
    //   .clk(dspclk),
    //   .trigger(envVal),     //1'b
    //   .ena(1'b1),
    //   .rst(1'b0),
    //   .levels(16'hFA23),      //LEN levels
    //   .times(12'hAFC),       //LEN-1 times
    //   .envOut(env1)
    //   );

    // assign w = squareWave;


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
    reg[`BITS:0] shiftVal=0;

`ifdef SIM
    integer file;
    initial file = $fopen("fpga.audio", "wb");
`endif


    always @(posedge dspClock) begin
      if (dspState == DSP_WAITING && bufferStartClock) begin
        dspState <= DSP_PROCESSING;
        dspEnabled <= 1'b1;
      end else if (dspState == DSP_PROCESSING) begin
        buffer[dspCounter] <= (w >>> (`BITS-8));

`ifdef SIM
        $fwriteb(file, "%c", buffer[dspCounter]);
`endif

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
