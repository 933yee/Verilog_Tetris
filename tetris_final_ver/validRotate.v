`timescale 1ns / 1ps
`include "global.v"

module ValidRotate(
           input clk,
           input [9:0] ctrlX1,
           input [9:0] ctrlX2,
           input [9:0] ctrlX3,
           input [9:0] ctrlX4,
           input [9:0] ctrlY1,
           input [9:0] ctrlY2,
           input [9:0] ctrlY3,
           input [9:0] ctrlY4,
           input [0:199] boardMemory,
           input [3:0] current_block,
           input [3:0] current_angle,
           output validClockwise,
           output validCounterclockwise
       );
reg validClockwise, validCounterclockwise;
// tmp registers
reg [0:3]clockwiser, counterclockwiser;
always@(posedge clk) begin
    validClockwise <= clockwiser[0] && clockwiser[1] && clockwiser[2] && clockwiser[3];
    // validCounterclockwise <= counterclockwiser[0] & counterclockwiser[1] && counterclockwiser[2] && counterclockwiser[3];
end
always@(*) begin
    case(current_block)
        `O_BLOCK: begin
            clockwiser = 4'b1111;
        end
        `L_BLOCK: begin
            case(current_angle)
                `ANGLE0: begin
                    // clockwise
                    clockwiser[1] = 1;
                    if(boardMemory[(ctrlY2-1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[(ctrlY2+1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[2] = 1;
                    end
                    else begin
                        clockwiser[2] = 0;
                    end
                    if(boardMemory[(ctrlY2+1)*`WIDTH+(ctrlX2+1)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                    // counterwise

                end
                `ANGLE90: begin
                    // clockwise
                    clockwiser[1] = 1;
                    if(boardMemory[ctrlY2*`WIDTH+(ctrlX2+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[ctrlY2*`WIDTH+(ctrlX2+1)%`WIDTH] == 0) begin
                        clockwiser[2] = 1;
                    end
                    else begin
                        clockwiser[2] = 0;
                    end
                    if(boardMemory[(ctrlY2+1)*`WIDTH+(ctrlX2+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end

                    // counterwise

                end
                `ANGLE180: begin
                    // clockwise
                    clockwiser[2] = 1;
                    if(boardMemory[(ctrlY1-1)*`WIDTH+ctrlX1] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[(ctrlY2-1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[1] = 1;
                    end
                    else begin
                        clockwiser[1] = 0;
                    end
                    if(boardMemory[(ctrlY2+1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end

                    // counterclockwise
                end
                `ANGLE270: begin
                    // clockwise
                    clockwiser[2] = 1;
                    if(boardMemory[ctrlY2*`WIDTH+(ctrlX2+1)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[ctrlY3*`WIDTH+(ctrlX3+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[1] = 1;
                    end
                    else begin
                        clockwiser[1] = 0;
                    end
                    if(boardMemory[ctrlY3*`WIDTH+(ctrlX3+1)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                end
            endcase
        end
        `J_BLOCK: begin
            case(current_angle)
                `ANGLE0: begin
                    // clockwise
                    clockwiser[2] = 1;
                    if(boardMemory[(ctrlY3-1)*`WIDTH+ctrlX3] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[(ctrlY3-1)*`WIDTH+(ctrlX3+1)%`WIDTH] == 0) begin
                        clockwiser[1] = 1;
                    end
                    else begin
                        clockwiser[1] = 0;
                    end
                    if(boardMemory[(ctrlY3+1)*`WIDTH+ctrlX3] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                    // counterwise

                end
                `ANGLE90: begin
                    // clockwise
                    clockwiser[1] = 1;
                    if(boardMemory[ctrlY3*`WIDTH+(ctrlX3+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[ctrlY3*`WIDTH+(ctrlX3+1)%`WIDTH] == 0) begin
                        clockwiser[2] = 1;
                    end
                    else begin
                        clockwiser[2] = 0;
                    end
                    if(boardMemory[(ctrlY3+1)*`WIDTH+(ctrlX3+1)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end

                    // counterwise

                end
                `ANGLE180: begin
                    // clockwise
                    clockwiser[1] = 1;
                    if(boardMemory[(ctrlY2-1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[(ctrlY2+1)*`WIDTH+(ctrlX2+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[2] = 1;
                    end
                    else begin
                        clockwiser[2] = 0;
                    end
                    if(boardMemory[(ctrlY2+1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end

                    // counterclockwise
                end
                `ANGLE270: begin
                    // clockwise
                    clockwiser[2] = 1;
                    if(boardMemory[(ctrlY2-1)*`WIDTH+(ctrlX2+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[ctrlY2*`WIDTH+(ctrlX2+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[1] = 1;
                    end
                    else begin
                        clockwiser[1] = 0;
                    end
                    if(boardMemory[ctrlY2*`WIDTH+(ctrlX2+1)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                end
            endcase
        end
        `S_BLOCK: begin
            case(current_angle)
                `ANGLE0: begin
                    // clockwise
                    clockwiser[0] = 1;
                    clockwiser[1] = 1;
                    if(boardMemory[(ctrlY2+1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[2] = 1;
                    end
                    else begin
                        clockwiser[2] = 0;
                    end
                    if(boardMemory[(ctrlY2+2)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                    // counterwise

                end
                `ANGLE90: begin
                    // clockwise
                    clockwiser[0] = 1;
                    clockwiser[1] = 1;

                    if(boardMemory[(ctrlY2+1)*`WIDTH+(ctrlX2-1+`WIDTH)%`WIDTH] == 0) begin
                        clockwiser[2] = 1;
                    end
                    else begin
                        clockwiser[2] = 0;
                    end

                    if(boardMemory[(ctrlY2+1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                    // counterwise

                end
                `ANGLE180: begin
                    // clockwise
                    clockwiser[2] = 1;
                    clockwiser[3] = 1;
                    if(boardMemory[(ctrlY1-1)*`WIDTH+(ctrlX1+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[ctrlY1*`WIDTH+(ctrlX1+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[1] = 1;
                    end
                    else begin
                        clockwiser[1] = 0;
                    end

                    // counterclockwise
                end
                `ANGLE270: begin
                    // clockwise
                    clockwiser[2] = 1;
                    clockwiser[3] = 1;

                    if(boardMemory[(ctrlY3-1)*`WIDTH+ctrlX3] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end

                    if(boardMemory[(ctrlY3-1)*`WIDTH+(ctrlX3+1)%`WIDTH] == 0) begin
                        clockwiser[1] = 1;
                    end
                    else begin
                        clockwiser[1] = 0;
                    end

                end
            endcase
        end
        `Z_BLOCK: begin
            case(current_angle)
                `ANGLE0: begin
                    // clockwise
                    clockwiser[1] = 1;
                    clockwiser[2] = 1;
                    if(boardMemory[(ctrlY3-1)*`WIDTH+(ctrlX3+1)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[(ctrlY3+1)*`WIDTH+ctrlX3] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                    // counterwise

                end
                `ANGLE90: begin
                    // clockwise
                    clockwiser[1] = 1;
                    clockwiser[2] = 1;

                    if(boardMemory[ctrlY2*`WIDTH+(ctrlX2+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end

                    if(boardMemory[(ctrlY2+1)*`WIDTH+(ctrlX2+1)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                    // counterwise

                end
                `ANGLE180: begin
                    // clockwise
                    clockwiser[1] = 1;
                    clockwiser[2] = 1;
                    if(boardMemory[(ctrlY2-1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[(ctrlY2+1)*`WIDTH+(ctrlX2+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end

                    // counterclockwise
                end
                `ANGLE270: begin
                    // clockwise
                    clockwiser[1] = 1;
                    clockwiser[2] = 1;

                    if(boardMemory[(ctrlY3-1)*`WIDTH+(ctrlX3+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end

                    if(boardMemory[ctrlY3*`WIDTH+(ctrlX3+1)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end

                end
            endcase
        end
        `I_BLOCK: begin
            case(current_angle)
                `ANGLE0: begin
                    // clockwise
                    clockwiser[1] = 1;
                    if(boardMemory[(ctrlY3-1)*`WIDTH+ctrlX3] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[(ctrlY3+1)*`WIDTH+ctrlX3] == 0) begin
                        clockwiser[2] = 1;
                    end
                    else begin
                        clockwiser[2] = 0;
                    end
                    if(boardMemory[(ctrlY3+2)*`WIDTH+ctrlX3] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                    // counterwise

                end
                `ANGLE90: begin
                    // clockwise
                    clockwiser[2] = 1;
                    if(boardMemory[ctrlY3*`WIDTH+(ctrlX3+`WIDTH-2)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[ctrlY3*`WIDTH+(ctrlX3+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[1] = 1;
                    end
                    else begin
                        clockwiser[1] = 0;
                    end
                    if(boardMemory[ctrlY3*`WIDTH+(ctrlX3+1)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                    // counterwise

                end
                `ANGLE180: begin
                    // clockwise
                    clockwiser[2] = 1;
                    if(boardMemory[(ctrlY2-2)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[(ctrlY2-1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[1] = 1;
                    end
                    else begin
                        clockwiser[1] = 0;
                    end
                    if(boardMemory[(ctrlY2+1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end

                    // counterclockwise
                end
                `ANGLE270: begin
                    // clockwise
                    clockwiser[1] = 1;
                    if(boardMemory[ctrlY2*`WIDTH+(ctrlX2+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    if(boardMemory[ctrlY2*`WIDTH+(ctrlX2+1)%`WIDTH] == 0) begin
                        clockwiser[2] = 1;
                    end
                    else begin
                        clockwiser[2] = 0;
                    end
                    if(boardMemory[ctrlY2*`WIDTH+(ctrlX2+2)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                end
            endcase
        end
        `T_BLOCK: begin
            case(current_angle)
                `ANGLE0: begin
                    // clockwise
                    clockwiser[0] = 1;
                    clockwiser[1] = 1;
                    clockwiser[2] = 1;
                    if(boardMemory[(ctrlY3+1)*`WIDTH+ctrlX3] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                    // counterwise

                end
                `ANGLE90: begin
                    // clockwise
                    clockwiser[1] = 1;
                    clockwiser[2] = 1;
                    clockwiser[3] = 1;
                    if(boardMemory[ctrlY2*`WIDTH+(ctrlX2+`WIDTH-1)%`WIDTH] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end
                    // counterwise

                end
                `ANGLE180: begin
                    // clockwise
                    clockwiser[1] = 1;
                    clockwiser[2] = 1;
                    clockwiser[3] = 1;
                    if(boardMemory[(ctrlY2-1)*`WIDTH+ctrlX2] == 0) begin
                        clockwiser[0] = 1;
                    end
                    else begin
                        clockwiser[0] = 0;
                    end

                    // counterclockwise
                end
                `ANGLE270: begin
                    // clockwise
                    clockwiser[0] = 1;
                    clockwiser[1] = 1;
                    clockwiser[2] = 1;
                    if(boardMemory[ctrlY3*`WIDTH+(ctrlX3+1)%`WIDTH] == 0) begin
                        clockwiser[3] = 1;
                    end
                    else begin
                        clockwiser[3] = 0;
                    end
                end
            endcase
        end
        default: begin
        end
    endcase
end

endmodule
