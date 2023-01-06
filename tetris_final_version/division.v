`timescale 1ns / 1ps
`include "global.v"
module twenty_division(
    input [9:0] dividend,
    output reg [9:0] out
);
    always@(*) begin
        if(dividend >= 0 && dividend <= 20) begin
            out = 0;
        end else if(dividend >= 20 && dividend <= 40) begin
            out = 1;
        end else if(dividend >= 40 && dividend <= 60) begin
            out = 2;           
        end else if(dividend >= 60 && dividend <= 80) begin
            out = 3;
        end else if(dividend >= 80 && dividend <= 100) begin
            out = 4;
        end else if(dividend >= 100 && dividend <= 120) begin
            out = 5;
        end else if(dividend >= 120 && dividend <= 140) begin
            out = 6;
        end else if(dividend >= 140 && dividend <= 160) begin
            out = 7;
        end else if(dividend >= 160 && dividend <= 180) begin
            out = 8;
        end else if(dividend >= 180 && dividend <= 200) begin
            out = 9;
        end else if(dividend >= 200 && dividend <= 220) begin
            out = 10;
        end else if(dividend >= 220 && dividend <= 240) begin
            out = 11;
        end else if(dividend >= 240 && dividend <= 260) begin
            out = 12;
        end else if(dividend >= 260 && dividend <= 280) begin
            out = 13;
        end else if(dividend >= 280 && dividend <= 300) begin
            out = 14;
        end else if(dividend >= 300 && dividend <= 320) begin
            out = 15;
        end else if(dividend >= 320 && dividend <= 340) begin
            out = 16;
        end else if(dividend >= 340 && dividend <= 360) begin
            out = 17;
        end else if(dividend >= 360 && dividend <= 380) begin
            out = 18;
        end else if(dividend >= 380 && dividend <= 400) begin
            out = 19;
        end else begin
            out = 0;
        end
    end
endmodule