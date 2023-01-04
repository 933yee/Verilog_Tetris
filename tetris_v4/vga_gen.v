`timescale 1ns / 1ps
`include "global.v"
module vga_gen(
    input [9:0] h_cnt, 
    input [9:0] v_cnt,
    input [0:199] boardMemory, 
    input [9:0] memoryX, 
    input [9:0] memoryY, 
    input [11:0] pixel_back,
    output [3:0]vgaRed, 
    output [3:0]vgaBlue, 
    output [3:0]vgaGreen, 
);
    reg [3:0] vgaRed, vgaBlue, vgaGreen;

endmodule