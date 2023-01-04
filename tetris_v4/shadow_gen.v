`timescale 1ns / 1ps
`include "global.v"

module shadow_gen(
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
    output [9:0] shadowX1,
    output [9:0] shadowX2,
    output [9:0] shadowX3,
    output [9:0] shadowX4,
    output [9:0] shadowY1,
    output [9:0] shadowY2,
    output [9:0] shadowY3,
    output [9:0] shadowY4
);
    reg [9:0] shadowX1, shadowX2, shadowX3, shadowX4;
    reg [9:0] shadowY1, shadowY2, shadowY3, shadowY4;
    always@(posedge clk) begin
        if(ctrlY1 + 1 == 20 || ctrlY2 + 1 == 20 || ctrlY3 + 1 == 20 || ctrlY4 + 1 == 20
            || boardMemory[(ctrlY1 + 1)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 1)*`WIDTH + ctrlX2]
            || boardMemory[(ctrlY3 + 1)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 1)*`WIDTH + ctrlX4]) begin
                shadowX1 <= ctrlX1;
                shadowX2 <= ctrlX2;
                shadowX3 <= ctrlX3;
                shadowX4 <= ctrlX4;
                shadowY1 <= ctrlY1;
                shadowY2 <= ctrlY2;
                shadowY3 <= ctrlY3;
                shadowY4 <= ctrlY4;
        end else if(ctrlY1 + 2 == 20 || ctrlY2 + 2 == 20 || ctrlY3 + 2 == 20 || ctrlY4 + 2 == 20
                || boardMemory[(ctrlY1 + 2)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 2)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 2)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 2)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+1;
                    shadowY2 <= ctrlY2+1;
                    shadowY3 <= ctrlY3+1;
                    shadowY4 <= ctrlY4+1;
        end else if(ctrlY1 + 3 == 20 || ctrlY2 + 3 == 20 || ctrlY3 + 3 == 20 || ctrlY4 + 3 == 20
                || boardMemory[(ctrlY1 + 3)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 3)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 3)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 3)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+2;
                    shadowY2 <= ctrlY2+2;
                    shadowY3 <= ctrlY3+2;
                    shadowY4 <= ctrlY4+2;
        end else if(ctrlY1 + 4 == 20 || ctrlY2 + 4 == 20 || ctrlY3 + 4 == 20 || ctrlY4 + 4 == 20
                || boardMemory[(ctrlY1 + 4)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 4)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 4)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 4)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+3;
                    shadowY2 <= ctrlY2+3;
                    shadowY3 <= ctrlY3+3;
                    shadowY4 <= ctrlY4+3;
        end else if(ctrlY1 + 5 == 20 || ctrlY2 + 5 == 20 || ctrlY3 + 5 == 20 || ctrlY4 + 5 == 20
                || boardMemory[(ctrlY1 + 5)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 5)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 5)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 5)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+4;
                    shadowY2 <= ctrlY2+4;
                    shadowY3 <= ctrlY3+4;
                    shadowY4 <= ctrlY4+4;
        end else if(ctrlY1 + 6 == 20 || ctrlY2 + 6 == 20 || ctrlY3 + 6 == 20 || ctrlY4 + 6 == 20
                || boardMemory[(ctrlY1 + 6)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 6)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 6)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 6)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+5;
                    shadowY2 <= ctrlY2+5;
                    shadowY3 <= ctrlY3+5;
                    shadowY4 <= ctrlY4+5;
        end else if(ctrlY1 + 7 == 20 || ctrlY2 + 7 == 20 || ctrlY3 + 7 == 20 || ctrlY4 + 7 == 20
                || boardMemory[(ctrlY1 + 7)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 7)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 7)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 7)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+6;
                    shadowY2 <= ctrlY2+6;
                    shadowY3 <= ctrlY3+6;
                    shadowY4 <= ctrlY4+6;
        end else if(ctrlY1 + 8 == 20 || ctrlY2 + 8 == 20 || ctrlY3 + 8 == 20 || ctrlY4 + 8 == 20
                || boardMemory[(ctrlY1 + 8)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 8)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 8)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 8)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+7;
                    shadowY2 <= ctrlY2+7;
                    shadowY3 <= ctrlY3+7;
                    shadowY4 <= ctrlY4+7;
        end else if(ctrlY1 + 9 == 20 || ctrlY2 + 9 == 20 || ctrlY3 + 9 == 20 || ctrlY4 + 9 == 20
                || boardMemory[(ctrlY1 + 9)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 9)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 9)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 9)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+8;
                    shadowY2 <= ctrlY2+8;
                    shadowY3 <= ctrlY3+8;
                    shadowY4 <= ctrlY4+8;
        end else if(ctrlY1 + 10 == 20 || ctrlY2 + 10 == 20 || ctrlY3 + 10 == 20 || ctrlY4 + 10 == 20
                || boardMemory[(ctrlY1 + 10)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 10)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 10)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 10)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+9;
                    shadowY2 <= ctrlY2+9;
                    shadowY3 <= ctrlY3+9;
                    shadowY4 <= ctrlY4+9;
        end else if(ctrlY1 + 11 == 20 || ctrlY2 + 11 == 20 || ctrlY3 + 11 == 20 || ctrlY4 + 11 == 20
                || boardMemory[(ctrlY1 + 11)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 11)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 11)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 11)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+10;
                    shadowY2 <= ctrlY2+10;
                    shadowY3 <= ctrlY3+10;
                    shadowY4 <= ctrlY4+10;
        end else if(ctrlY1 + 12 == 20 || ctrlY2 + 12 == 20 || ctrlY3 + 12 == 20 || ctrlY4 + 12 == 20
                || boardMemory[(ctrlY1 + 12)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 12)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 12)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 12)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+11;
                    shadowY2 <= ctrlY2+11;
                    shadowY3 <= ctrlY3+11;
                    shadowY4 <= ctrlY4+11;
        end else if(ctrlY1 + 13 == 20 || ctrlY2 + 13 == 20 || ctrlY3 + 13 == 20 || ctrlY4 + 13 == 20
                || boardMemory[(ctrlY1 + 13)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 13)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 13)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 13)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+12;
                    shadowY2 <= ctrlY2+12;
                    shadowY3 <= ctrlY3+12;
                    shadowY4 <= ctrlY4+12;
        end else if(ctrlY1 + 14 == 20 || ctrlY2 + 14 == 20 || ctrlY3 + 14 == 20 || ctrlY4 + 14 == 20
                || boardMemory[(ctrlY1 + 14)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 14)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 14)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 14)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+13;
                    shadowY2 <= ctrlY2+13;
                    shadowY3 <= ctrlY3+13;
                    shadowY4 <= ctrlY4+13;
        end else if(ctrlY1 + 15 == 20 || ctrlY2 + 15 == 20 || ctrlY3 + 15 == 20 || ctrlY4 + 15 == 20
                || boardMemory[(ctrlY1 + 15)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 15)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 15)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 15)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+14;
                    shadowY2 <= ctrlY2+14;
                    shadowY3 <= ctrlY3+14;
                    shadowY4 <= ctrlY4+14;
        end else if(ctrlY1 + 16 == 20 || ctrlY2 + 16 == 20 || ctrlY3 + 16 == 20 || ctrlY4 + 16 == 20
                || boardMemory[(ctrlY1 + 16)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 16)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 16)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 16)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+15;
                    shadowY2 <= ctrlY2+15;
                    shadowY3 <= ctrlY3+15;
                    shadowY4 <= ctrlY4+15;
        end else if(ctrlY1 + 17 == 20 || ctrlY2 + 17 == 20 || ctrlY3 + 17 == 20 || ctrlY4 + 17 == 20
                || boardMemory[(ctrlY1 + 17)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 17)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 17)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 17)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+16;
                    shadowY2 <= ctrlY2+16;
                    shadowY3 <= ctrlY3+16;
                    shadowY4 <= ctrlY4+16;
        end else if(ctrlY1 + 18 == 20 || ctrlY2 + 18 == 20 || ctrlY3 + 18 == 20 || ctrlY4 + 18 == 20
                || boardMemory[(ctrlY1 + 18)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 18)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 18)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 18)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+17;
                    shadowY2 <= ctrlY2+17;
                    shadowY3 <= ctrlY3+17;
                    shadowY4 <= ctrlY4+17;
        end else if(ctrlY1 + 19 == 20 || ctrlY2 + 19 == 20 || ctrlY3 + 19 == 20 || ctrlY4 + 19 == 20
                || boardMemory[(ctrlY1 + 19)*`WIDTH + ctrlX1] || boardMemory[(ctrlY2 + 19)*`WIDTH + ctrlX2]
                || boardMemory[(ctrlY3 + 19)*`WIDTH + ctrlX3] || boardMemory[(ctrlY4 + 19)*`WIDTH + ctrlX4]) begin
                    shadowX1 <= ctrlX1;
                    shadowX2 <= ctrlX2;
                    shadowX3 <= ctrlX3;
                    shadowX4 <= ctrlX4;
                    shadowY1 <= ctrlY1+18;
                    shadowY2 <= ctrlY2+18;
                    shadowY3 <= ctrlY3+18;
                    shadowY4 <= ctrlY4+18;
        end 
    end    
endmodule