// *******************************
// lab_SPEAKER_TOP
//
// ********************************

module MusicMain (
           input clk,
           input reset,
           input [3:0] level,
           output pmod_1,
           output pmod_2,
           output pmod_4
       );
reg [31:0] BEAT_FREQ;	//one beat=0.125sec

always @(*) begin
    case (level)
        4'd1: begin
            BEAT_FREQ = 32'd8;
        end
        4'd2: begin
            BEAT_FREQ = 32'd9;
        end
        4'd3: begin
            BEAT_FREQ = 32'd10;
        end
        4'd4: begin
            BEAT_FREQ = 32'd11;
        end
        4'd5: begin
            BEAT_FREQ = 32'd12;
        end
        4'd6: begin
            BEAT_FREQ = 32'd13;
        end
        4'd7: begin
            BEAT_FREQ = 32'd14;
        end
        4'd8: begin
            BEAT_FREQ = 32'd15;
        end
        default: begin
            BEAT_FREQ = 32'd8;
        end
    endcase
end
parameter DUTY_BEST = 10'd512;	//duty cycle=50%

wire [31:0] freq;
wire [7:0] ibeatNum;
wire beatFreq;

assign pmod_2 = 1'd1;	//no gain(6dB)
assign pmod_4 = 1'd1;	//turn-on

//Generate beat speed
PWM_gen btSpeedGen ( .clk(clk),
                     .reset(reset),
                     .freq(BEAT_FREQ),
                     .duty(DUTY_BEST),
                     .PWM(beatFreq)
                   );

//manipulate beat
PlayerCtrl playerCtrl_00 ( .clk(beatFreq),
                           .reset(reset),
                           .ibeat(ibeatNum)
                         );

//Generate variant freq. of tones
Music music00 ( .ibeatNum(ibeatNum),
                .tone(freq)
              );

// Generate particular freq. signal
PWM_gen toneGen ( .clk(clk),
                  .reset(reset),
                  .freq(level == 8 ? freq*2 : freq),
                  .duty(DUTY_BEST),
                  .PWM(pmod_1)
                );
endmodule
