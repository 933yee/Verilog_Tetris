`timescale 1ns / 1ps
`include "global.v"
module twenty_division(
    input [9:0] dividend,
    output reg [9:0] out
);
    always@(*) begin
        if(dividend >= `BLOCK_SIDE*0 && dividend <= `BLOCK_SIDE*1) begin
            out = 0;
        end else if(dividend >= `BLOCK_SIDE*1 && dividend <= `BLOCK_SIDE*2) begin
            out = 1;
        end else if(dividend >= `BLOCK_SIDE*2 && dividend <= `BLOCK_SIDE*3) begin
            out = 2;           
        end else if(dividend >= `BLOCK_SIDE*3 && dividend <= `BLOCK_SIDE*4) begin
            out = 3;
        end else if(dividend >= `BLOCK_SIDE*4 && dividend <= `BLOCK_SIDE*5) begin
            out = 4;
        end else if(dividend >= `BLOCK_SIDE*5 && dividend <= `BLOCK_SIDE*6) begin
            out = 5;
        end else if(dividend >= `BLOCK_SIDE*6 && dividend <= `BLOCK_SIDE*7) begin
            out = 6;
        end else if(dividend >= `BLOCK_SIDE*7 && dividend <= `BLOCK_SIDE*8) begin
            out = 7;
        end else if(dividend >= `BLOCK_SIDE*8 && dividend <= `BLOCK_SIDE*9) begin
            out = 8;
        end else if(dividend >= `BLOCK_SIDE*9 && dividend <= `BLOCK_SIDE*10) begin
            out = 9;
        end else if(dividend >= `BLOCK_SIDE*10 && dividend <= `BLOCK_SIDE*11) begin
            out = 10;
        end else if(dividend >= `BLOCK_SIDE*11 && dividend <= `BLOCK_SIDE*12) begin
            out = 11;
        end else if(dividend >= `BLOCK_SIDE*12 && dividend <= `BLOCK_SIDE*13) begin
            out = 12;
        end else if(dividend >= `BLOCK_SIDE*13 && dividend <= `BLOCK_SIDE*14) begin
            out = 13;
        end else if(dividend >= `BLOCK_SIDE*14 && dividend <= `BLOCK_SIDE*15) begin
            out = 14;
        end else if(dividend >= `BLOCK_SIDE*15 && dividend <= `BLOCK_SIDE*16) begin
            out = 15;
        end else if(dividend >= `BLOCK_SIDE*16 && dividend <= `BLOCK_SIDE*17) begin
            out = 16;
        end else if(dividend >= `BLOCK_SIDE*17 && dividend <= `BLOCK_SIDE*18) begin
            out = 17;
        end else if(dividend >= `BLOCK_SIDE*18 && dividend <= `BLOCK_SIDE*19) begin
            out = 18;
        end else if(dividend >= `BLOCK_SIDE*19 && dividend <= `BLOCK_SIDE*20) begin
            out = 19;
        end else begin
            out = 0;
        end
    end
endmodule