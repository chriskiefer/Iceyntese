// iverilog -g2012 -o env.vvp rottest.sv ../bitseq.sv ../env.sv; vvp env.vvp -lxt
module envseq #(
  parameter DEPTH = 4,
  parameter LEN = 2,
  parameter TSCALE = 1
)(
  input clk,       //clock signal
  input trigger,
  input ena,       //enable signal
  input rst,       //reset signal
  input [(DEPTH*LEN)-1:0] levels,   //input
  input [(DEPTH*(LEN-1))-1:0] times,
  output [`BITS-1:0] envOut  //output
);


reg [23:0] timeCounter;
reg [7:0] levelOffset, timeOffset;
reg [DEPTH-1:0] envLevel;
reg [`BITS-1:0] envLevelScaled;
reg [7:0] bitDepth = DEPTH;

localparam ENV_WAITING = 2'd0;
localparam ENV_RUNNING = 2'd1;

reg [1:0] envState = ENV_WAITING;

initial begin
  // levs = levels;
  // ts = times;
  levelOffset = ((LEN-1) * DEPTH);
  timeOffset = (DEPTH*(LEN-2));
  timeCounter <= 0;
  envLevel <= 0;
  envLevelScaled <= 0;
end

//clk or trigger (introduces a slight delay but <1sample so whatever)
wire envTrig = clk ^ trigger;

always @(posedge envTrig) begin
  if (rst) begin
  end else begin
    if (ena) begin
      case (envState)
        ENV_WAITING:
          begin
            if (trigger) begin
              envState <= ENV_RUNNING;
              timeCounter <= (times[((LEN-2) * DEPTH) +: DEPTH] * TSCALE) - 1;
              envLevel <= levels[((LEN-1) * DEPTH) +: DEPTH];
              envLevelScaled <= levels[((LEN-1) * DEPTH) +: DEPTH] << (`FPWIDTH - DEPTH - 1);
              levelOffset = ((LEN-1) * DEPTH);
              timeOffset = (DEPTH*(LEN-2));
            end
          end
        ENV_RUNNING:
          begin
            if (trigger) begin
              //repeat of above
              timeCounter <= (times[((LEN-2) * DEPTH) +: DEPTH] * TSCALE) - 1;
              envLevel <= levels[((LEN-1) * DEPTH) +: DEPTH];
              envLevelScaled <= levels[((LEN-1) * DEPTH) +: DEPTH] << (`FPWIDTH - DEPTH - 1);
              levelOffset <= ((LEN-1) * DEPTH);
              timeOffset <= (DEPTH*(LEN-2));
            end else begin
              if (timeCounter == 0) begin
                if (levelOffset == 0) begin
                  envState <= ENV_WAITING;
                  levelOffset <= ((LEN-1) * DEPTH);
                  timeOffset <= (DEPTH*(LEN-2));
                  timeCounter <= 8'd129;
                end else begin
                  levelOffset <= levelOffset - DEPTH;
                  timeOffset <= timeOffset - DEPTH;
                  if (timeOffset == 0) begin
                    timeCounter <= 0;
                    envState <= ENV_WAITING;
                  end else begin
                    timeCounter <= (times[(timeOffset - DEPTH) +: DEPTH] * TSCALE) - 1;
                  end
                end
                envLevel <= levels[(levelOffset - DEPTH) +: DEPTH];
                envLevelScaled <= levels[(levelOffset - DEPTH) +: DEPTH] << (`FPWIDTH - DEPTH - 1);
              end else begin
                timeCounter <= timeCounter - 1;
              end
            end
          end
        default:
          envState <= envState;
      endcase
    end
  end
end

assign envOut = envLevelScaled;



endmodule
