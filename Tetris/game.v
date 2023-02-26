`timescale 1ns / 1ps
`include "global.v"

module game(
           input clk,
           input rst,
           input [9:0] h_cnt,
           input [9:0] v_cnt,
           input [511:0] key_down,
           input [8:0] last_change,
           input been_ready,
           output [16:0] pixel_addr,
           output [3:0] vgaGreen,
           output [3:0] vgaBlue,
           output [3:0] vgaRed,
           input valid,
           input [11:0] pixel,
           input [11:0] pixel_back,
           output [3:0]level,
           output valid_rotate_led
       );
// pixel
reg [16:0] pixel_addr;

// board data
reg [0:199] boardMemory;// left_up to right_down
reg [3:0] boardMemory_type [0:199];
reg [9:0] ctrlX [3:0]; // coordinate X
reg [9:0] next_ctrlX [3:0];
reg [9:0] ctrlY [3:0]; // coordinate Y
reg [9:0] next_ctrlY [3:0];
reg [9:0] a1 = 201, a2 = 201, a3 = 201, a4 = 201;
reg [9:0] d1 = 201, d2 = 201, d3 = 201, d4 = 201;
//vga
reg [3:0] vgaGreen, vgaRed, vgaBlue;

// block status
reg [3:0] current_block, next_block;
reg [3:0] current_angle, next_angle;

//other
reg start = 0;
reg gamestart = 0;
reg first = 0;
reg [31:0] score;
wire [3:0]random_block;
reg [3:0] level;
reg speed;

// hold
reg hold;
reg c_hold;
reg [3:0]hold_block;

rand_gen rand_gen1(
             .clk(clk),
             .rst(start),
             .random_block(random_block),
             .drop(drop)
         );
reg [31:0]start_1s_cnt = 0;
// calculate the coordinates of the boardMemory
wire [9:0] memoryX, memoryY;
twenty_division td1(.dividend(h_cnt-`LEFT_MOST), .out(memoryX));
twenty_division td2(.dividend(v_cnt-`UP_MOST), .out(memoryY));

// clk
wire clk_1s, clk_0_8s, clk_0_6s, clk_0_4s, clk_0_2s, clk_0_1s, clk_0_0_5s, shineclk, clk_0_0_2_5s;
clock_divisor_1s cd1(
                     .clk(clk),
                     .clk_out(clk_1s),
                     .rst(start)
                 );
clock_divisor_0_8s cd2(
                       .clk(clk),
                       .clk_out(clk_0_8s),
                       .rst(start)
                   );
clock_divisor_0_6s cd3(
                       .clk(clk),
                       .clk_out(clk_0_6s),
                       .rst(start)
                   );
clock_divisor_0_4s cd4(
                       .clk(clk),
                       .clk_out(clk_0_4s),
                       .rst(start)
                   );
clock_divisor_0_2s cd5(
                       .clk(clk),
                       .clk_out(clk_0_2s),
                       .rst(start)
                   );
clock_divisor_0_1s cd6(
                       .clk(clk),
                       .clk_out(clk_0_1s),
                       .rst(start)
                   );
clock_divisor_0_0_5s cd7(
                         .clk(clk),
                         .clk_out(clk_0_0_5s),
                         .rst(start)
                     );
clock_divisor_0_0_2_5s cd9(
                           .clk(clk),
                           .clk_out(clk_0_0_2_5s),
                           .rst(start)
                       );
shine_clk cd8(
              .clk(clk),
              .clk_out(shineclk),
              .rst(start)
          );
// check valid movement or not
wire validLeft, validRight, validDown;
validMove validmove(
              .clk(clk),
              .ctrlX1(ctrlX[0]),
              .ctrlX2(ctrlX[1]),
              .ctrlX3(ctrlX[2]),
              .ctrlX4(ctrlX[3]),
              .ctrlY1(ctrlY[0]),
              .ctrlY2(ctrlY[1]),
              .ctrlY3(ctrlY[2]),
              .ctrlY4(ctrlY[3]),
              .boardMemory(boardMemory),
              .validLeft(validLeft),
              .validRight(validRight),
              .validDown(validDown)
          );

// check valid rotation or not
wire validClockwise, validCounterclockwise;
ValidRotate validrotate(
                .clk(clk),
                .ctrlX1(ctrlX[0]),
                .ctrlX2(ctrlX[1]),
                .ctrlX3(ctrlX[2]),
                .ctrlX4(ctrlX[3]),
                .ctrlY1(ctrlY[0]),
                .ctrlY2(ctrlY[1]),
                .ctrlY3(ctrlY[2]),
                .ctrlY4(ctrlY[3]),
                .boardMemory(boardMemory),
                .current_block(current_block),
                .current_angle(current_angle),
                .validClockwise(validClockwise),
                .validCounterclockwise(validCounterclockwise)
            );
assign valid_rotate_led = validClockwise;

// checklines
wire fullLine;
wire [0:19] fullLines;
reg drop, harddrop;
checklines checklines_(
               .clk(clk),
               .boardMemory(boardMemory),
               .fullLine(fullLine),
               .fullLines(fullLines)
           );

// shadow generator
wire [9:0] shadowY[3:0];
shadow_gen shadow_gen1(
               .clk(clk),
               .ctrlX1(ctrlX[0]),
               .ctrlX2(ctrlX[1]),
               .ctrlX3(ctrlX[2]),
               .ctrlX4(ctrlX[3]),
               .ctrlY1(ctrlY[0]),
               .ctrlY2(ctrlY[1]),
               .ctrlY3(ctrlY[2]),
               .ctrlY4(ctrlY[3]),
               .boardMemory(boardMemory),
               .shadowY1(shadowY[0]),
               .shadowY2(shadowY[1]),
               .shadowY3(shadowY[2]),
               .shadowY4(shadowY[3])
           );



always@(*) begin
    if(gamestart) begin
        current_angle = next_angle;
        current_block = next_block;
        ctrlX[0] = next_ctrlX[0];
        ctrlX[1] = next_ctrlX[1];
        ctrlX[2] = next_ctrlX[2];
        ctrlX[3] = next_ctrlX[3];
        ctrlY[0] = next_ctrlY[0];
        ctrlY[1] = next_ctrlY[1];
        ctrlY[2] = next_ctrlY[2];
        ctrlY[3] = next_ctrlY[3];
    end
    else begin
        current_angle = `ANGLE0;
        current_block = `NONE;
        ctrlX[0] = 0;
        ctrlX[1] = 0;
        ctrlX[2] = 0;
        ctrlX[3] = 0;
        ctrlY[0] = 20;
        ctrlY[1] = 20;
        ctrlY[2] = 20;
        ctrlY[3] = 20;
    end
end



// vga
always@(*) begin
    if(valid) begin
        if(h_cnt > `LEFT_MOST+1 && h_cnt <= `RIGHT_MOST && v_cnt >= `UP_MOST && v_cnt < `DOWN_MOST) begin
            if(boardMemory[memoryY*`WIDTH+memoryX] == 1'b1) begin
                case(boardMemory_type[memoryY*`WIDTH+memoryX])
                    `Z_BLOCK: begin
                        if(v_cnt % 20 == 0 || h_cnt % 20 == 0 || v_cnt % 20 == 19 || h_cnt % 20 == 19) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if (v_cnt % 20 > 3 && v_cnt % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if ((h_cnt % 20 == 16 && v_cnt % 20 == 1) || (h_cnt % 20 == 15 && v_cnt % 20 == 2) || (h_cnt % 20 == 14 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 14) || (h_cnt % 20 == 2 && v_cnt % 20 == 15) || (h_cnt % 20 == 1 && v_cnt % 20 == 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf10;
                        end
                        else if ((h_cnt % 20 == 17 && v_cnt % 20 == 1) || (h_cnt % 20 == 16 && v_cnt % 20 == 2) || (h_cnt % 20 == 15 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 15) || (h_cnt % 20 == 2 && v_cnt % 20 == 16) || (h_cnt % 20 == 1 && v_cnt % 20 == 17)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf20;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 1) || (h_cnt % 20 == 17 && v_cnt % 20 == 2) || (h_cnt % 20 == 16 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 16) || (h_cnt % 20 == 2 && v_cnt % 20 == 17) || (h_cnt % 20 == 1 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf30;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 2) || (h_cnt % 20 == 17 && v_cnt % 20 == 3) || (h_cnt % 20 == 16 && v_cnt % 20 == 4) || (h_cnt % 20 == 4 && v_cnt % 20 == 16) || (h_cnt % 20 == 3 && v_cnt % 20 == 17) || (h_cnt % 20 == 2 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf40;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 3) || (h_cnt % 20 == 17 && v_cnt % 20 == 4) || (h_cnt % 20 == 16 && v_cnt % 20 == 5) || (h_cnt % 20 == 5 && v_cnt % 20 == 16) || (h_cnt % 20 == 4 && v_cnt % 20 == 17) || (h_cnt % 20 == 3 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf50;
                        end
                        else if ((h_cnt % 20 < 16 && v_cnt % 20 < 4) || (h_cnt % 20 < 4 && v_cnt % 20 < 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf00;
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf60;
                        end
                    end
                    `S_BLOCK: begin
                        if(v_cnt % 20 == 0 || h_cnt % 20 == 0 || v_cnt % 20 == 19 || h_cnt % 20 == 19) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if (v_cnt % 20 > 3 && v_cnt % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if ((h_cnt % 20 == 16 && v_cnt % 20 == 1) || (h_cnt % 20 == 15 && v_cnt % 20 == 2) || (h_cnt % 20 == 14 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 14) || (h_cnt % 20 == 2 && v_cnt % 20 == 15) || (h_cnt % 20 == 1 && v_cnt % 20 == 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0f4;
                        end
                        else if ((h_cnt % 20 == 17 && v_cnt % 20 == 1) || (h_cnt % 20 == 16 && v_cnt % 20 == 2) || (h_cnt % 20 == 15 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 15) || (h_cnt % 20 == 2 && v_cnt % 20 == 16) || (h_cnt % 20 == 1 && v_cnt % 20 == 17)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0f5;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 1) || (h_cnt % 20 == 17 && v_cnt % 20 == 2) || (h_cnt % 20 == 16 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 16) || (h_cnt % 20 == 2 && v_cnt % 20 == 17) || (h_cnt % 20 == 1 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0f6;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 2) || (h_cnt % 20 == 17 && v_cnt % 20 == 3) || (h_cnt % 20 == 16 && v_cnt % 20 == 4) || (h_cnt % 20 == 4 && v_cnt % 20 == 16) || (h_cnt % 20 == 3 && v_cnt % 20 == 17) || (h_cnt % 20 == 2 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0f7;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 3) || (h_cnt % 20 == 17 && v_cnt % 20 == 4) || (h_cnt % 20 == 16 && v_cnt % 20 == 5) || (h_cnt % 20 == 5 && v_cnt % 20 == 16) || (h_cnt % 20 == 4 && v_cnt % 20 == 17) || (h_cnt % 20 == 3 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0f8;
                        end
                        else if ((h_cnt % 20 < 16 && v_cnt % 20 < 4) || (h_cnt % 20 < 4 && v_cnt % 20 < 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0f3;
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0f9;
                        end
                    end
                    `O_BLOCK: begin
                        if(v_cnt % 20 == 0 || h_cnt % 20 == 0 || v_cnt % 20 == 19 || h_cnt % 20 == 19) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if (v_cnt % 20 > 3 && v_cnt % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if ((h_cnt % 20 == 16 && v_cnt % 20 == 1) || (h_cnt % 20 == 15 && v_cnt % 20 == 2) || (h_cnt % 20 == 14 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 14) || (h_cnt % 20 == 2 && v_cnt % 20 == 15) || (h_cnt % 20 == 1 && v_cnt % 20 == 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hef0;
                        end
                        else if ((h_cnt % 20 == 17 && v_cnt % 20 == 1) || (h_cnt % 20 == 16 && v_cnt % 20 == 2) || (h_cnt % 20 == 15 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 15) || (h_cnt % 20 == 2 && v_cnt % 20 == 16) || (h_cnt % 20 == 1 && v_cnt % 20 == 17)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hdf0;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 1) || (h_cnt % 20 == 17 && v_cnt % 20 == 2) || (h_cnt % 20 == 16 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 16) || (h_cnt % 20 == 2 && v_cnt % 20 == 17) || (h_cnt % 20 == 1 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hcf0;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 2) || (h_cnt % 20 == 17 && v_cnt % 20 == 3) || (h_cnt % 20 == 16 && v_cnt % 20 == 4) || (h_cnt % 20 == 4 && v_cnt % 20 == 16) || (h_cnt % 20 == 3 && v_cnt % 20 == 17) || (h_cnt % 20 == 2 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hbf0;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 3) || (h_cnt % 20 == 17 && v_cnt % 20 == 4) || (h_cnt % 20 == 16 && v_cnt % 20 == 5) || (h_cnt % 20 == 5 && v_cnt % 20 == 16) || (h_cnt % 20 == 4 && v_cnt % 20 == 17) || (h_cnt % 20 == 3 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'haf0;
                        end
                        else if ((h_cnt % 20 < 16 && v_cnt % 20 < 4) || (h_cnt % 20 < 4 && v_cnt % 20 < 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hff0;
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h9f0;
                        end
                    end
                    `I_BLOCK: begin
                        if(v_cnt % 20 == 0 || h_cnt % 20 == 0 || v_cnt % 20 == 19 || h_cnt % 20 == 19) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if (v_cnt % 20 > 3 && v_cnt % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if ((h_cnt % 20 == 16 && v_cnt % 20 == 1) || (h_cnt % 20 == 15 && v_cnt % 20 == 2) || (h_cnt % 20 == 14 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 14) || (h_cnt % 20 == 2 && v_cnt % 20 == 15) || (h_cnt % 20 == 1 && v_cnt % 20 == 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0ef;
                        end
                        else if ((h_cnt % 20 == 17 && v_cnt % 20 == 1) || (h_cnt % 20 == 16 && v_cnt % 20 == 2) || (h_cnt % 20 == 15 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 15) || (h_cnt % 20 == 2 && v_cnt % 20 == 16) || (h_cnt % 20 == 1 && v_cnt % 20 == 17)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0df;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 1) || (h_cnt % 20 == 17 && v_cnt % 20 == 2) || (h_cnt % 20 == 16 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 16) || (h_cnt % 20 == 2 && v_cnt % 20 == 17) || (h_cnt % 20 == 1 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0cf;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 2) || (h_cnt % 20 == 17 && v_cnt % 20 == 3) || (h_cnt % 20 == 16 && v_cnt % 20 == 4) || (h_cnt % 20 == 4 && v_cnt % 20 == 16) || (h_cnt % 20 == 3 && v_cnt % 20 == 17) || (h_cnt % 20 == 2 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0bf;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 3) || (h_cnt % 20 == 17 && v_cnt % 20 == 4) || (h_cnt % 20 == 16 && v_cnt % 20 == 5) || (h_cnt % 20 == 5 && v_cnt % 20 == 16) || (h_cnt % 20 == 4 && v_cnt % 20 == 17) || (h_cnt % 20 == 3 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0af;
                        end
                        else if ((h_cnt % 20 < 16 && v_cnt % 20 < 4) || (h_cnt % 20 < 4 && v_cnt % 20 < 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0ff;
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h09f;
                        end
                    end
                    `L_BLOCK: begin
                        if(v_cnt % 20 == 0 || h_cnt % 20 == 0 || v_cnt % 20 == 19 || h_cnt % 20 == 19) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if (v_cnt % 20 > 3 && v_cnt % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if ((h_cnt % 20 == 16 && v_cnt % 20 == 1) || (h_cnt % 20 == 15 && v_cnt % 20 == 2) || (h_cnt % 20 == 14 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 14) || (h_cnt % 20 == 2 && v_cnt % 20 == 15) || (h_cnt % 20 == 1 && v_cnt % 20 == 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf70;
                        end
                        else if ((h_cnt % 20 == 17 && v_cnt % 20 == 1) || (h_cnt % 20 == 16 && v_cnt % 20 == 2) || (h_cnt % 20 == 15 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 15) || (h_cnt % 20 == 2 && v_cnt % 20 == 16) || (h_cnt % 20 == 1 && v_cnt % 20 == 17)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf80;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 1) || (h_cnt % 20 == 17 && v_cnt % 20 == 2) || (h_cnt % 20 == 16 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 16) || (h_cnt % 20 == 2 && v_cnt % 20 == 17) || (h_cnt % 20 == 1 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf90;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 2) || (h_cnt % 20 == 17 && v_cnt % 20 == 3) || (h_cnt % 20 == 16 && v_cnt % 20 == 4) || (h_cnt % 20 == 4 && v_cnt % 20 == 16) || (h_cnt % 20 == 3 && v_cnt % 20 == 17) || (h_cnt % 20 == 2 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hfa0;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 3) || (h_cnt % 20 == 17 && v_cnt % 20 == 4) || (h_cnt % 20 == 16 && v_cnt % 20 == 5) || (h_cnt % 20 == 5 && v_cnt % 20 == 16) || (h_cnt % 20 == 4 && v_cnt % 20 == 17) || (h_cnt % 20 == 3 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hfb0;
                        end
                        else if ((h_cnt % 20 < 16 && v_cnt % 20 < 4) || (h_cnt % 20 < 4 && v_cnt % 20 < 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf60;
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hfc0;
                        end
                    end
                    `J_BLOCK: begin
                        if(v_cnt % 20 == 0 || h_cnt % 20 == 0 || v_cnt % 20 == 19 || h_cnt % 20 == 19) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if (v_cnt % 20 > 3 && v_cnt % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if ((h_cnt % 20 == 16 && v_cnt % 20 == 1) || (h_cnt % 20 == 15 && v_cnt % 20 == 2) || (h_cnt % 20 == 14 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 14) || (h_cnt % 20 == 2 && v_cnt % 20 == 15) || (h_cnt % 20 == 1 && v_cnt % 20 == 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h10f;
                        end
                        else if ((h_cnt % 20 == 17 && v_cnt % 20 == 1) || (h_cnt % 20 == 16 && v_cnt % 20 == 2) || (h_cnt % 20 == 15 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 15) || (h_cnt % 20 == 2 && v_cnt % 20 == 16) || (h_cnt % 20 == 1 && v_cnt % 20 == 17)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h20f;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 1) || (h_cnt % 20 == 17 && v_cnt % 20 == 2) || (h_cnt % 20 == 16 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 16) || (h_cnt % 20 == 2 && v_cnt % 20 == 17) || (h_cnt % 20 == 1 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h30f;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 2) || (h_cnt % 20 == 17 && v_cnt % 20 == 3) || (h_cnt % 20 == 16 && v_cnt % 20 == 4) || (h_cnt % 20 == 4 && v_cnt % 20 == 16) || (h_cnt % 20 == 3 && v_cnt % 20 == 17) || (h_cnt % 20 == 2 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h40f;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 3) || (h_cnt % 20 == 17 && v_cnt % 20 == 4) || (h_cnt % 20 == 16 && v_cnt % 20 == 5) || (h_cnt % 20 == 5 && v_cnt % 20 == 16) || (h_cnt % 20 == 4 && v_cnt % 20 == 17) || (h_cnt % 20 == 3 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h50f;
                        end
                        else if ((h_cnt % 20 < 16 && v_cnt % 20 < 4) || (h_cnt % 20 < 4 && v_cnt % 20 < 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h00f;
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h60f;
                        end
                    end
                    `T_BLOCK: begin
                        if(v_cnt % 20 == 0 || h_cnt % 20 == 0 || v_cnt % 20 == 19 || h_cnt % 20 == 19) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if (v_cnt % 20 > 3 && v_cnt % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if ((h_cnt % 20 == 16 && v_cnt % 20 == 1) || (h_cnt % 20 == 15 && v_cnt % 20 == 2) || (h_cnt % 20 == 14 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 14) || (h_cnt % 20 == 2 && v_cnt % 20 == 15) || (h_cnt % 20 == 1 && v_cnt % 20 == 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf0e;
                        end
                        else if ((h_cnt % 20 == 17 && v_cnt % 20 == 1) || (h_cnt % 20 == 16 && v_cnt % 20 == 2) || (h_cnt % 20 == 15 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 15) || (h_cnt % 20 == 2 && v_cnt % 20 == 16) || (h_cnt % 20 == 1 && v_cnt % 20 == 17)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf0d;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 1) || (h_cnt % 20 == 17 && v_cnt % 20 == 2) || (h_cnt % 20 == 16 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 16) || (h_cnt % 20 == 2 && v_cnt % 20 == 17) || (h_cnt % 20 == 1 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf0c;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 2) || (h_cnt % 20 == 17 && v_cnt % 20 == 3) || (h_cnt % 20 == 16 && v_cnt % 20 == 4) || (h_cnt % 20 == 4 && v_cnt % 20 == 16) || (h_cnt % 20 == 3 && v_cnt % 20 == 17) || (h_cnt % 20 == 2 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf0b;
                        end
                        else if ((h_cnt % 20 == 18 && v_cnt % 20 == 3) || (h_cnt % 20 == 17 && v_cnt % 20 == 4) || (h_cnt % 20 == 16 && v_cnt % 20 == 5) || (h_cnt % 20 == 5 && v_cnt % 20 == 16) || (h_cnt % 20 == 4 && v_cnt % 20 == 17) || (h_cnt % 20 == 3 && v_cnt % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf0a;
                        end
                        else if ((h_cnt % 20 < 16 && v_cnt % 20 < 4) || (h_cnt % 20 < 4 && v_cnt % 20 < 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf0f;
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hf09;
                        end
                    end
                    default: begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                    end
                endcase
                // {vgaRed, vgaGreen, vgaBlue} = pixel;
            end
            else if(shadowY[0] == memoryY && ctrlX[0] == memoryX || shadowY[1] == memoryY && ctrlX[1] == memoryX|| shadowY[2] == memoryY && ctrlX[2] == memoryX|| shadowY[3] == memoryY && ctrlX[3] == memoryX) begin
                {vgaRed, vgaGreen, vgaBlue} = 12'h666;
            end
            else begin
                {vgaRed, vgaGreen, vgaBlue} = pixel_back;
            end
        end
        else if (h_cnt > 450 && h_cnt < 550 && v_cnt > 65 && v_cnt < 115 ) begin
            if(first == 0) begin
                if(h_cnt >= 470 && h_cnt < 530 && v_cnt >= 70 && v_cnt < 110) begin
                    if(h_cnt >= 510 && h_cnt < 530 && v_cnt >= 70 && v_cnt < 90) begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                    end
                    else if(h_cnt >= 490 && h_cnt < 510 && v_cnt >= 70 && v_cnt < 90) begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                    end
                    else begin
                        if((v_cnt + 10) % 20 == 0 || (h_cnt + 10) % 20 == 0 || (v_cnt + 10) % 20 == 19 || (h_cnt + 10) % 20 == 19) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && (h_cnt + 10) % 20 > 3 && (h_cnt + 10) % 20 < 16) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if (((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 14 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 14) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h10f;
                        end
                        else if (((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 17)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h20f;
                        end
                        else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h30f;
                        end
                        else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h40f;
                        end
                        else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 5) || ((h_cnt + 10) % 20 == 5 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 18)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h50f;
                        end
                        else if (((h_cnt + 10) % 20 < 16 && (v_cnt + 10) % 20 < 4) || ((h_cnt + 10) % 20 < 4 && (v_cnt + 10) % 20 < 16)) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h00f;
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h60f;
                        end
                    end
                end
                else begin
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                end
            end
            else begin
                case(random_block)
                    `O_BLOCK: begin
                        //O
                        if(h_cnt >= 480 && h_cnt < 520 && v_cnt >= 70 && v_cnt < 110) begin
                            if((v_cnt + 10) % 20 == 0 || h_cnt % 20 == 0 || (v_cnt + 10) % 20 == 19 || h_cnt % 20 == 19) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else if ((h_cnt % 20 == 16 && (v_cnt + 10) % 20 == 1) || (h_cnt % 20 == 15 && (v_cnt + 10) % 20 == 2) || (h_cnt % 20 == 14 && (v_cnt + 10) % 20 == 3) || (h_cnt % 20 == 3 && (v_cnt + 10) % 20 == 14) || (h_cnt % 20 == 2 && (v_cnt + 10) % 20 == 15) || (h_cnt % 20 == 1 && (v_cnt + 10) % 20 == 16)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'hef0;
                            end
                            else if ((h_cnt % 20 == 17 && (v_cnt + 10) % 20 == 1) || (h_cnt % 20 == 16 && (v_cnt + 10) % 20 == 2) || (h_cnt % 20 == 15 && (v_cnt + 10) % 20 == 3) || (h_cnt % 20 == 3 && (v_cnt + 10) % 20 == 15) || (h_cnt % 20 == 2 && (v_cnt + 10) % 20 == 16) || (h_cnt % 20 == 1 && (v_cnt + 10) % 20 == 17)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'hdf0;
                            end
                            else if ((h_cnt % 20 == 18 && (v_cnt + 10) % 20 == 1) || (h_cnt % 20 == 17 && (v_cnt + 10) % 20 == 2) || (h_cnt % 20 == 16 && (v_cnt + 10) % 20 == 3) || (h_cnt % 20 == 3 && (v_cnt + 10) % 20 == 16) || (h_cnt % 20 == 2 && (v_cnt + 10) % 20 == 17) || (h_cnt % 20 == 1 && (v_cnt + 10) % 20 == 18)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'hcf0;
                            end
                            else if ((h_cnt % 20 == 18 && (v_cnt + 10) % 20 == 2) || (h_cnt % 20 == 17 && (v_cnt + 10) % 20 == 3) || (h_cnt % 20 == 16 && (v_cnt + 10) % 20 == 4) || (h_cnt % 20 == 4 && (v_cnt + 10) % 20 == 16) || (h_cnt % 20 == 3 && (v_cnt + 10) % 20 == 17) || (h_cnt % 20 == 2 && (v_cnt + 10) % 20 == 18)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'hbf0;
                            end
                            else if ((h_cnt % 20 == 18 && (v_cnt + 10) % 20 == 3) || (h_cnt % 20 == 17 && (v_cnt + 10) % 20 == 4) || (h_cnt % 20 == 16 && (v_cnt + 10) % 20 == 5) || (h_cnt % 20 == 5 && (v_cnt + 10) % 20 == 16) || (h_cnt % 20 == 4 && (v_cnt + 10) % 20 == 17) || (h_cnt % 20 == 3 && (v_cnt + 10) % 20 == 18)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'haf0;
                            end
                            else if ((h_cnt % 20 < 16 && (v_cnt + 10) % 20 < 4) || (h_cnt % 20 < 4 && (v_cnt + 10) % 20 < 16)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'hff0;
                            end
                            else begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h9f0;
                            end
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                    end
                    `L_BLOCK: begin
                        //L
                        if(h_cnt >= 470 && h_cnt < 530 && v_cnt >= 70 && v_cnt < 110) begin
                            if(h_cnt >= 490 && h_cnt < 510 && v_cnt >= 70 && v_cnt < 90) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                            end
                            else if(h_cnt >= 470 && h_cnt < 490 && v_cnt >= 70 && v_cnt < 90) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                            end
                            else begin
                                if((v_cnt + 10) % 20 == 0 || (h_cnt + 10) % 20 == 0 || (v_cnt + 10) % 20 == 19 || (h_cnt + 10) % 20 == 19) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                                end
                                else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && (h_cnt + 10) % 20 > 3 && (h_cnt + 10) % 20 < 16) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                                end
                                else if (((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 14 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 14) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 16)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf70;
                                end
                                else if (((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 17)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf80;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf90;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hfa0;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 5) || ((h_cnt + 10) % 20 == 5 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hfb0;
                                end
                                else if (((h_cnt + 10) % 20 < 16 && (v_cnt + 10) % 20 < 4) || ((h_cnt + 10) % 20 < 4 && (v_cnt + 10) % 20 < 16)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf60;
                                end
                                else begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hfc0;
                                end
                            end
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                    end
                    `J_BLOCK: begin
                        //J
                        if(h_cnt >= 470 && h_cnt < 530 && v_cnt >= 70 && v_cnt < 110) begin
                            if(h_cnt >= 510 && h_cnt < 530 && v_cnt >= 70 && v_cnt < 90) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                            end
                            else if(h_cnt >= 490 && h_cnt < 510 && v_cnt >= 70 && v_cnt < 90) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                            end
                            else begin
                                if((v_cnt + 10) % 20 == 0 || (h_cnt + 10) % 20 == 0 || (v_cnt + 10) % 20 == 19 || (h_cnt + 10) % 20 == 19) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                                end
                                else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && (h_cnt + 10) % 20 > 3 && (h_cnt + 10) % 20 < 16) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                                end
                                else if (((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 14 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 14) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 16)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h10f;
                                end
                                else if (((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 17)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h20f;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h30f;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h40f;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 5) || ((h_cnt + 10) % 20 == 5 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h50f;
                                end
                                else if (((h_cnt + 10) % 20 < 16 && (v_cnt + 10) % 20 < 4) || ((h_cnt + 10) % 20 < 4 && (v_cnt + 10) % 20 < 16)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h00f;
                                end
                                else begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h60f;
                                end
                            end
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                    end
                    `S_BLOCK: begin
                        //S
                        if(h_cnt >= 470 && h_cnt < 530 && v_cnt >= 70 && v_cnt < 110) begin
                            if(h_cnt >= 510 && h_cnt < 530 && v_cnt >= 90 && v_cnt < 110) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                            end
                            else if(h_cnt >= 470 && h_cnt < 490 && v_cnt >= 70 && v_cnt < 90) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                            end
                            else begin
                                if((v_cnt + 10) % 20 == 0 || (h_cnt + 10) % 20 == 0 || (v_cnt + 10) % 20 == 19 || (h_cnt + 10) % 20 == 19) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                                end
                                else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && (h_cnt + 10) % 20 > 3 && (h_cnt + 10) % 20 < 16) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                                end
                                else if (((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 14 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 14) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 16)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h0f4;
                                end
                                else if (((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 17)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h0f5;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h0f6;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h0f7;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 5) || ((h_cnt + 10) % 20 == 5 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h0f8;
                                end
                                else if (((h_cnt + 10) % 20 < 16 && (v_cnt + 10) % 20 < 4) || ((h_cnt + 10) % 20 < 4 && (v_cnt + 10) % 20 < 16)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h0f3;
                                end
                                else begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h0f9;
                                end
                            end
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                    end
                    `Z_BLOCK: begin
                        //Z
                        if(h_cnt >= 470 && h_cnt < 530 && v_cnt >= 70 && v_cnt < 110) begin
                            if(h_cnt >= 510 && h_cnt < 530 && v_cnt >= 70 && v_cnt < 90) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                            end
                            else if(h_cnt >= 470 && h_cnt < 490 && v_cnt >= 90 && v_cnt < 110) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                            end
                            else begin
                                if((v_cnt + 10) % 20 == 0 || (h_cnt + 10) % 20 == 0 || (v_cnt + 10) % 20 == 19 || (h_cnt + 10) % 20 == 19) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                                end
                                else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && (h_cnt + 10) % 20 > 3 && (h_cnt + 10) % 20 < 16) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                                end
                                else if (((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 14 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 14) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 16)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf10;
                                end
                                else if (((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 17)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf20;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf30;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf40;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 5) || ((h_cnt + 10) % 20 == 5 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf50;
                                end
                                else if (((h_cnt + 10) % 20 < 16 && (v_cnt + 10) % 20 < 4) || ((h_cnt + 10) % 20 < 4 && (v_cnt + 10) % 20 < 16)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf00;
                                end
                                else begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf60;
                                end
                            end
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                    end
                    `I_BLOCK: begin
                        //I
                        if(h_cnt >= 460 && h_cnt < 540 && v_cnt >= 80 && v_cnt < 100) begin
                            if(v_cnt % 20 == 0 || h_cnt % 20 == 0 || v_cnt % 20 == 19 || h_cnt % 20 == 19) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else if (v_cnt % 20 > 3 && v_cnt % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else if ((h_cnt % 20 == 16 && v_cnt % 20 == 1) || (h_cnt % 20 == 15 && v_cnt % 20 == 2) || (h_cnt % 20 == 14 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 14) || (h_cnt % 20 == 2 && v_cnt % 20 == 15) || (h_cnt % 20 == 1 && v_cnt % 20 == 16)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0ef;
                            end
                            else if ((h_cnt % 20 == 17 && v_cnt % 20 == 1) || (h_cnt % 20 == 16 && v_cnt % 20 == 2) || (h_cnt % 20 == 15 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 15) || (h_cnt % 20 == 2 && v_cnt % 20 == 16) || (h_cnt % 20 == 1 && v_cnt % 20 == 17)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0df;
                            end
                            else if ((h_cnt % 20 == 18 && v_cnt % 20 == 1) || (h_cnt % 20 == 17 && v_cnt % 20 == 2) || (h_cnt % 20 == 16 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 16) || (h_cnt % 20 == 2 && v_cnt % 20 == 17) || (h_cnt % 20 == 1 && v_cnt % 20 == 18)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0cf;
                            end
                            else if ((h_cnt % 20 == 18 && v_cnt % 20 == 2) || (h_cnt % 20 == 17 && v_cnt % 20 == 3) || (h_cnt % 20 == 16 && v_cnt % 20 == 4) || (h_cnt % 20 == 4 && v_cnt % 20 == 16) || (h_cnt % 20 == 3 && v_cnt % 20 == 17) || (h_cnt % 20 == 2 && v_cnt % 20 == 18)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0bf;
                            end
                            else if ((h_cnt % 20 == 18 && v_cnt % 20 == 3) || (h_cnt % 20 == 17 && v_cnt % 20 == 4) || (h_cnt % 20 == 16 && v_cnt % 20 == 5) || (h_cnt % 20 == 5 && v_cnt % 20 == 16) || (h_cnt % 20 == 4 && v_cnt % 20 == 17) || (h_cnt % 20 == 3 && v_cnt % 20 == 18)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0af;
                            end
                            else if ((h_cnt % 20 < 16 && v_cnt % 20 < 4) || (h_cnt % 20 < 4 && v_cnt % 20 < 16)) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0ff;
                            end
                            else begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h09f;
                            end
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                    end
                    `T_BLOCK: begin
                        //T
                        if(h_cnt >= 470 && h_cnt < 530 && v_cnt >= 70 && v_cnt < 110) begin
                            if(h_cnt >= 470 && h_cnt < 490 && v_cnt >= 70 && v_cnt < 90) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                            end
                            else if(h_cnt >= 510 && h_cnt < 530 && v_cnt >= 70 && v_cnt < 90) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                            end
                            else begin
                                if((v_cnt + 10) % 20 == 0 || (h_cnt + 10) % 20 == 0 || (v_cnt + 10) % 20 == 19 || (h_cnt + 10) % 20 == 19) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                                end
                                else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && (h_cnt + 10) % 20 > 3 && (h_cnt + 10) % 20 < 16) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                                end
                                else if (((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 14 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 14) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 16)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf0e;
                                end
                                else if (((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 15 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 15) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 17)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf0d;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 1) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 1 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf0c;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 2) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 2 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf0b;
                                end
                                else if (((h_cnt + 10) % 20 == 18 && (v_cnt + 10) % 20 == 3) || ((h_cnt + 10) % 20 == 17 && (v_cnt + 10) % 20 == 4) || ((h_cnt + 10) % 20 == 16 && (v_cnt + 10) % 20 == 5) || ((h_cnt + 10) % 20 == 5 && (v_cnt + 10) % 20 == 16) || ((h_cnt + 10) % 20 == 4 && (v_cnt + 10) % 20 == 17) || ((h_cnt + 10) % 20 == 3 && (v_cnt + 10) % 20 == 18)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf0a;
                                end
                                else if (((h_cnt + 10) % 20 < 16 && (v_cnt + 10) % 20 < 4) || ((h_cnt + 10) % 20 < 4 && (v_cnt + 10) % 20 < 16)) begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf0f;
                                end
                                else begin
                                    {vgaRed, vgaGreen, vgaBlue} = 12'hf09;
                                end
                            end
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                    end
                endcase
            end

        end
        else if(h_cnt >= 100 && h_cnt <= 210 && v_cnt >= 60 && v_cnt <= 110) begin
            case(hold_block)
                `O_BLOCK: begin
                    if(h_cnt >= 130 && h_cnt < 170 && v_cnt >= 70 && v_cnt < 110) begin
                        if((v_cnt + 10) % 20 == 0 || (h_cnt + 10) % 20 == 0 || (v_cnt + 10) % 20 == 19 || (h_cnt + 10) % 20 == 19) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && (h_cnt + 10) % 20 > 3 && (h_cnt + 10) % 20 < 16) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hbbb;
                        end
                    end
                    else begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                    end
                end
                `L_BLOCK: begin
                    if(h_cnt >= 120 && h_cnt < 180 && v_cnt >= 70 && v_cnt < 110) begin
                        if(h_cnt >= 140 && h_cnt < 160 && v_cnt >= 70 && v_cnt < 90) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                        else if(h_cnt >= 120 && h_cnt < 140 && v_cnt >= 70 && v_cnt < 90) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                        else begin
                            if((v_cnt + 10) % 20 == 0 || h_cnt % 20 == 0 || (v_cnt + 10) % 20 == 19 || h_cnt % 20 == 19) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'hbbb;
                            end
                        end
                    end
                    else begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                    end
                end
                `J_BLOCK: begin
                    if(h_cnt >= 120 && h_cnt < 180 && v_cnt >= 70 && v_cnt < 110) begin
                        if(h_cnt >= 140 && h_cnt < 160 && v_cnt >= 70 && v_cnt < 90) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                        else if(h_cnt >= 160 && h_cnt < 180 && v_cnt >= 70 && v_cnt < 90) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                        else begin
                            if((v_cnt + 10) % 20 == 0 || h_cnt % 20 == 0 || (v_cnt + 10) % 20 == 19 || h_cnt % 20 == 19) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'hbbb;
                            end
                        end
                    end
                    else begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                    end
                end
                `S_BLOCK: begin
                    if(h_cnt >= 120 && h_cnt < 180 && v_cnt >= 70 && v_cnt < 110) begin
                        if(h_cnt >= 160 && h_cnt < 180 && v_cnt >= 90 && v_cnt < 110) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                        else if(h_cnt >= 120 && h_cnt < 140 && v_cnt >= 70 && v_cnt < 90) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                        else begin
                            if((v_cnt + 10) % 20 == 0 || h_cnt % 20 == 0 || (v_cnt + 10) % 20 == 19 || h_cnt % 20 == 19) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'hbbb;
                            end
                        end
                    end
                    else begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                    end
                end
                `Z_BLOCK: begin
                    if(h_cnt >= 120 && h_cnt < 180 && v_cnt >= 70 && v_cnt < 110) begin
                        if(h_cnt >= 160 && h_cnt < 180 && v_cnt >= 70 && v_cnt < 90) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                        else if(h_cnt >= 120 && h_cnt < 140 && v_cnt >= 90 && v_cnt < 110) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                        else begin
                            if((v_cnt + 10) % 20 == 0 || h_cnt % 20 == 0 || (v_cnt + 10) % 20 == 19 || h_cnt % 20 == 19) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'hbbb;
                            end
                        end
                    end
                    else begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                    end
                end
                `I_BLOCK: begin
                    if(h_cnt >= 110 && h_cnt < 190 && v_cnt >= 80 && v_cnt < 100) begin
                        if(v_cnt % 20 == 0 || (h_cnt + 10) % 20 == 0 || v_cnt % 20 == 19 || (h_cnt + 10) % 20 == 19) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else if (v_cnt % 20 > 3 && v_cnt % 20 < 16 && (h_cnt + 10) % 20 > 3 && (h_cnt + 10) % 20 < 16) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                        end
                        else begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'hbbb;
                        end
                    end
                    else begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                    end
                end
                `T_BLOCK: begin
                    if(h_cnt >= 120 && h_cnt < 180 && v_cnt >= 70 && v_cnt < 110) begin
                        if(h_cnt >= 120 && h_cnt < 140 && v_cnt >= 70 && v_cnt < 90) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                        else if(h_cnt >= 160 && h_cnt < 180 && v_cnt >= 70 && v_cnt < 90) begin
                            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                        end
                        else begin
                            if((v_cnt + 10) % 20 == 0 || h_cnt % 20 == 0 || (v_cnt + 10) % 20 == 19 || h_cnt % 20 == 19) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else if ((v_cnt + 10) % 20 > 3 && (v_cnt + 10) % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                            end
                            else begin
                                {vgaRed, vgaGreen, vgaBlue} = 12'hbbb;
                            end
                        end
                    end
                    else begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                    end
                end
                default: begin
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                end
            endcase
        end
        else if(v_cnt <= 35 || h_cnt <= 92 || h_cnt > 562 || v_cnt >= 446 || (h_cnt > 92 && h_cnt <= 215 && v_cnt>= 122 && v_cnt <= 446) || (h_cnt > 438 && h_cnt <= 563 && v_cnt >= 122 && v_cnt <= 446) || (h_cnt > 425 && h_cnt < 440 && v_cnt> 34 && v_cnt <= 446)) begin
            if(score < 80) begin
                if(v_cnt < 480-score*6) begin
                    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
                end
                else begin
                    {vgaRed, vgaGreen, vgaBlue} = pixel_back + shine;
                end
            end
            else begin
                {vgaRed, vgaGreen, vgaBlue} = pixel_back + shine;
            end
        end
        else begin
            {vgaRed, vgaGreen, vgaBlue} = pixel_back + shine;
        end
    end
    else begin
        {vgaRed, vgaGreen, vgaBlue} = 12'h0;
    end
end


// update game scene
always@ (posedge clk) begin
    if(gamestart) begin
        if(start) begin
            boardMemory_type[0] <= 0;
            boardMemory_type[1] <= 0;
            boardMemory_type[2] <= 0;
            boardMemory_type[3] <= 0;
            boardMemory_type[4] <= 0;
            boardMemory_type[5] <= 0;
            boardMemory_type[6] <= 0;
            boardMemory_type[7] <= 0;
            boardMemory_type[8] <= 0;
            boardMemory_type[9] <= 0;
            boardMemory_type[10] <= 0;
            boardMemory_type[11] <= 0;
            boardMemory_type[12] <= 0;
            boardMemory_type[13] <= 0;
            boardMemory_type[14] <= 0;
            boardMemory_type[15] <= 0;
            boardMemory_type[16] <= 0;
            boardMemory_type[17] <= 0;
            boardMemory_type[18] <= 0;
            boardMemory_type[19] <= 0;
            boardMemory_type[20] <= 0;
            boardMemory_type[21] <= 0;
            boardMemory_type[22] <= 0;
            boardMemory_type[23] <= 0;
            boardMemory_type[24] <= 0;
            boardMemory_type[25] <= 0;
            boardMemory_type[26] <= 0;
            boardMemory_type[27] <= 0;
            boardMemory_type[28] <= 0;
            boardMemory_type[29] <= 0;
            boardMemory_type[30] <= 0;
            boardMemory_type[31] <= 0;
            boardMemory_type[32] <= 0;
            boardMemory_type[33] <= 0;
            boardMemory_type[34] <= 0;
            boardMemory_type[35] <= 0;
            boardMemory_type[36] <= 0;
            boardMemory_type[37] <= 0;
            boardMemory_type[38] <= 0;
            boardMemory_type[39] <= 0;
            boardMemory_type[40] <= 0;
            boardMemory_type[41] <= 0;
            boardMemory_type[42] <= 0;
            boardMemory_type[43] <= 0;
            boardMemory_type[44] <= 0;
            boardMemory_type[45] <= 0;
            boardMemory_type[46] <= 0;
            boardMemory_type[47] <= 0;
            boardMemory_type[48] <= 0;
            boardMemory_type[49] <= 0;
            boardMemory_type[50] <= 0;
            boardMemory_type[51] <= 0;
            boardMemory_type[52] <= 0;
            boardMemory_type[53] <= 0;
            boardMemory_type[54] <= 0;
            boardMemory_type[55] <= 0;
            boardMemory_type[56] <= 0;
            boardMemory_type[57] <= 0;
            boardMemory_type[58] <= 0;
            boardMemory_type[59] <= 0;
            boardMemory_type[60] <= 0;
            boardMemory_type[61] <= 0;
            boardMemory_type[62] <= 0;
            boardMemory_type[63] <= 0;
            boardMemory_type[64] <= 0;
            boardMemory_type[65] <= 0;
            boardMemory_type[66] <= 0;
            boardMemory_type[67] <= 0;
            boardMemory_type[68] <= 0;
            boardMemory_type[69] <= 0;
            boardMemory_type[70] <= 0;
            boardMemory_type[71] <= 0;
            boardMemory_type[72] <= 0;
            boardMemory_type[73] <= 0;
            boardMemory_type[74] <= 0;
            boardMemory_type[75] <= 0;
            boardMemory_type[76] <= 0;
            boardMemory_type[77] <= 0;
            boardMemory_type[78] <= 0;
            boardMemory_type[79] <= 0;
            boardMemory_type[80] <= 0;
            boardMemory_type[81] <= 0;
            boardMemory_type[82] <= 0;
            boardMemory_type[83] <= 0;
            boardMemory_type[84] <= 0;
            boardMemory_type[85] <= 0;
            boardMemory_type[86] <= 0;
            boardMemory_type[87] <= 0;
            boardMemory_type[88] <= 0;
            boardMemory_type[89] <= 0;
            boardMemory_type[90] <= 0;
            boardMemory_type[91] <= 0;
            boardMemory_type[92] <= 0;
            boardMemory_type[93] <= 0;
            boardMemory_type[94] <= 0;
            boardMemory_type[95] <= 0;
            boardMemory_type[96] <= 0;
            boardMemory_type[97] <= 0;
            boardMemory_type[98] <= 0;
            boardMemory_type[99] <= 0;
            boardMemory_type[100] <= 0;
            boardMemory_type[101] <= 0;
            boardMemory_type[102] <= 0;
            boardMemory_type[103] <= 0;
            boardMemory_type[104] <= 0;
            boardMemory_type[105] <= 0;
            boardMemory_type[106] <= 0;
            boardMemory_type[107] <= 0;
            boardMemory_type[108] <= 0;
            boardMemory_type[109] <= 0;
            boardMemory_type[110] <= 0;
            boardMemory_type[111] <= 0;
            boardMemory_type[112] <= 0;
            boardMemory_type[113] <= 0;
            boardMemory_type[114] <= 0;
            boardMemory_type[115] <= 0;
            boardMemory_type[116] <= 0;
            boardMemory_type[117] <= 0;
            boardMemory_type[118] <= 0;
            boardMemory_type[119] <= 0;
            boardMemory_type[120] <= 0;
            boardMemory_type[121] <= 0;
            boardMemory_type[122] <= 0;
            boardMemory_type[123] <= 0;
            boardMemory_type[124] <= 0;
            boardMemory_type[125] <= 0;
            boardMemory_type[126] <= 0;
            boardMemory_type[127] <= 0;
            boardMemory_type[128] <= 0;
            boardMemory_type[129] <= 0;
            boardMemory_type[130] <= 0;
            boardMemory_type[131] <= 0;
            boardMemory_type[132] <= 0;
            boardMemory_type[133] <= 0;
            boardMemory_type[134] <= 0;
            boardMemory_type[135] <= 0;
            boardMemory_type[136] <= 0;
            boardMemory_type[137] <= 0;
            boardMemory_type[138] <= 0;
            boardMemory_type[139] <= 0;
            boardMemory_type[140] <= 0;
            boardMemory_type[141] <= 0;
            boardMemory_type[142] <= 0;
            boardMemory_type[143] <= 0;
            boardMemory_type[144] <= 0;
            boardMemory_type[145] <= 0;
            boardMemory_type[146] <= 0;
            boardMemory_type[147] <= 0;
            boardMemory_type[148] <= 0;
            boardMemory_type[149] <= 0;
            boardMemory_type[150] <= 0;
            boardMemory_type[151] <= 0;
            boardMemory_type[152] <= 0;
            boardMemory_type[153] <= 0;
            boardMemory_type[154] <= 0;
            boardMemory_type[155] <= 0;
            boardMemory_type[156] <= 0;
            boardMemory_type[157] <= 0;
            boardMemory_type[158] <= 0;
            boardMemory_type[159] <= 0;
            boardMemory_type[160] <= 0;
            boardMemory_type[161] <= 0;
            boardMemory_type[162] <= 0;
            boardMemory_type[163] <= 0;
            boardMemory_type[164] <= 0;
            boardMemory_type[165] <= 0;
            boardMemory_type[166] <= 0;
            boardMemory_type[167] <= 0;
            boardMemory_type[168] <= 0;
            boardMemory_type[169] <= 0;
            boardMemory_type[170] <= 0;
            boardMemory_type[171] <= 0;
            boardMemory_type[172] <= 0;
            boardMemory_type[173] <= 0;
            boardMemory_type[174] <= 0;
            boardMemory_type[175] <= 0;
            boardMemory_type[176] <= 0;
            boardMemory_type[177] <= 0;
            boardMemory_type[178] <= 0;
            boardMemory_type[179] <= 0;
            boardMemory_type[180] <= 0;
            boardMemory_type[181] <= 0;
            boardMemory_type[182] <= 0;
            boardMemory_type[183] <= 0;
            boardMemory_type[184] <= 0;
            boardMemory_type[185] <= 0;
            boardMemory_type[186] <= 0;
            boardMemory_type[187] <= 0;
            boardMemory_type[188] <= 0;
            boardMemory_type[189] <= 0;
            boardMemory_type[190] <= 0;
            boardMemory_type[191] <= 0;
            boardMemory_type[192] <= 0;
            boardMemory_type[193] <= 0;
            boardMemory_type[194] <= 0;
            boardMemory_type[195] <= 0;
            boardMemory_type[196] <= 0;
            boardMemory_type[197] <= 0;
            boardMemory_type[198] <= 0;
            boardMemory_type[199] <= 0;
            boardMemory <= 200'b0000010000_0001110000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000;
        end
        else if(drop) begin
            if(fullLines[19]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory_type[100] <= boardMemory_type[90];
                boardMemory_type[101] <= boardMemory_type[91];
                boardMemory_type[102] <= boardMemory_type[92];
                boardMemory_type[103] <= boardMemory_type[93];
                boardMemory_type[104] <= boardMemory_type[94];
                boardMemory_type[105] <= boardMemory_type[95];
                boardMemory_type[106] <= boardMemory_type[96];
                boardMemory_type[107] <= boardMemory_type[97];
                boardMemory_type[108] <= boardMemory_type[98];
                boardMemory_type[109] <= boardMemory_type[99];
                boardMemory_type[110] <= boardMemory_type[100];
                boardMemory_type[111] <= boardMemory_type[101];
                boardMemory_type[112] <= boardMemory_type[102];
                boardMemory_type[113] <= boardMemory_type[103];
                boardMemory_type[114] <= boardMemory_type[104];
                boardMemory_type[115] <= boardMemory_type[105];
                boardMemory_type[116] <= boardMemory_type[106];
                boardMemory_type[117] <= boardMemory_type[107];
                boardMemory_type[118] <= boardMemory_type[108];
                boardMemory_type[119] <= boardMemory_type[109];
                boardMemory_type[120] <= boardMemory_type[110];
                boardMemory_type[121] <= boardMemory_type[111];
                boardMemory_type[122] <= boardMemory_type[112];
                boardMemory_type[123] <= boardMemory_type[113];
                boardMemory_type[124] <= boardMemory_type[114];
                boardMemory_type[125] <= boardMemory_type[115];
                boardMemory_type[126] <= boardMemory_type[116];
                boardMemory_type[127] <= boardMemory_type[117];
                boardMemory_type[128] <= boardMemory_type[118];
                boardMemory_type[129] <= boardMemory_type[119];
                boardMemory_type[130] <= boardMemory_type[120];
                boardMemory_type[131] <= boardMemory_type[121];
                boardMemory_type[132] <= boardMemory_type[122];
                boardMemory_type[133] <= boardMemory_type[123];
                boardMemory_type[134] <= boardMemory_type[124];
                boardMemory_type[135] <= boardMemory_type[125];
                boardMemory_type[136] <= boardMemory_type[126];
                boardMemory_type[137] <= boardMemory_type[127];
                boardMemory_type[138] <= boardMemory_type[128];
                boardMemory_type[139] <= boardMemory_type[129];
                boardMemory_type[140] <= boardMemory_type[130];
                boardMemory_type[141] <= boardMemory_type[131];
                boardMemory_type[142] <= boardMemory_type[132];
                boardMemory_type[143] <= boardMemory_type[133];
                boardMemory_type[144] <= boardMemory_type[134];
                boardMemory_type[145] <= boardMemory_type[135];
                boardMemory_type[146] <= boardMemory_type[136];
                boardMemory_type[147] <= boardMemory_type[137];
                boardMemory_type[148] <= boardMemory_type[138];
                boardMemory_type[149] <= boardMemory_type[139];
                boardMemory_type[150] <= boardMemory_type[140];
                boardMemory_type[151] <= boardMemory_type[141];
                boardMemory_type[152] <= boardMemory_type[142];
                boardMemory_type[153] <= boardMemory_type[143];
                boardMemory_type[154] <= boardMemory_type[144];
                boardMemory_type[155] <= boardMemory_type[145];
                boardMemory_type[156] <= boardMemory_type[146];
                boardMemory_type[157] <= boardMemory_type[147];
                boardMemory_type[158] <= boardMemory_type[148];
                boardMemory_type[159] <= boardMemory_type[149];
                boardMemory_type[160] <= boardMemory_type[150];
                boardMemory_type[161] <= boardMemory_type[151];
                boardMemory_type[162] <= boardMemory_type[152];
                boardMemory_type[163] <= boardMemory_type[153];
                boardMemory_type[164] <= boardMemory_type[154];
                boardMemory_type[165] <= boardMemory_type[155];
                boardMemory_type[166] <= boardMemory_type[156];
                boardMemory_type[167] <= boardMemory_type[157];
                boardMemory_type[168] <= boardMemory_type[158];
                boardMemory_type[169] <= boardMemory_type[159];
                boardMemory_type[170] <= boardMemory_type[160];
                boardMemory_type[171] <= boardMemory_type[161];
                boardMemory_type[172] <= boardMemory_type[162];
                boardMemory_type[173] <= boardMemory_type[163];
                boardMemory_type[174] <= boardMemory_type[164];
                boardMemory_type[175] <= boardMemory_type[165];
                boardMemory_type[176] <= boardMemory_type[166];
                boardMemory_type[177] <= boardMemory_type[167];
                boardMemory_type[178] <= boardMemory_type[168];
                boardMemory_type[179] <= boardMemory_type[169];
                boardMemory_type[180] <= boardMemory_type[170];
                boardMemory_type[181] <= boardMemory_type[171];
                boardMemory_type[182] <= boardMemory_type[172];
                boardMemory_type[183] <= boardMemory_type[173];
                boardMemory_type[184] <= boardMemory_type[174];
                boardMemory_type[185] <= boardMemory_type[175];
                boardMemory_type[186] <= boardMemory_type[176];
                boardMemory_type[187] <= boardMemory_type[177];
                boardMemory_type[188] <= boardMemory_type[178];
                boardMemory_type[189] <= boardMemory_type[179];
                boardMemory_type[190] <= boardMemory_type[180];
                boardMemory_type[191] <= boardMemory_type[181];
                boardMemory_type[192] <= boardMemory_type[182];
                boardMemory_type[193] <= boardMemory_type[183];
                boardMemory_type[194] <= boardMemory_type[184];
                boardMemory_type[195] <= boardMemory_type[185];
                boardMemory_type[196] <= boardMemory_type[186];
                boardMemory_type[197] <= boardMemory_type[187];
                boardMemory_type[198] <= boardMemory_type[188];
                boardMemory_type[199] <= boardMemory_type[189];
                boardMemory <= {10'b0000000000, boardMemory[0:189]};
            end
            else if(fullLines[18]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory_type[100] <= boardMemory_type[90];
                boardMemory_type[101] <= boardMemory_type[91];
                boardMemory_type[102] <= boardMemory_type[92];
                boardMemory_type[103] <= boardMemory_type[93];
                boardMemory_type[104] <= boardMemory_type[94];
                boardMemory_type[105] <= boardMemory_type[95];
                boardMemory_type[106] <= boardMemory_type[96];
                boardMemory_type[107] <= boardMemory_type[97];
                boardMemory_type[108] <= boardMemory_type[98];
                boardMemory_type[109] <= boardMemory_type[99];
                boardMemory_type[110] <= boardMemory_type[100];
                boardMemory_type[111] <= boardMemory_type[101];
                boardMemory_type[112] <= boardMemory_type[102];
                boardMemory_type[113] <= boardMemory_type[103];
                boardMemory_type[114] <= boardMemory_type[104];
                boardMemory_type[115] <= boardMemory_type[105];
                boardMemory_type[116] <= boardMemory_type[106];
                boardMemory_type[117] <= boardMemory_type[107];
                boardMemory_type[118] <= boardMemory_type[108];
                boardMemory_type[119] <= boardMemory_type[109];
                boardMemory_type[120] <= boardMemory_type[110];
                boardMemory_type[121] <= boardMemory_type[111];
                boardMemory_type[122] <= boardMemory_type[112];
                boardMemory_type[123] <= boardMemory_type[113];
                boardMemory_type[124] <= boardMemory_type[114];
                boardMemory_type[125] <= boardMemory_type[115];
                boardMemory_type[126] <= boardMemory_type[116];
                boardMemory_type[127] <= boardMemory_type[117];
                boardMemory_type[128] <= boardMemory_type[118];
                boardMemory_type[129] <= boardMemory_type[119];
                boardMemory_type[130] <= boardMemory_type[120];
                boardMemory_type[131] <= boardMemory_type[121];
                boardMemory_type[132] <= boardMemory_type[122];
                boardMemory_type[133] <= boardMemory_type[123];
                boardMemory_type[134] <= boardMemory_type[124];
                boardMemory_type[135] <= boardMemory_type[125];
                boardMemory_type[136] <= boardMemory_type[126];
                boardMemory_type[137] <= boardMemory_type[127];
                boardMemory_type[138] <= boardMemory_type[128];
                boardMemory_type[139] <= boardMemory_type[129];
                boardMemory_type[140] <= boardMemory_type[130];
                boardMemory_type[141] <= boardMemory_type[131];
                boardMemory_type[142] <= boardMemory_type[132];
                boardMemory_type[143] <= boardMemory_type[133];
                boardMemory_type[144] <= boardMemory_type[134];
                boardMemory_type[145] <= boardMemory_type[135];
                boardMemory_type[146] <= boardMemory_type[136];
                boardMemory_type[147] <= boardMemory_type[137];
                boardMemory_type[148] <= boardMemory_type[138];
                boardMemory_type[149] <= boardMemory_type[139];
                boardMemory_type[150] <= boardMemory_type[140];
                boardMemory_type[151] <= boardMemory_type[141];
                boardMemory_type[152] <= boardMemory_type[142];
                boardMemory_type[153] <= boardMemory_type[143];
                boardMemory_type[154] <= boardMemory_type[144];
                boardMemory_type[155] <= boardMemory_type[145];
                boardMemory_type[156] <= boardMemory_type[146];
                boardMemory_type[157] <= boardMemory_type[147];
                boardMemory_type[158] <= boardMemory_type[148];
                boardMemory_type[159] <= boardMemory_type[149];
                boardMemory_type[160] <= boardMemory_type[150];
                boardMemory_type[161] <= boardMemory_type[151];
                boardMemory_type[162] <= boardMemory_type[152];
                boardMemory_type[163] <= boardMemory_type[153];
                boardMemory_type[164] <= boardMemory_type[154];
                boardMemory_type[165] <= boardMemory_type[155];
                boardMemory_type[166] <= boardMemory_type[156];
                boardMemory_type[167] <= boardMemory_type[157];
                boardMemory_type[168] <= boardMemory_type[158];
                boardMemory_type[169] <= boardMemory_type[159];
                boardMemory_type[170] <= boardMemory_type[160];
                boardMemory_type[171] <= boardMemory_type[161];
                boardMemory_type[172] <= boardMemory_type[162];
                boardMemory_type[173] <= boardMemory_type[163];
                boardMemory_type[174] <= boardMemory_type[164];
                boardMemory_type[175] <= boardMemory_type[165];
                boardMemory_type[176] <= boardMemory_type[166];
                boardMemory_type[177] <= boardMemory_type[167];
                boardMemory_type[178] <= boardMemory_type[168];
                boardMemory_type[179] <= boardMemory_type[169];
                boardMemory_type[180] <= boardMemory_type[170];
                boardMemory_type[181] <= boardMemory_type[171];
                boardMemory_type[182] <= boardMemory_type[172];
                boardMemory_type[183] <= boardMemory_type[173];
                boardMemory_type[184] <= boardMemory_type[174];
                boardMemory_type[185] <= boardMemory_type[175];
                boardMemory_type[186] <= boardMemory_type[176];
                boardMemory_type[187] <= boardMemory_type[177];
                boardMemory_type[188] <= boardMemory_type[178];
                boardMemory_type[189] <= boardMemory_type[179];
                boardMemory <= {10'b0000000000, boardMemory[0:179], boardMemory[190:199]};
            end
            else if(fullLines[17]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory_type[100] <= boardMemory_type[90];
                boardMemory_type[101] <= boardMemory_type[91];
                boardMemory_type[102] <= boardMemory_type[92];
                boardMemory_type[103] <= boardMemory_type[93];
                boardMemory_type[104] <= boardMemory_type[94];
                boardMemory_type[105] <= boardMemory_type[95];
                boardMemory_type[106] <= boardMemory_type[96];
                boardMemory_type[107] <= boardMemory_type[97];
                boardMemory_type[108] <= boardMemory_type[98];
                boardMemory_type[109] <= boardMemory_type[99];
                boardMemory_type[110] <= boardMemory_type[100];
                boardMemory_type[111] <= boardMemory_type[101];
                boardMemory_type[112] <= boardMemory_type[102];
                boardMemory_type[113] <= boardMemory_type[103];
                boardMemory_type[114] <= boardMemory_type[104];
                boardMemory_type[115] <= boardMemory_type[105];
                boardMemory_type[116] <= boardMemory_type[106];
                boardMemory_type[117] <= boardMemory_type[107];
                boardMemory_type[118] <= boardMemory_type[108];
                boardMemory_type[119] <= boardMemory_type[109];
                boardMemory_type[120] <= boardMemory_type[110];
                boardMemory_type[121] <= boardMemory_type[111];
                boardMemory_type[122] <= boardMemory_type[112];
                boardMemory_type[123] <= boardMemory_type[113];
                boardMemory_type[124] <= boardMemory_type[114];
                boardMemory_type[125] <= boardMemory_type[115];
                boardMemory_type[126] <= boardMemory_type[116];
                boardMemory_type[127] <= boardMemory_type[117];
                boardMemory_type[128] <= boardMemory_type[118];
                boardMemory_type[129] <= boardMemory_type[119];
                boardMemory_type[130] <= boardMemory_type[120];
                boardMemory_type[131] <= boardMemory_type[121];
                boardMemory_type[132] <= boardMemory_type[122];
                boardMemory_type[133] <= boardMemory_type[123];
                boardMemory_type[134] <= boardMemory_type[124];
                boardMemory_type[135] <= boardMemory_type[125];
                boardMemory_type[136] <= boardMemory_type[126];
                boardMemory_type[137] <= boardMemory_type[127];
                boardMemory_type[138] <= boardMemory_type[128];
                boardMemory_type[139] <= boardMemory_type[129];
                boardMemory_type[140] <= boardMemory_type[130];
                boardMemory_type[141] <= boardMemory_type[131];
                boardMemory_type[142] <= boardMemory_type[132];
                boardMemory_type[143] <= boardMemory_type[133];
                boardMemory_type[144] <= boardMemory_type[134];
                boardMemory_type[145] <= boardMemory_type[135];
                boardMemory_type[146] <= boardMemory_type[136];
                boardMemory_type[147] <= boardMemory_type[137];
                boardMemory_type[148] <= boardMemory_type[138];
                boardMemory_type[149] <= boardMemory_type[139];
                boardMemory_type[150] <= boardMemory_type[140];
                boardMemory_type[151] <= boardMemory_type[141];
                boardMemory_type[152] <= boardMemory_type[142];
                boardMemory_type[153] <= boardMemory_type[143];
                boardMemory_type[154] <= boardMemory_type[144];
                boardMemory_type[155] <= boardMemory_type[145];
                boardMemory_type[156] <= boardMemory_type[146];
                boardMemory_type[157] <= boardMemory_type[147];
                boardMemory_type[158] <= boardMemory_type[148];
                boardMemory_type[159] <= boardMemory_type[149];
                boardMemory_type[160] <= boardMemory_type[150];
                boardMemory_type[161] <= boardMemory_type[151];
                boardMemory_type[162] <= boardMemory_type[152];
                boardMemory_type[163] <= boardMemory_type[153];
                boardMemory_type[164] <= boardMemory_type[154];
                boardMemory_type[165] <= boardMemory_type[155];
                boardMemory_type[166] <= boardMemory_type[156];
                boardMemory_type[167] <= boardMemory_type[157];
                boardMemory_type[168] <= boardMemory_type[158];
                boardMemory_type[169] <= boardMemory_type[159];
                boardMemory_type[170] <= boardMemory_type[160];
                boardMemory_type[171] <= boardMemory_type[161];
                boardMemory_type[172] <= boardMemory_type[162];
                boardMemory_type[173] <= boardMemory_type[163];
                boardMemory_type[174] <= boardMemory_type[164];
                boardMemory_type[175] <= boardMemory_type[165];
                boardMemory_type[176] <= boardMemory_type[166];
                boardMemory_type[177] <= boardMemory_type[167];
                boardMemory_type[178] <= boardMemory_type[168];
                boardMemory_type[179] <= boardMemory_type[169];
                boardMemory <= {10'b0000000000, boardMemory[0:169], boardMemory[180:199]};
            end
            else if(fullLines[16]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory_type[100] <= boardMemory_type[90];
                boardMemory_type[101] <= boardMemory_type[91];
                boardMemory_type[102] <= boardMemory_type[92];
                boardMemory_type[103] <= boardMemory_type[93];
                boardMemory_type[104] <= boardMemory_type[94];
                boardMemory_type[105] <= boardMemory_type[95];
                boardMemory_type[106] <= boardMemory_type[96];
                boardMemory_type[107] <= boardMemory_type[97];
                boardMemory_type[108] <= boardMemory_type[98];
                boardMemory_type[109] <= boardMemory_type[99];
                boardMemory_type[110] <= boardMemory_type[100];
                boardMemory_type[111] <= boardMemory_type[101];
                boardMemory_type[112] <= boardMemory_type[102];
                boardMemory_type[113] <= boardMemory_type[103];
                boardMemory_type[114] <= boardMemory_type[104];
                boardMemory_type[115] <= boardMemory_type[105];
                boardMemory_type[116] <= boardMemory_type[106];
                boardMemory_type[117] <= boardMemory_type[107];
                boardMemory_type[118] <= boardMemory_type[108];
                boardMemory_type[119] <= boardMemory_type[109];
                boardMemory_type[120] <= boardMemory_type[110];
                boardMemory_type[121] <= boardMemory_type[111];
                boardMemory_type[122] <= boardMemory_type[112];
                boardMemory_type[123] <= boardMemory_type[113];
                boardMemory_type[124] <= boardMemory_type[114];
                boardMemory_type[125] <= boardMemory_type[115];
                boardMemory_type[126] <= boardMemory_type[116];
                boardMemory_type[127] <= boardMemory_type[117];
                boardMemory_type[128] <= boardMemory_type[118];
                boardMemory_type[129] <= boardMemory_type[119];
                boardMemory_type[130] <= boardMemory_type[120];
                boardMemory_type[131] <= boardMemory_type[121];
                boardMemory_type[132] <= boardMemory_type[122];
                boardMemory_type[133] <= boardMemory_type[123];
                boardMemory_type[134] <= boardMemory_type[124];
                boardMemory_type[135] <= boardMemory_type[125];
                boardMemory_type[136] <= boardMemory_type[126];
                boardMemory_type[137] <= boardMemory_type[127];
                boardMemory_type[138] <= boardMemory_type[128];
                boardMemory_type[139] <= boardMemory_type[129];
                boardMemory_type[140] <= boardMemory_type[130];
                boardMemory_type[141] <= boardMemory_type[131];
                boardMemory_type[142] <= boardMemory_type[132];
                boardMemory_type[143] <= boardMemory_type[133];
                boardMemory_type[144] <= boardMemory_type[134];
                boardMemory_type[145] <= boardMemory_type[135];
                boardMemory_type[146] <= boardMemory_type[136];
                boardMemory_type[147] <= boardMemory_type[137];
                boardMemory_type[148] <= boardMemory_type[138];
                boardMemory_type[149] <= boardMemory_type[139];
                boardMemory_type[150] <= boardMemory_type[140];
                boardMemory_type[151] <= boardMemory_type[141];
                boardMemory_type[152] <= boardMemory_type[142];
                boardMemory_type[153] <= boardMemory_type[143];
                boardMemory_type[154] <= boardMemory_type[144];
                boardMemory_type[155] <= boardMemory_type[145];
                boardMemory_type[156] <= boardMemory_type[146];
                boardMemory_type[157] <= boardMemory_type[147];
                boardMemory_type[158] <= boardMemory_type[148];
                boardMemory_type[159] <= boardMemory_type[149];
                boardMemory_type[160] <= boardMemory_type[150];
                boardMemory_type[161] <= boardMemory_type[151];
                boardMemory_type[162] <= boardMemory_type[152];
                boardMemory_type[163] <= boardMemory_type[153];
                boardMemory_type[164] <= boardMemory_type[154];
                boardMemory_type[165] <= boardMemory_type[155];
                boardMemory_type[166] <= boardMemory_type[156];
                boardMemory_type[167] <= boardMemory_type[157];
                boardMemory_type[168] <= boardMemory_type[158];
                boardMemory_type[169] <= boardMemory_type[159];
                boardMemory <= {10'b0000000000, boardMemory[0:159], boardMemory[170:199]};
            end
            else if(fullLines[15]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory_type[100] <= boardMemory_type[90];
                boardMemory_type[101] <= boardMemory_type[91];
                boardMemory_type[102] <= boardMemory_type[92];
                boardMemory_type[103] <= boardMemory_type[93];
                boardMemory_type[104] <= boardMemory_type[94];
                boardMemory_type[105] <= boardMemory_type[95];
                boardMemory_type[106] <= boardMemory_type[96];
                boardMemory_type[107] <= boardMemory_type[97];
                boardMemory_type[108] <= boardMemory_type[98];
                boardMemory_type[109] <= boardMemory_type[99];
                boardMemory_type[110] <= boardMemory_type[100];
                boardMemory_type[111] <= boardMemory_type[101];
                boardMemory_type[112] <= boardMemory_type[102];
                boardMemory_type[113] <= boardMemory_type[103];
                boardMemory_type[114] <= boardMemory_type[104];
                boardMemory_type[115] <= boardMemory_type[105];
                boardMemory_type[116] <= boardMemory_type[106];
                boardMemory_type[117] <= boardMemory_type[107];
                boardMemory_type[118] <= boardMemory_type[108];
                boardMemory_type[119] <= boardMemory_type[109];
                boardMemory_type[120] <= boardMemory_type[110];
                boardMemory_type[121] <= boardMemory_type[111];
                boardMemory_type[122] <= boardMemory_type[112];
                boardMemory_type[123] <= boardMemory_type[113];
                boardMemory_type[124] <= boardMemory_type[114];
                boardMemory_type[125] <= boardMemory_type[115];
                boardMemory_type[126] <= boardMemory_type[116];
                boardMemory_type[127] <= boardMemory_type[117];
                boardMemory_type[128] <= boardMemory_type[118];
                boardMemory_type[129] <= boardMemory_type[119];
                boardMemory_type[130] <= boardMemory_type[120];
                boardMemory_type[131] <= boardMemory_type[121];
                boardMemory_type[132] <= boardMemory_type[122];
                boardMemory_type[133] <= boardMemory_type[123];
                boardMemory_type[134] <= boardMemory_type[124];
                boardMemory_type[135] <= boardMemory_type[125];
                boardMemory_type[136] <= boardMemory_type[126];
                boardMemory_type[137] <= boardMemory_type[127];
                boardMemory_type[138] <= boardMemory_type[128];
                boardMemory_type[139] <= boardMemory_type[129];
                boardMemory_type[140] <= boardMemory_type[130];
                boardMemory_type[141] <= boardMemory_type[131];
                boardMemory_type[142] <= boardMemory_type[132];
                boardMemory_type[143] <= boardMemory_type[133];
                boardMemory_type[144] <= boardMemory_type[134];
                boardMemory_type[145] <= boardMemory_type[135];
                boardMemory_type[146] <= boardMemory_type[136];
                boardMemory_type[147] <= boardMemory_type[137];
                boardMemory_type[148] <= boardMemory_type[138];
                boardMemory_type[149] <= boardMemory_type[139];
                boardMemory_type[150] <= boardMemory_type[140];
                boardMemory_type[151] <= boardMemory_type[141];
                boardMemory_type[152] <= boardMemory_type[142];
                boardMemory_type[153] <= boardMemory_type[143];
                boardMemory_type[154] <= boardMemory_type[144];
                boardMemory_type[155] <= boardMemory_type[145];
                boardMemory_type[156] <= boardMemory_type[146];
                boardMemory_type[157] <= boardMemory_type[147];
                boardMemory_type[158] <= boardMemory_type[148];
                boardMemory_type[159] <= boardMemory_type[149];
                boardMemory <= {10'b0000000000, boardMemory[0:149], boardMemory[160:199]};
            end
            else if(fullLines[14]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory_type[100] <= boardMemory_type[90];
                boardMemory_type[101] <= boardMemory_type[91];
                boardMemory_type[102] <= boardMemory_type[92];
                boardMemory_type[103] <= boardMemory_type[93];
                boardMemory_type[104] <= boardMemory_type[94];
                boardMemory_type[105] <= boardMemory_type[95];
                boardMemory_type[106] <= boardMemory_type[96];
                boardMemory_type[107] <= boardMemory_type[97];
                boardMemory_type[108] <= boardMemory_type[98];
                boardMemory_type[109] <= boardMemory_type[99];
                boardMemory_type[110] <= boardMemory_type[100];
                boardMemory_type[111] <= boardMemory_type[101];
                boardMemory_type[112] <= boardMemory_type[102];
                boardMemory_type[113] <= boardMemory_type[103];
                boardMemory_type[114] <= boardMemory_type[104];
                boardMemory_type[115] <= boardMemory_type[105];
                boardMemory_type[116] <= boardMemory_type[106];
                boardMemory_type[117] <= boardMemory_type[107];
                boardMemory_type[118] <= boardMemory_type[108];
                boardMemory_type[119] <= boardMemory_type[109];
                boardMemory_type[120] <= boardMemory_type[110];
                boardMemory_type[121] <= boardMemory_type[111];
                boardMemory_type[122] <= boardMemory_type[112];
                boardMemory_type[123] <= boardMemory_type[113];
                boardMemory_type[124] <= boardMemory_type[114];
                boardMemory_type[125] <= boardMemory_type[115];
                boardMemory_type[126] <= boardMemory_type[116];
                boardMemory_type[127] <= boardMemory_type[117];
                boardMemory_type[128] <= boardMemory_type[118];
                boardMemory_type[129] <= boardMemory_type[119];
                boardMemory_type[130] <= boardMemory_type[120];
                boardMemory_type[131] <= boardMemory_type[121];
                boardMemory_type[132] <= boardMemory_type[122];
                boardMemory_type[133] <= boardMemory_type[123];
                boardMemory_type[134] <= boardMemory_type[124];
                boardMemory_type[135] <= boardMemory_type[125];
                boardMemory_type[136] <= boardMemory_type[126];
                boardMemory_type[137] <= boardMemory_type[127];
                boardMemory_type[138] <= boardMemory_type[128];
                boardMemory_type[139] <= boardMemory_type[129];
                boardMemory_type[140] <= boardMemory_type[130];
                boardMemory_type[141] <= boardMemory_type[131];
                boardMemory_type[142] <= boardMemory_type[132];
                boardMemory_type[143] <= boardMemory_type[133];
                boardMemory_type[144] <= boardMemory_type[134];
                boardMemory_type[145] <= boardMemory_type[135];
                boardMemory_type[146] <= boardMemory_type[136];
                boardMemory_type[147] <= boardMemory_type[137];
                boardMemory_type[148] <= boardMemory_type[138];
                boardMemory_type[149] <= boardMemory_type[139];
                boardMemory <= {10'b0000000000, boardMemory[0:139], boardMemory[150:199]};
            end
            else if(fullLines[13]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory_type[100] <= boardMemory_type[90];
                boardMemory_type[101] <= boardMemory_type[91];
                boardMemory_type[102] <= boardMemory_type[92];
                boardMemory_type[103] <= boardMemory_type[93];
                boardMemory_type[104] <= boardMemory_type[94];
                boardMemory_type[105] <= boardMemory_type[95];
                boardMemory_type[106] <= boardMemory_type[96];
                boardMemory_type[107] <= boardMemory_type[97];
                boardMemory_type[108] <= boardMemory_type[98];
                boardMemory_type[109] <= boardMemory_type[99];
                boardMemory_type[110] <= boardMemory_type[100];
                boardMemory_type[111] <= boardMemory_type[101];
                boardMemory_type[112] <= boardMemory_type[102];
                boardMemory_type[113] <= boardMemory_type[103];
                boardMemory_type[114] <= boardMemory_type[104];
                boardMemory_type[115] <= boardMemory_type[105];
                boardMemory_type[116] <= boardMemory_type[106];
                boardMemory_type[117] <= boardMemory_type[107];
                boardMemory_type[118] <= boardMemory_type[108];
                boardMemory_type[119] <= boardMemory_type[109];
                boardMemory_type[120] <= boardMemory_type[110];
                boardMemory_type[121] <= boardMemory_type[111];
                boardMemory_type[122] <= boardMemory_type[112];
                boardMemory_type[123] <= boardMemory_type[113];
                boardMemory_type[124] <= boardMemory_type[114];
                boardMemory_type[125] <= boardMemory_type[115];
                boardMemory_type[126] <= boardMemory_type[116];
                boardMemory_type[127] <= boardMemory_type[117];
                boardMemory_type[128] <= boardMemory_type[118];
                boardMemory_type[129] <= boardMemory_type[119];
                boardMemory_type[130] <= boardMemory_type[120];
                boardMemory_type[131] <= boardMemory_type[121];
                boardMemory_type[132] <= boardMemory_type[122];
                boardMemory_type[133] <= boardMemory_type[123];
                boardMemory_type[134] <= boardMemory_type[124];
                boardMemory_type[135] <= boardMemory_type[125];
                boardMemory_type[136] <= boardMemory_type[126];
                boardMemory_type[137] <= boardMemory_type[127];
                boardMemory_type[138] <= boardMemory_type[128];
                boardMemory_type[139] <= boardMemory_type[129];
                boardMemory <= {10'b0000000000, boardMemory[0:129], boardMemory[140:199]};
            end
            else if(fullLines[12]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory_type[100] <= boardMemory_type[90];
                boardMemory_type[101] <= boardMemory_type[91];
                boardMemory_type[102] <= boardMemory_type[92];
                boardMemory_type[103] <= boardMemory_type[93];
                boardMemory_type[104] <= boardMemory_type[94];
                boardMemory_type[105] <= boardMemory_type[95];
                boardMemory_type[106] <= boardMemory_type[96];
                boardMemory_type[107] <= boardMemory_type[97];
                boardMemory_type[108] <= boardMemory_type[98];
                boardMemory_type[109] <= boardMemory_type[99];
                boardMemory_type[110] <= boardMemory_type[100];
                boardMemory_type[111] <= boardMemory_type[101];
                boardMemory_type[112] <= boardMemory_type[102];
                boardMemory_type[113] <= boardMemory_type[103];
                boardMemory_type[114] <= boardMemory_type[104];
                boardMemory_type[115] <= boardMemory_type[105];
                boardMemory_type[116] <= boardMemory_type[106];
                boardMemory_type[117] <= boardMemory_type[107];
                boardMemory_type[118] <= boardMemory_type[108];
                boardMemory_type[119] <= boardMemory_type[109];
                boardMemory_type[120] <= boardMemory_type[110];
                boardMemory_type[121] <= boardMemory_type[111];
                boardMemory_type[122] <= boardMemory_type[112];
                boardMemory_type[123] <= boardMemory_type[113];
                boardMemory_type[124] <= boardMemory_type[114];
                boardMemory_type[125] <= boardMemory_type[115];
                boardMemory_type[126] <= boardMemory_type[116];
                boardMemory_type[127] <= boardMemory_type[117];
                boardMemory_type[128] <= boardMemory_type[118];
                boardMemory_type[129] <= boardMemory_type[119];
                boardMemory <= {10'b0000000000, boardMemory[0:119], boardMemory[130:199]};
            end
            else if(fullLines[11]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory_type[100] <= boardMemory_type[90];
                boardMemory_type[101] <= boardMemory_type[91];
                boardMemory_type[102] <= boardMemory_type[92];
                boardMemory_type[103] <= boardMemory_type[93];
                boardMemory_type[104] <= boardMemory_type[94];
                boardMemory_type[105] <= boardMemory_type[95];
                boardMemory_type[106] <= boardMemory_type[96];
                boardMemory_type[107] <= boardMemory_type[97];
                boardMemory_type[108] <= boardMemory_type[98];
                boardMemory_type[109] <= boardMemory_type[99];
                boardMemory_type[110] <= boardMemory_type[100];
                boardMemory_type[111] <= boardMemory_type[101];
                boardMemory_type[112] <= boardMemory_type[102];
                boardMemory_type[113] <= boardMemory_type[103];
                boardMemory_type[114] <= boardMemory_type[104];
                boardMemory_type[115] <= boardMemory_type[105];
                boardMemory_type[116] <= boardMemory_type[106];
                boardMemory_type[117] <= boardMemory_type[107];
                boardMemory_type[118] <= boardMemory_type[108];
                boardMemory_type[119] <= boardMemory_type[109];
                boardMemory <= {10'b0000000000, boardMemory[0:109], boardMemory[120:199]};
            end
            else if(fullLines[10]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory_type[100] <= boardMemory_type[90];
                boardMemory_type[101] <= boardMemory_type[91];
                boardMemory_type[102] <= boardMemory_type[92];
                boardMemory_type[103] <= boardMemory_type[93];
                boardMemory_type[104] <= boardMemory_type[94];
                boardMemory_type[105] <= boardMemory_type[95];
                boardMemory_type[106] <= boardMemory_type[96];
                boardMemory_type[107] <= boardMemory_type[97];
                boardMemory_type[108] <= boardMemory_type[98];
                boardMemory_type[109] <= boardMemory_type[99];
                boardMemory <= {10'b0000000000, boardMemory[0:99], boardMemory[110:199]};
            end
            else if(fullLines[9]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory_type[90] <= boardMemory_type[80];
                boardMemory_type[91] <= boardMemory_type[81];
                boardMemory_type[92] <= boardMemory_type[82];
                boardMemory_type[93] <= boardMemory_type[83];
                boardMemory_type[94] <= boardMemory_type[84];
                boardMemory_type[95] <= boardMemory_type[85];
                boardMemory_type[96] <= boardMemory_type[86];
                boardMemory_type[97] <= boardMemory_type[87];
                boardMemory_type[98] <= boardMemory_type[88];
                boardMemory_type[99] <= boardMemory_type[89];
                boardMemory <= {10'b0000000000, boardMemory[0:89], boardMemory[100:199]};
            end
            else if(fullLines[8]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory_type[80] <= boardMemory_type[70];
                boardMemory_type[81] <= boardMemory_type[71];
                boardMemory_type[82] <= boardMemory_type[72];
                boardMemory_type[83] <= boardMemory_type[73];
                boardMemory_type[84] <= boardMemory_type[74];
                boardMemory_type[85] <= boardMemory_type[75];
                boardMemory_type[86] <= boardMemory_type[76];
                boardMemory_type[87] <= boardMemory_type[77];
                boardMemory_type[88] <= boardMemory_type[78];
                boardMemory_type[89] <= boardMemory_type[79];
                boardMemory <= {10'b0000000000, boardMemory[0:79], boardMemory[90:199]};
            end
            else if(fullLines[7]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory_type[70] <= boardMemory_type[60];
                boardMemory_type[71] <= boardMemory_type[61];
                boardMemory_type[72] <= boardMemory_type[62];
                boardMemory_type[73] <= boardMemory_type[63];
                boardMemory_type[74] <= boardMemory_type[64];
                boardMemory_type[75] <= boardMemory_type[65];
                boardMemory_type[76] <= boardMemory_type[66];
                boardMemory_type[77] <= boardMemory_type[67];
                boardMemory_type[78] <= boardMemory_type[68];
                boardMemory_type[79] <= boardMemory_type[69];
                boardMemory <= {10'b0000000000, boardMemory[0:69], boardMemory[80:199]};
            end
            else if(fullLines[6]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory_type[60] <= boardMemory_type[50];
                boardMemory_type[61] <= boardMemory_type[51];
                boardMemory_type[62] <= boardMemory_type[52];
                boardMemory_type[63] <= boardMemory_type[53];
                boardMemory_type[64] <= boardMemory_type[54];
                boardMemory_type[65] <= boardMemory_type[55];
                boardMemory_type[66] <= boardMemory_type[56];
                boardMemory_type[67] <= boardMemory_type[57];
                boardMemory_type[68] <= boardMemory_type[58];
                boardMemory_type[69] <= boardMemory_type[59];
                boardMemory <= {10'b0000000000, boardMemory[0:59], boardMemory[70:199]};
            end
            else if(fullLines[5]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory_type[50] <= boardMemory_type[40];
                boardMemory_type[51] <= boardMemory_type[41];
                boardMemory_type[52] <= boardMemory_type[42];
                boardMemory_type[53] <= boardMemory_type[43];
                boardMemory_type[54] <= boardMemory_type[44];
                boardMemory_type[55] <= boardMemory_type[45];
                boardMemory_type[56] <= boardMemory_type[46];
                boardMemory_type[57] <= boardMemory_type[47];
                boardMemory_type[58] <= boardMemory_type[48];
                boardMemory_type[59] <= boardMemory_type[49];
                boardMemory <= {10'b0000000000, boardMemory[0:49], boardMemory[60:199]};
            end
            else if(fullLines[4]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory_type[40] <= boardMemory_type[30];
                boardMemory_type[41] <= boardMemory_type[31];
                boardMemory_type[42] <= boardMemory_type[32];
                boardMemory_type[43] <= boardMemory_type[33];
                boardMemory_type[44] <= boardMemory_type[34];
                boardMemory_type[45] <= boardMemory_type[35];
                boardMemory_type[46] <= boardMemory_type[36];
                boardMemory_type[47] <= boardMemory_type[37];
                boardMemory_type[48] <= boardMemory_type[38];
                boardMemory_type[49] <= boardMemory_type[39];
                boardMemory <= {10'b0000000000, boardMemory[0:39], boardMemory[50:199]};
            end
            else if(fullLines[3]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory_type[30] <= boardMemory_type[20];
                boardMemory_type[31] <= boardMemory_type[21];
                boardMemory_type[32] <= boardMemory_type[22];
                boardMemory_type[33] <= boardMemory_type[23];
                boardMemory_type[34] <= boardMemory_type[24];
                boardMemory_type[35] <= boardMemory_type[25];
                boardMemory_type[36] <= boardMemory_type[26];
                boardMemory_type[37] <= boardMemory_type[27];
                boardMemory_type[38] <= boardMemory_type[28];
                boardMemory_type[39] <= boardMemory_type[29];
                boardMemory <= {10'b0000000000, boardMemory[0:29], boardMemory[40:199]};
            end
            else if(fullLines[2]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory_type[20] <= boardMemory_type[10];
                boardMemory_type[21] <= boardMemory_type[11];
                boardMemory_type[22] <= boardMemory_type[12];
                boardMemory_type[23] <= boardMemory_type[13];
                boardMemory_type[24] <= boardMemory_type[14];
                boardMemory_type[25] <= boardMemory_type[15];
                boardMemory_type[26] <= boardMemory_type[16];
                boardMemory_type[27] <= boardMemory_type[17];
                boardMemory_type[28] <= boardMemory_type[18];
                boardMemory_type[29] <= boardMemory_type[19];
                boardMemory <= {10'b0000000000, boardMemory[0:19], boardMemory[30:199]};
            end
            else if(fullLines[1]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory_type[10] <= boardMemory_type[0];
                boardMemory_type[11] <= boardMemory_type[1];
                boardMemory_type[12] <= boardMemory_type[2];
                boardMemory_type[13] <= boardMemory_type[3];
                boardMemory_type[14] <= boardMemory_type[4];
                boardMemory_type[15] <= boardMemory_type[5];
                boardMemory_type[16] <= boardMemory_type[6];
                boardMemory_type[17] <= boardMemory_type[7];
                boardMemory_type[18] <= boardMemory_type[8];
                boardMemory_type[19] <= boardMemory_type[9];
                boardMemory <= {10'b0000000000, boardMemory[0:9], boardMemory[20:199]};
            end
            else if(fullLines[0]) begin
                boardMemory_type[0] <= 4'd0;
                boardMemory_type[1] <= 4'd0;
                boardMemory_type[2] <= 4'd0;
                boardMemory_type[3] <= 4'd0;
                boardMemory_type[4] <= 4'd0;
                boardMemory_type[5] <= 4'd0;
                boardMemory_type[6] <= 4'd0;
                boardMemory_type[7] <= 4'd0;
                boardMemory_type[8] <= 4'd0;
                boardMemory_type[9] <= 4'd0;
                boardMemory <= {10'b0000000000, boardMemory[10:199]};
            end
        end
        else begin
            if(d1 != a1 && d1 != a2 && d1 != a3 && d1 != a4 && d1 != 201) begin
                boardMemory[d1] <= 0;
                boardMemory_type[d1] <= `NONE;
            end
            if(d2 != a1 && d2 != a2 && d2 != a3 && d2 != a4 && d2 != 201) begin
                boardMemory[d2] <= 0;
                boardMemory_type[d2] <= `NONE;
            end
            if(d3 != a1 && d3 != a2 && d3 != a3 && d3 != a4 && d3 != 201) begin
                boardMemory[d3] <= 0;
                boardMemory_type[d3] <= `NONE;
            end
            if(d4 != a1 && d4 != a2 && d4 != a3 && d4 != a4 && d4 != 201) begin
                boardMemory[d4] <= 0;
                boardMemory_type[d4] <= `NONE;
            end
            if(a1 != 201) begin
                boardMemory[a1] <= 1;
                boardMemory_type[a1] <= current_block;
            end
            if(a2 != 201) begin
                boardMemory[a2] <= 1;
                boardMemory_type[a2] <= current_block;
            end
            if(a3 != 201) begin
                boardMemory[a3] <= 1;
                boardMemory_type[a3] <= current_block;
            end
            if(a4 != 201) begin
                boardMemory[a4] <= 1;
                boardMemory_type[a4] <= current_block;
            end
        end
    end
end

// level
always@(*) begin
    if(gamestart) begin
        if(score >= 0 && score < 10) begin
            speed = clk_1s;
            level = 1;
        end
        else if(score >= 10 && score < 20) begin
            speed = clk_0_8s;
            level = 2;
        end
        else if(score >= 20 && score < 30) begin
            speed = clk_0_6s;
            level = 3;
        end
        else if(score >= 30 && score < 40) begin
            speed = clk_0_4s;
            level = 4;
        end
        else if(score >= 40 && score < 50) begin
            speed = clk_0_2s;
            level = 5;
        end
        else if(score >= 50 && score < 60) begin
            speed = clk_0_1s;
            level = 6;
        end
        else if(score >= 60 && score < 80) begin
            speed = clk_0_0_5s;
            level = 7;
        end
        else begin
            speed = clk_0_0_2_5s;
            level = 8;
        end
    end
end
// shine effect
reg [11:0] shine, shine_next;
always@(posedge shineclk) begin
    if(shine == 12'h111)
        shine_next <= 12'h0;
    else
        shine_next <= 12'h111;
end
always@(*) begin
    if(fullLine || shine == 12'h111 || gamestart == 0) begin
        shine = shine_next;
    end
end
// game start control
always@(posedge clk) begin
    if(been_ready && key_down[last_change] && last_change == `KEY_CODES_ENTER && gamestart == 0) begin
        gamestart <= 1;
    end
end
// calculate next value
always @ (posedge clk) begin
    if(gamestart) begin
        if(start) begin
            start_1s_cnt <= 0;
            start <= 0;
            first <= 0;
            score <= 32'd0;
            next_ctrlX[0] <= 5;
            next_ctrlX[1] <= 3;
            next_ctrlX[2] <= 4;
            next_ctrlX[3] <= 5;
            next_ctrlY[0] <= 0;
            next_ctrlY[1] <= 1;
            next_ctrlY[2] <= 1;
            next_ctrlY[3] <= 1;
            c_hold <= 0;
            hold <= 0;
            hold_block <= `NONE;
            next_block <= `L_BLOCK;
            next_angle <= `ANGLE0;
            drop <= 0;
            harddrop <= 0;
            d1 <= 201;
            d2 <= 201;
            d3 <= 201;
            d4 <= 201;
            a1 <= 201;
            a2 <= 201;
            a3 <= 201;
            a4 <= 201;
        end
        else if(speed) begin
            if(validDown) begin
                // next position and original position overlap condition
                if((ctrlY[0]*`WIDTH+ctrlX[0] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                        (ctrlY[0]*`WIDTH+ctrlX[0] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                        (ctrlY[0]*`WIDTH+ctrlX[0] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                    // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                    d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                end
                else begin
                    d1 <= 201;
                end
                if((ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[0]+1)*`WIDTH+ctrlX[0]) &&
                        (ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                        (ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                    // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                    d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                end
                else begin
                    d2 <= 201;
                end
                if((ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                        (ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[0]+1)*`WIDTH+ctrlX[0]) &&
                        (ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                    // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                    d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                end
                else begin
                    d3 <= 201;
                end
                if((ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                        (ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                        (ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[0]+1)*`WIDTH+ctrlX[0])) begin
                    // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                    d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                end
                else begin
                    d4 <= 201;
                end
                // add next position to boardMemory
                a1 <= (ctrlY[0]+1)*`WIDTH + ctrlX[0];
                a2 <= (ctrlY[1]+1)*`WIDTH + ctrlX[1];
                a3 <= (ctrlY[2]+1)*`WIDTH + ctrlX[2];
                a4 <= (ctrlY[3]+1)*`WIDTH + ctrlX[3];
                next_ctrlX[0] <= ctrlX[0];
                next_ctrlX[1] <= ctrlX[1];
                next_ctrlX[2] <= ctrlX[2];
                next_ctrlX[3] <= ctrlX[3];
                next_ctrlY[0] <= ctrlY[0] + 1;
                next_ctrlY[1] <= ctrlY[1] + 1;
                next_ctrlY[2] <= ctrlY[2] + 1;
                next_ctrlY[3] <= ctrlY[3] + 1;
            end
        end
        else if(drop) begin
            first <= 1;
            hold <= 0;
            if(c_hold == 0) begin
                d1 <= 201;
                d2 <= 201;
                d3 <= 201;
                d4 <= 201;
            end
            else
                c_hold <= 0;

            if(fullLine == 0) begin
                //create new block
                drop <= 0;
                if(first == 0) begin
                    next_ctrlX[0] <= 3;
                    next_ctrlX[1] <= 3;
                    next_ctrlX[2] <= 4;
                    next_ctrlX[3] <= 5;
                    next_ctrlY[0] <= 0;
                    next_ctrlY[1] <= 1;
                    next_ctrlY[2] <= 1;
                    next_ctrlY[3] <= 1;
                    a1 <= 3;
                    a2 <= 13;
                    a3 <= 14;
                    a4 <= 15;
                    next_block <= `J_BLOCK;
                end
                else begin
                    case(random_block)
                        `O_BLOCK: begin
                            next_ctrlX[0] <= 4;
                            next_ctrlX[1] <= 5;
                            next_ctrlX[2] <= 4;
                            next_ctrlX[3] <= 5;
                            next_ctrlY[0] <= 0;
                            next_ctrlY[1] <= 0;
                            next_ctrlY[2] <= 1;
                            next_ctrlY[3] <= 1;
                            a1 <= 4;
                            a2 <= 5;
                            a3 <= 14;
                            a4 <= 15;
                            // boardMemory[4] <= 1'b1;
                            // boardMemory[5] <= 1'b1;
                            // boardMemory[`WIDTH + 4] <= 1'b1;
                            // boardMemory[`WIDTH + 5] <= 1'b1;
                            next_block <= `O_BLOCK;
                        end
                        `L_BLOCK: begin
                            next_ctrlX[0] <= 5;
                            next_ctrlX[1] <= 3;
                            next_ctrlX[2] <= 4;
                            next_ctrlX[3] <= 5;
                            next_ctrlY[0] <= 0;
                            next_ctrlY[1] <= 1;
                            next_ctrlY[2] <= 1;
                            next_ctrlY[3] <= 1;
                            a1 <= 5;
                            a2 <= 13;
                            a3 <= 14;
                            a4 <= 15;
                            next_block <= `L_BLOCK;

                        end
                        `J_BLOCK: begin
                            next_ctrlX[0] <= 3;
                            next_ctrlX[1] <= 3;
                            next_ctrlX[2] <= 4;
                            next_ctrlX[3] <= 5;
                            next_ctrlY[0] <= 0;
                            next_ctrlY[1] <= 1;
                            next_ctrlY[2] <= 1;
                            next_ctrlY[3] <= 1;
                            a1 <= 3;
                            a2 <= 13;
                            a3 <= 14;
                            a4 <= 15;
                            // boardMemory[3] <= 1'b1;
                            // boardMemory[`WIDTH + 3] <= 1'b1;
                            // boardMemory[`WIDTH + 4] <= 1'b1;
                            // boardMemory[`WIDTH + 5] <= 1'b1;
                            next_block <= `J_BLOCK;

                        end
                        `S_BLOCK: begin
                            next_ctrlX[0] <= 4;
                            next_ctrlX[1] <= 5;
                            next_ctrlX[2] <= 3;
                            next_ctrlX[3] <= 4;
                            next_ctrlY[0] <= 0;
                            next_ctrlY[1] <= 0;
                            next_ctrlY[2] <= 1;
                            next_ctrlY[3] <= 1;
                            a1 <= 4;
                            a2 <= 5;
                            a3 <= 13;
                            a4 <= 14;
                            // boardMemory[4] <= 1'b1;
                            // boardMemory[`WIDTH + 5] <= 1'b1;
                            // boardMemory[`WIDTH + 3] <= 1'b1;
                            // boardMemory[`WIDTH + 4] <= 1'b1;
                            next_block <= `S_BLOCK;

                        end
                        `Z_BLOCK: begin
                            next_ctrlX[0] <= 3;
                            next_ctrlX[1] <= 4;
                            next_ctrlX[2] <= 4;
                            next_ctrlX[3] <= 5;
                            next_ctrlY[0] <= 0;
                            next_ctrlY[1] <= 0;
                            next_ctrlY[2] <= 1;
                            next_ctrlY[3] <= 1;
                            a1 <= 3;
                            a2 <= 4;
                            a3 <= 14;
                            a4 <= 15;
                            // boardMemory[3] <= 1'b1;
                            // boardMemory[4] <= 1'b1;
                            // boardMemory[`WIDTH + 4] <= 1'b1;
                            // boardMemory[`WIDTH + 5] <= 1'b1;
                            next_block <= `Z_BLOCK;

                        end
                        `I_BLOCK: begin
                            next_ctrlX[0] <= 3;
                            next_ctrlX[1] <= 4;
                            next_ctrlX[2] <= 5;
                            next_ctrlX[3] <= 6;
                            next_ctrlY[0] <= 1;
                            next_ctrlY[1] <= 1;
                            next_ctrlY[2] <= 1;
                            next_ctrlY[3] <= 1;
                            a1 <= 13;
                            a2 <= 14;
                            a3 <= 15;
                            a4 <= 16;
                            // boardMemory[3] <= 1'b1;
                            // boardMemory[4] <= 1'b1;
                            // boardMemory[5] <= 1'b1;
                            // boardMemory[6] <= 1'b1;
                            next_block <= `I_BLOCK;

                        end
                        `T_BLOCK: begin
                            next_ctrlX[0] <= 4;
                            next_ctrlX[1] <= 3;
                            next_ctrlX[2] <= 4;
                            next_ctrlX[3] <= 5;
                            next_ctrlY[0] <= 0;
                            next_ctrlY[1] <= 1;
                            next_ctrlY[2] <= 1;
                            next_ctrlY[3] <= 1;
                            a1 <= 4;
                            a2 <= 13;
                            a3 <= 14;
                            a4 <= 15;
                            // boardMemory[4] <= 1'b1;
                            // boardMemory[`WIDTH + 3] <= 1'b1;
                            // boardMemory[`WIDTH + 4] <= 1'b1;
                            // boardMemory[`WIDTH + 5] <= 1'b1;
                            next_block <= `T_BLOCK;

                        end
                    endcase
                end
                next_angle <= `ANGLE0;
            end
            else begin
                score <= score + 1'b1;
            end
        end
        else if (been_ready && key_down[last_change] == 1'b1) begin

            case (last_change)
                `KEY_CODES_C: begin
                    if(hold == 0) begin
                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                        hold_block <= current_block;
                        hold <= 1;
                        next_angle <= `ANGLE0;
                        case(hold_block)
                            `O_BLOCK: begin
                                next_block <= `O_BLOCK;
                                next_ctrlX[0] <= 4;
                                next_ctrlX[1] <= 5;
                                next_ctrlX[2] <= 4;
                                next_ctrlX[3] <= 5;
                                next_ctrlY[0] <= 0;
                                next_ctrlY[1] <= 0;
                                next_ctrlY[2] <= 1;
                                next_ctrlY[3] <= 1;
                                a1 <= 4;
                                a2 <= 5;
                                a3 <= 14;
                                a4 <= 15;
                            end
                            `L_BLOCK: begin
                                next_block <= `L_BLOCK;
                                next_ctrlX[0] <= 5;
                                next_ctrlX[1] <= 3;
                                next_ctrlX[2] <= 4;
                                next_ctrlX[3] <= 5;
                                next_ctrlY[0] <= 0;
                                next_ctrlY[1] <= 1;
                                next_ctrlY[2] <= 1;
                                next_ctrlY[3] <= 1;
                                a1 <= 5;
                                a2 <= 13;
                                a3 <= 14;
                                a4 <= 15;
                            end
                            `J_BLOCK: begin
                                next_block <= `J_BLOCK;
                                next_ctrlX[0] <= 3;
                                next_ctrlX[1] <= 3;
                                next_ctrlX[2] <= 4;
                                next_ctrlX[3] <= 5;
                                next_ctrlY[0] <= 0;
                                next_ctrlY[1] <= 1;
                                next_ctrlY[2] <= 1;
                                next_ctrlY[3] <= 1;
                                a1 <= 3;
                                a2 <= 13;
                                a3 <= 14;
                                a4 <= 15;
                            end
                            `Z_BLOCK: begin
                                next_block <= `Z_BLOCK;
                                next_ctrlX[0] <= 3;
                                next_ctrlX[1] <= 4;
                                next_ctrlX[2] <= 4;
                                next_ctrlX[3] <= 5;
                                next_ctrlY[0] <= 0;
                                next_ctrlY[1] <= 0;
                                next_ctrlY[2] <= 1;
                                next_ctrlY[3] <= 1;
                                a1 <= 3;
                                a2 <= 4;
                                a3 <= 14;
                                a4 <= 15;
                            end
                            `S_BLOCK: begin
                                next_block <= `S_BLOCK;
                                next_ctrlX[0] <= 4;
                                next_ctrlX[1] <= 5;
                                next_ctrlX[2] <= 3;
                                next_ctrlX[3] <= 4;
                                next_ctrlY[0] <= 0;
                                next_ctrlY[1] <= 0;
                                next_ctrlY[2] <= 1;
                                next_ctrlY[3] <= 1;
                                a1 <= 4;
                                a2 <= 5;
                                a3 <= 13;
                                a4 <= 14;
                            end
                            `I_BLOCK: begin
                                next_block <= `I_BLOCK;
                                next_ctrlX[0] <= 3;
                                next_ctrlX[1] <= 4;
                                next_ctrlX[2] <= 5;
                                next_ctrlX[3] <= 6;
                                next_ctrlY[0] <= 1;
                                next_ctrlY[1] <= 1;
                                next_ctrlY[2] <= 1;
                                next_ctrlY[3] <= 1;
                                a1 <= 13;
                                a2 <= 14;
                                a3 <= 15;
                                a4 <= 16;
                            end
                            `T_BLOCK: begin
                                next_block <= `T_BLOCK;
                                next_ctrlX[0] <= 4;
                                next_ctrlX[1] <= 3;
                                next_ctrlX[2] <= 4;
                                next_ctrlX[3] <= 5;
                                next_ctrlY[0] <= 0;
                                next_ctrlY[1] <= 1;
                                next_ctrlY[2] <= 1;
                                next_ctrlY[3] <= 1;
                                a1 <= 4;
                                a2 <= 13;
                                a3 <= 14;
                                a4 <= 15;
                            end
                            default: begin
                                c_hold <= 1;
                                drop <= 1;
                            end
                        endcase
                    end
                end
                `KEY_CODES_UP: begin
                    if(validClockwise) begin

                        case(current_block)
                            `O_BLOCK: begin
                            end
                            `L_BLOCK: begin
                                case(current_angle)
                                    `ANGLE0: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[2];
                                        next_ctrlY[0] <= ctrlY[2]-1;
                                        next_ctrlX[1] <= ctrlX[2];
                                        next_ctrlY[1] <= ctrlY[2];
                                        next_ctrlX[2] <= ctrlX[2];
                                        next_ctrlY[2] <= ctrlY[2]+1;
                                        next_ctrlX[3] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[2]+1;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[2]-1)*`WIDTH+ctrlX[2];
                                        a2 <= (ctrlY[2]+1)*`WIDTH+ctrlX[2];
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= (ctrlY[2]+1)*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[2]-1)*`WIDTH+ctrlX[2]] <= 1;
                                        // boardMemory[(ctrlY[2]+1)*`WIDTH+ctrlX[2]] <= 1;
                                        // boardMemory[(ctrlY[2]+1)*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;

                                        next_angle <= `ANGLE90;
                                    end
                                    `ANGLE90: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[1]-1+`WIDTH)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[1];
                                        next_ctrlX[1] <= ctrlX[1];
                                        next_ctrlY[1] <= ctrlY[1];
                                        next_ctrlX[2] <= (ctrlX[1]+1)%`WIDTH;
                                        next_ctrlY[2] <= ctrlY[1];
                                        next_ctrlX[3] <= (ctrlX[1]-1+`WIDTH)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[1]+1;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // //boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= ctrlY[1]*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH;
                                        a4 <= (ctrlY[1]+1)*`WIDTH+(ctrlX[1]-1+`WIDTH)%`WIDTH;
                                        // // add new position to memory
                                        //boardMemory[ctrlY[1]*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;
                                        //boardMemory[ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH] <= 1;
                                        //boardMemory[(ctrlY[1]+1)*`WIDTH+(ctrlX[1]-1+`WIDTH)%`WIDTH] <= 1;

                                        // counterwise
                                        next_angle <= `ANGLE180;
                                    end
                                    `ANGLE180: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[1]-1;
                                        next_ctrlX[1] <= ctrlX[1];
                                        next_ctrlY[1] <= ctrlY[1]-1;
                                        next_ctrlX[2] <= ctrlX[1];
                                        next_ctrlY[2] <= ctrlY[1];
                                        next_ctrlX[3] <= ctrlX[1];
                                        next_ctrlY[3] <= ctrlY[1]+1;

                                        // // delete origin position in memory
                                        //boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        //boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        //boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[1]-1)*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= (ctrlY[1]-1)*`WIDTH+ctrlX[1];
                                        a4 <= (ctrlY[1]+1)*`WIDTH+ctrlX[1];
                                        // // add new position to memory
                                        //boardMemory[(ctrlY[1]-1)*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;
                                        //boardMemory[(ctrlY[1]-1)*`WIDTH+ctrlX[1]] <= 1;
                                        //boardMemory[(ctrlY[1]+1)*`WIDTH+ctrlX[1]] <= 1;

                                        // counterclockwise
                                        next_angle <= `ANGLE270;
                                    end
                                    `ANGLE270: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[2]-1;
                                        next_ctrlX[1] <= (ctrlX[2]-1+`WIDTH)%`WIDTH;
                                        next_ctrlY[1] <= ctrlY[2];
                                        next_ctrlX[2] <= ctrlX[2];
                                        next_ctrlY[2] <= ctrlY[2];
                                        next_ctrlX[3] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[2];

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[2]-1)*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        a2 <= ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH;
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[2]-1)*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                                        // boardMemory[ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH] <= 1;
                                        // boardMemory[ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                                        next_angle <= `ANGLE0;
                                    end
                                endcase
                            end
                            `J_BLOCK: begin
                                case(current_angle)
                                    `ANGLE0: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[2];
                                        next_ctrlY[0] <= ctrlY[2]-1;
                                        next_ctrlX[1] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[1] <= ctrlY[2]-1;
                                        next_ctrlX[2] <= ctrlX[2];
                                        next_ctrlY[2] <= ctrlY[2];
                                        next_ctrlX[3] <= ctrlX[2];
                                        next_ctrlY[3] <= ctrlY[2]+1;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[2]-1)*`WIDTH+ctrlX[2];
                                        a2 <= (ctrlY[2]-1)*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= (ctrlY[2]+1)*`WIDTH+ctrlX[2];
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[2]-1)*`WIDTH+ctrlX[2]] <= 1;
                                        // boardMemory[(ctrlY[2]-1)*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[2]+1)*`WIDTH+ctrlX[2]] <= 1;

                                        next_angle <= `ANGLE90;
                                    end
                                    `ANGLE90: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[2]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[2];
                                        next_ctrlX[1] <= ctrlX[2];
                                        next_ctrlY[1] <= ctrlY[2];
                                        next_ctrlX[2] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[2] <= ctrlY[2];
                                        next_ctrlX[3] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[2]+1;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH;
                                        a2 <= ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= (ctrlY[2]+1)*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        // // add new position to memory
                                        // boardMemory[ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH] <= 1;
                                        // boardMemory[ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[2]+1)*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;

                                        // counterwise
                                        next_angle <= `ANGLE180;
                                    end
                                    `ANGLE180: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[1];
                                        next_ctrlY[0] <= ctrlY[1]-1;
                                        next_ctrlX[1] <= ctrlX[1];
                                        next_ctrlY[1] <= ctrlY[1];
                                        next_ctrlX[2] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[2] <= ctrlY[1]+1;
                                        next_ctrlX[3] <= ctrlX[1];
                                        next_ctrlY[3] <= ctrlY[1]+1;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[1]-1)*`WIDTH+ctrlX[1];
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= (ctrlY[1]+1)*`WIDTH+ctrlX[1];
                                        a4 <= (ctrlY[1]+1)*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[1]-1)*`WIDTH+ctrlX[1]] <= 1;
                                        // boardMemory[(ctrlY[1]+1)*`WIDTH+ctrlX[1]] <= 1;
                                        // boardMemory[(ctrlY[1]+1)*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;

                                        // counterclockwise
                                        next_angle <= `ANGLE270;
                                    end
                                    `ANGLE270: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[1]-1;
                                        next_ctrlX[1] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[1] <= ctrlY[1];
                                        next_ctrlX[2] <= ctrlX[1];
                                        next_ctrlY[2] <= ctrlY[1];
                                        next_ctrlX[3] <= (ctrlX[1]+1)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[1];

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[1]-1)*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= ctrlY[1]*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        a4 <= ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH;
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[1]-1)*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;
                                        // boardMemory[ctrlY[1]*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;
                                        // boardMemory[ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH] <= 1;
                                        next_angle <= `ANGLE0;
                                    end
                                endcase
                            end
                            `S_BLOCK: begin
                                case(current_angle)
                                    `ANGLE0: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[0];
                                        next_ctrlY[0] <= ctrlY[0];
                                        next_ctrlX[1] <= ctrlX[3];
                                        next_ctrlY[1] <= ctrlY[3];
                                        next_ctrlX[2] <= (ctrlX[3]+1)%`WIDTH;
                                        next_ctrlY[2] <= ctrlY[3];
                                        next_ctrlX[3] <= (ctrlX[3]+1)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[3]+1;

                                        // // delete origin position in memory
                                        // //boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        a2 <= ctrlY[3]*`WIDTH+(ctrlX[3]+1)%`WIDTH;
                                        a3 <= (ctrlY[3]+1)*`WIDTH+(ctrlX[3]+1)%`WIDTH;
                                        a4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        // // add new position to memory
                                        // boardMemory[ctrlY[3]*`WIDTH+(ctrlX[3]+1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[3]+1)*`WIDTH+(ctrlX[3]+1)%`WIDTH] <= 1;

                                        next_angle <= `ANGLE90;
                                    end
                                    `ANGLE90: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[1];
                                        next_ctrlY[0] <= ctrlY[1];
                                        next_ctrlX[1] <= ctrlX[2];
                                        next_ctrlY[1] <= ctrlY[2];
                                        next_ctrlX[2] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[2] <= ctrlY[1]+1;
                                        next_ctrlX[3] <= ctrlX[1];
                                        next_ctrlY[3] <= ctrlY[1]+1;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[1]+1)*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= (ctrlY[1]+1)*`WIDTH+ctrlX[1];
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[1]+1)*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[1]+1)*`WIDTH+ctrlX[1]] <= 1;

                                        // counterwise
                                        next_angle <= `ANGLE180;
                                    end
                                    `ANGLE180: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[0]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[0]-1;
                                        next_ctrlX[1] <= (ctrlX[0]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[1] <= ctrlY[0];
                                        next_ctrlX[2] <= ctrlX[0];
                                        next_ctrlY[2] <= ctrlY[0];
                                        next_ctrlX[3] <= ctrlX[3];
                                        next_ctrlY[3] <= ctrlY[3];

                                        // // delete origin position in memory
                                        // // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        a2 <= (ctrlY[0]-1)*`WIDTH+(ctrlX[0]+`WIDTH-1)%`WIDTH;
                                        a3 <= ctrlY[0]*`WIDTH+(ctrlX[0]+`WIDTH-1)%`WIDTH;
                                        a4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[0]-1)*`WIDTH+(ctrlX[0]+`WIDTH-1)%`WIDTH] <= 1;
                                        // boardMemory[ctrlY[0]*`WIDTH+(ctrlX[0]+`WIDTH-1)%`WIDTH] <= 1;

                                        // counterclockwise
                                        next_angle <= `ANGLE270;
                                    end
                                    `ANGLE270: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[2];
                                        next_ctrlY[0] <= ctrlY[2]-1;
                                        next_ctrlX[1] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[1] <= ctrlY[2]-1;
                                        next_ctrlX[2] <= ctrlX[1];
                                        next_ctrlY[2] <= ctrlY[1];
                                        next_ctrlX[3] <= ctrlX[2];
                                        next_ctrlY[3] <= ctrlY[2];

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[2]-1)*`WIDTH+ctrlX[2];
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= (ctrlY[2]-1)*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[2]-1)*`WIDTH+ctrlX[2]] <= 1;
                                        // boardMemory[(ctrlY[2]-1)*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                                        next_angle <= `ANGLE0;
                                    end
                                endcase
                            end
                            `Z_BLOCK: begin
                                case(current_angle)
                                    `ANGLE0: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[2]-1;
                                        next_ctrlX[1] <= ctrlX[2];
                                        next_ctrlY[1] <= ctrlY[2];
                                        next_ctrlX[2] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[2] <= ctrlY[2];
                                        next_ctrlX[3] <= ctrlX[2];
                                        next_ctrlY[3] <= ctrlY[2]+1;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[2]-1)*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        a2 <= (ctrlY[2]+1)*`WIDTH+ctrlX[2];
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[2]-1)*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                                        // //boardMemory[ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[2]+1)*`WIDTH+ctrlX[2]] <= 1;

                                        next_angle <= `ANGLE90;
                                    end
                                    `ANGLE90: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[1];
                                        next_ctrlX[1] <= ctrlX[1];
                                        next_ctrlY[1] <= ctrlY[1];
                                        next_ctrlX[2] <= ctrlX[1];
                                        next_ctrlY[2] <= ctrlY[1]+1;
                                        next_ctrlX[3] <= (ctrlX[1]+1)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[1]+1;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= ctrlY[1]*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= (ctrlY[1]+1)*`WIDTH+(ctrlX[1]+1)%`WIDTH;
                                        a4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        // // add new position to memory
                                        // boardMemory[ctrlY[1]*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;
                                        // //boardMemory[(ctrlY[1]+1)*`WIDTH+ctrlX[1]] <= 1;
                                        // boardMemory[(ctrlY[1]+1)*`WIDTH+(ctrlX[1]+1)%`WIDTH] <= 1;

                                        // counterwise
                                        next_angle <= `ANGLE180;
                                    end
                                    `ANGLE180: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[1];
                                        next_ctrlY[0] <= ctrlY[1]-1;
                                        next_ctrlX[1] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[1] <= ctrlY[1];
                                        next_ctrlX[2] <= ctrlX[1];
                                        next_ctrlY[2] <= ctrlY[1];
                                        next_ctrlX[3] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[1]+1;

                                        // // delete origin position in memory
                                        // //boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // //boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= (ctrlY[1]-1)*`WIDTH+ctrlX[1];
                                        a4 <= (ctrlY[1]+1)*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[1]-1)*`WIDTH+ctrlX[1]] <= 1;
                                        // //boardMemory[ctrlY[1]*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[1]+1)*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;

                                        // counterclockwise
                                        next_angle <= `ANGLE270;
                                    end
                                    `ANGLE270: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[2]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[2]-1;
                                        next_ctrlX[1] <= ctrlX[2];
                                        next_ctrlY[1] <= ctrlY[2]-1;
                                        next_ctrlX[2] <= ctrlX[2];
                                        next_ctrlY[2] <= ctrlY[2];
                                        next_ctrlX[3] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[2];

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[2]-1)*`WIDTH+(ctrlX[2]+`WIDTH-1)%`WIDTH;
                                        a2 <= (ctrlY[2]-1)*`WIDTH+ctrlX[2];
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[2]-1)*`WIDTH+(ctrlX[2]+`WIDTH-1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[2]-1)*`WIDTH+ctrlX[2]] <= 1;
                                        // boardMemory[ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                                        next_angle <= `ANGLE0;
                                    end
                                endcase
                            end
                            `I_BLOCK: begin
                                case(current_angle)
                                    `ANGLE0: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[2];
                                        next_ctrlY[0] <= ctrlY[2]-1;
                                        next_ctrlX[1] <= ctrlX[2];
                                        next_ctrlY[1] <= ctrlY[2];
                                        next_ctrlX[2] <= ctrlX[2];
                                        next_ctrlY[2] <= ctrlY[2]+1;
                                        next_ctrlX[3] <= ctrlX[2];
                                        next_ctrlY[3] <= ctrlY[2]+2;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[2]-1)*`WIDTH+ctrlX[2];
                                        a2 <= (ctrlY[2]+1)*`WIDTH+ctrlX[2];
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= (ctrlY[2]+2)*`WIDTH+ctrlX[2];
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[2]-1)*`WIDTH+ctrlX[2]] <= 1;
                                        // boardMemory[(ctrlY[2]+1)*`WIDTH+ctrlX[2]] <= 1;
                                        // boardMemory[(ctrlY[2]+2)*`WIDTH+ctrlX[2]] <= 1;

                                        next_angle <= `ANGLE90;
                                    end
                                    `ANGLE90: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[2]+`WIDTH-2)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[2];
                                        next_ctrlX[1] <= (ctrlX[2]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[1] <= ctrlY[2];
                                        next_ctrlX[2] <= ctrlX[2];
                                        next_ctrlY[2] <= ctrlY[2];
                                        next_ctrlX[3] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[2];

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[2])*`WIDTH+(ctrlX[2]+`WIDTH-2)%`WIDTH;
                                        a2 <= (ctrlY[2])*`WIDTH+(ctrlX[2]+`WIDTH-1)%`WIDTH;
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= (ctrlY[2])*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[2])*`WIDTH+(ctrlX[2]+`WIDTH-2)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[2])*`WIDTH+(ctrlX[2]+`WIDTH-1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[2])*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;

                                        // counterwise
                                        next_angle <= `ANGLE180;
                                    end
                                    `ANGLE180: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[1];
                                        next_ctrlY[0] <= ctrlY[1]-2;
                                        next_ctrlX[1] <= ctrlX[1];
                                        next_ctrlY[1] <= ctrlY[1]-1;
                                        next_ctrlX[2] <= ctrlX[1];
                                        next_ctrlY[2] <= ctrlY[1];
                                        next_ctrlX[3] <= ctrlX[1];
                                        next_ctrlY[3] <= ctrlY[1]+1;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[1]-2)*`WIDTH+ctrlX[1];
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= (ctrlY[1]-1)*`WIDTH+ctrlX[1];
                                        a4 <= (ctrlY[1]+1)*`WIDTH+ctrlX[1];
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[1]-2)*`WIDTH+ctrlX[1]] <= 1;
                                        // boardMemory[(ctrlY[1]-1)*`WIDTH+ctrlX[1]] <= 1;
                                        // boardMemory[(ctrlY[1]+1)*`WIDTH+ctrlX[1]] <= 1;

                                        // counterclockwise
                                        next_angle <= `ANGLE270;
                                    end
                                    `ANGLE270: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[1];
                                        next_ctrlX[1] <= ctrlX[1];
                                        next_ctrlY[1] <= ctrlY[1];
                                        next_ctrlX[2] <= (ctrlX[1]+1)%`WIDTH;
                                        next_ctrlY[2] <= ctrlY[1];
                                        next_ctrlX[3] <= (ctrlX[1]+2)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[1];

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[1])*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= (ctrlY[1])*`WIDTH+(ctrlX[1]+1)%`WIDTH;
                                        a4 <= (ctrlY[1])*`WIDTH+(ctrlX[1]+2)%`WIDTH;
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[1])*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[1])*`WIDTH+(ctrlX[1]+1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[1])*`WIDTH+(ctrlX[1]+2)%`WIDTH] <= 1;
                                        next_angle <= `ANGLE0;
                                    end
                                endcase
                            end
                            `T_BLOCK: begin
                                case(current_angle)
                                    `ANGLE0: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[2];
                                        next_ctrlY[0] <= ctrlY[2]-1;
                                        next_ctrlX[1] <= ctrlX[2];
                                        next_ctrlY[1] <= ctrlY[2];
                                        next_ctrlX[2] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[2] <= ctrlY[2];
                                        next_ctrlX[3] <= ctrlX[2];
                                        next_ctrlY[3] <= ctrlY[2]+1;

                                        // // delete origin position in memory
                                        // // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        a2 <= (ctrlY[2]+1)*`WIDTH+ctrlX[2];
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        // // add new position to memory
                                        // //boardMemory[(ctrlY[2]-1)*`WIDTH+ctrlX[2]] <= 1;
                                        // //boardMemory[(ctrlY[2])*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[2]+1)*`WIDTH+ctrlX[2]] <= 1;

                                        next_angle <= `ANGLE90;
                                    end
                                    `ANGLE90: begin
                                        // update current position
                                        next_ctrlX[0] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[0] <= ctrlY[1];
                                        next_ctrlX[1] <= ctrlX[1];
                                        next_ctrlY[1] <= ctrlY[1];
                                        next_ctrlX[2] <= (ctrlX[1]+1)%`WIDTH;
                                        next_ctrlY[2] <= ctrlY[1];
                                        next_ctrlX[3] <= ctrlX[1];
                                        next_ctrlY[3] <= ctrlY[1]+1;

                                        // // delete origin position in memory
                                        // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= (ctrlY[1])*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[1])*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;
                                        // //boardMemory[(ctrlY[1])*`WIDTH+(ctrlX[1]+1)%`WIDTH] <= 1;
                                        // //boardMemory[(ctrlY[1]+1)*`WIDTH+ctrlX[1]] <= 1;

                                        // counterwise
                                        next_angle <= `ANGLE180;
                                    end
                                    `ANGLE180: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[1];
                                        next_ctrlY[0] <= ctrlY[1]-1;
                                        next_ctrlX[1] <= (ctrlX[1]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[1] <= ctrlY[1];
                                        next_ctrlX[2] <= ctrlX[1];
                                        next_ctrlY[2] <= ctrlY[1];
                                        next_ctrlX[3] <= ctrlX[1];
                                        next_ctrlY[3] <= ctrlY[1]+1;

                                        // // delete origin position in memory
                                        // //boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // //boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= (ctrlY[1]-1)*`WIDTH+ctrlX[1];
                                        a4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        // // add new position to memory
                                        // boardMemory[(ctrlY[1]-1)*`WIDTH+ctrlX[1]] <= 1;
                                        // //boardMemory[(ctrlY[1])*`WIDTH+(ctrlX[1]+`WIDTH-1)%`WIDTH] <= 1;
                                        // //boardMemory[(ctrlY[1]+1)*`WIDTH+ctrlX[1]] <= 1;

                                        // counterclockwise
                                        next_angle <= `ANGLE270;
                                    end
                                    `ANGLE270: begin
                                        // update current position
                                        next_ctrlX[0] <= ctrlX[2];
                                        next_ctrlY[0] <= ctrlY[2]-1;
                                        next_ctrlX[1] <= (ctrlX[2]+`WIDTH-1)%`WIDTH;
                                        next_ctrlY[1] <= ctrlY[2];
                                        next_ctrlX[2] <= ctrlX[2];
                                        next_ctrlY[2] <= ctrlY[2];
                                        next_ctrlX[3] <= (ctrlX[2]+1)%`WIDTH;
                                        next_ctrlY[3] <= ctrlY[2];

                                        // // delete origin position in memory
                                        // //boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                                        // //boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                                        // //boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                                        // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                                        d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                                        a1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                                        a2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                                        a3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                                        a4 <= (ctrlY[2])*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                                        // // add new position to memory
                                        // //boardMemory[(ctrlY[2]-1)*`WIDTH+ctrlX[2]] <= 1;
                                        // //boardMemory[(ctrlY[2])*`WIDTH+(ctrlX[2]+`WIDTH-1)%`WIDTH] <= 1;
                                        // boardMemory[(ctrlY[2])*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                                        next_angle <= `ANGLE0;
                                    end
                                endcase
                            end
                            default: begin
                            end
                        endcase
                    end
                end
                `KEY_CODES_DOWN: begin
                    if(validDown) begin
                        // next position and original position overlap condition
                        if((ctrlY[0]*`WIDTH+ctrlX[0] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                                (ctrlY[0]*`WIDTH+ctrlX[0] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                                (ctrlY[0]*`WIDTH+ctrlX[0] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                            // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                            d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                        end
                        else begin
                            d1 <= 201;
                        end
                        if((ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[0]+1)*`WIDTH+ctrlX[0]) &&
                                (ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                                (ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                            // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                            d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                        end
                        else begin
                            d2 <= 201;
                        end
                        if((ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                                (ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[0]+1)*`WIDTH+ctrlX[0]) &&
                                (ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                            // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                            d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                        end
                        else begin
                            d3 <= 201;
                        end
                        if((ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                                (ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                                (ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[0]+1)*`WIDTH+ctrlX[0])) begin
                            // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                            d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                        end
                        else begin
                            d4 <= 201;
                        end
                        // add next position to boardMemory
                        a1 <= (ctrlY[0]+1)*`WIDTH + ctrlX[0];
                        a2 <= (ctrlY[1]+1)*`WIDTH + ctrlX[1];
                        a3 <= (ctrlY[2]+1)*`WIDTH + ctrlX[2];
                        a4 <= (ctrlY[3]+1)*`WIDTH + ctrlX[3];
                        // boardMemory[(ctrlY[0]+1)*`WIDTH + ctrlX[0]] <= 1'b1;
                        // boardMemory[(ctrlY[1]+1)*`WIDTH + ctrlX[1]] <= 1'b1;
                        // boardMemory[(ctrlY[2]+1)*`WIDTH + ctrlX[2]] <= 1'b1;
                        // boardMemory[(ctrlY[3]+1)*`WIDTH + ctrlX[3]] <= 1'b1;
                        next_ctrlX[0] <= ctrlX[0];
                        next_ctrlX[1] <= ctrlX[1];
                        next_ctrlX[2] <= ctrlX[2];
                        next_ctrlX[3] <= ctrlX[3];
                        next_ctrlY[0] <= ctrlY[0] + 1;
                        next_ctrlY[1] <= ctrlY[1] + 1;
                        next_ctrlY[2] <= ctrlY[2] + 1;
                        next_ctrlY[3] <= ctrlY[3] + 1;
                    end
                    else begin
                        // drop
                        drop <= 1;
                    end
                end
                `KEY_CODES_LEFT: begin
                    if(validLeft) begin
                        // overlap condition
                        if((ctrlY[0]*`WIDTH+ctrlX[0] != ctrlY[1]*`WIDTH+(ctrlX[1]-1+`WIDTH)%`WIDTH) &&
                                (ctrlY[0]*`WIDTH+ctrlX[0] != ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH) &&
                                (ctrlY[0]*`WIDTH+ctrlX[0] != ctrlY[3]*`WIDTH+(ctrlX[3]-1+`WIDTH)%`WIDTH)) begin
                            // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                            d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                        end
                        else begin
                            d1 <= 201;
                        end
                        if((ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[0]*`WIDTH+(ctrlX[0]-1+`WIDTH)%`WIDTH) &&
                                (ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH) &&
                                (ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[3]*`WIDTH+(ctrlX[3]-1+`WIDTH)%`WIDTH)) begin
                            // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                            d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                        end
                        else begin
                            d2 <= 201;
                        end
                        if((ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[1]*`WIDTH+(ctrlX[1]-1+`WIDTH)%`WIDTH) &&
                                (ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[0]*`WIDTH+(ctrlX[0]-1+`WIDTH)%`WIDTH) &&
                                (ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[3]*`WIDTH+(ctrlX[3]-1+`WIDTH)%`WIDTH)) begin
                            // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                            d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                        end
                        else begin
                            d3 <= 201;
                        end
                        if((ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[1]*`WIDTH+(ctrlX[1]-1+`WIDTH)%`WIDTH) &&
                                (ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH) &&
                                (ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[0]*`WIDTH+(ctrlX[0]-1+`WIDTH)%`WIDTH)) begin
                            // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                            d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                        end
                        else begin
                            d4 <= 201;
                        end

                        // add next position to boardMemory
                        next_ctrlX[0] <= (ctrlX[0]-1+`WIDTH)%`WIDTH;
                        // boardMemory[ctrlY[0]*`WIDTH+(ctrlX[0]-1+`WIDTH)%`WIDTH] <= 1;
                        a1 <= ctrlY[0]*`WIDTH+(ctrlX[0]-1+`WIDTH)%`WIDTH;
                        next_ctrlX[1] <= (ctrlX[1]-1+`WIDTH)%`WIDTH;
                        // boardMemory[ctrlY[1]*`WIDTH+(ctrlX[1]-1+`WIDTH)%`WIDTH] <= 1;
                        a2 <= ctrlY[1]*`WIDTH+(ctrlX[1]-1+`WIDTH)%`WIDTH;
                        next_ctrlX[2] <= (ctrlX[2]-1+`WIDTH)%`WIDTH;
                        // boardMemory[ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH] <= 1;
                        a3 <= ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH;
                        next_ctrlX[3] <= (ctrlX[3]-1+`WIDTH)%`WIDTH;
                        // boardMemory[ctrlY[3]*`WIDTH+(ctrlX[3]-1+`WIDTH)%`WIDTH] <= 1;
                        a4 <= ctrlY[3]*`WIDTH+(ctrlX[3]-1+`WIDTH)%`WIDTH;

                        next_ctrlY[0] <= ctrlY[0];
                        next_ctrlY[1] <= ctrlY[1];
                        next_ctrlY[2] <= ctrlY[2];
                        next_ctrlY[3] <= ctrlY[3];
                    end
                end
                `KEY_CODES_RIGHT: begin
                    if(validRight) begin
                        // overlap condition
                        if((ctrlY[0]*`WIDTH+ctrlX[0] != ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH) &&
                                (ctrlY[0]*`WIDTH+ctrlX[0] != ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH) &&
                                (ctrlY[0]*`WIDTH+ctrlX[0] != ctrlY[3]*`WIDTH+(ctrlX[3]+1)%`WIDTH)) begin
                            // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                            d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                        end
                        else begin
                            d1 <= 201;
                        end
                        if((ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[0]*`WIDTH+(ctrlX[0]+1)%`WIDTH) &&
                                (ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH) &&
                                (ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[3]*`WIDTH+(ctrlX[3]+1)%`WIDTH)) begin
                            // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                            d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                        end
                        else begin
                            d2 <= 201;
                        end
                        if((ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH) &&
                                (ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[0]*`WIDTH+(ctrlX[0]+1)%`WIDTH) &&
                                (ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[3]*`WIDTH+(ctrlX[3]+1)%`WIDTH)) begin
                            // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                            d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                        end
                        else begin
                            d3 <= 201;
                        end
                        if((ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH) &&
                                (ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH) &&
                                (ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[0]*`WIDTH+(ctrlX[0]+1)%`WIDTH)) begin
                            // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                            d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                        end
                        else begin
                            d4 <= 201;
                        end

                        // add next position to board memory
                        next_ctrlX[0] <= (ctrlX[0]+1)%`WIDTH;
                        // boardMemory[ctrlY[0]*`WIDTH+(ctrlX[0]+1)%`WIDTH] <= 1;
                        a1 <= ctrlY[0]*`WIDTH+(ctrlX[0]+1)%`WIDTH;
                        next_ctrlX[1] <= (ctrlX[1]+1)%`WIDTH;
                        // boardMemory[ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH] <= 1;
                        a2 <= ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH;
                        next_ctrlX[2] <= (ctrlX[2]+1)%`WIDTH;
                        // boardMemory[ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH] <= 1;
                        a3 <= ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH;
                        next_ctrlX[3] <= (ctrlX[3]+1)%`WIDTH;
                        // boardMemory[ctrlY[3]*`WIDTH+(ctrlX[3]+1)%`WIDTH] <= 1;
                        a4 <= ctrlY[3]*`WIDTH+(ctrlX[3]+1)%`WIDTH;

                        next_ctrlY[0] <= ctrlY[0];
                        next_ctrlY[1] <= ctrlY[1];
                        next_ctrlY[2] <= ctrlY[2];
                        next_ctrlY[3] <= ctrlY[3];
                    end
                end
                `KEY_CODES_SPACE: begin
                    d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                    d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                    d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                    d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                    a1 <= shadowY[0]*`WIDTH + ctrlX[0];
                    a2 <= shadowY[1]*`WIDTH + ctrlX[1];
                    a3 <= shadowY[2]*`WIDTH + ctrlX[2];
                    a4 <= shadowY[3]*`WIDTH + ctrlX[3];
                    harddrop <= 1;
                end
                `KEY_CODES_ESC: begin
                    start <= 1;
                end
                default: begin
                    a1 <= a1;
                    a2 <= a2;
                    a3 <= a3;
                    a4 <= a4;
                    d1 <= d1;
                    d2 <= d2;
                    d3 <= d3;
                    d4 <= d4;
                end
            endcase
        end
        else if(harddrop) begin
            drop <= 1;
            harddrop <= 0;
        end
        else begin
            a1 <= a1;
            a2 <= a2;
            a3 <= a3;
            a4 <= a4;
            d1 <= d1;
            d2 <= d2;
            d3 <= d3;
            d4 <= d4;

            if(validDown == 0) begin
                start_1s_cnt <= start_1s_cnt + 1;
                if(start_1s_cnt == 31'd90000000) begin
                    drop <= 1;
                    start_1s_cnt <= 0;
                end
            end
            else begin
                start_1s_cnt <= 0;
            end
        end
    end
    else begin
        next_ctrlX[0] <= 5;
        next_ctrlX[1] <= 3;
        next_ctrlX[2] <= 4;
        next_ctrlX[3] <= 5;
        next_ctrlY[0] <= 0;
        next_ctrlY[1] <= 1;
        next_ctrlY[2] <= 1;
        next_ctrlY[3] <= 1;
        hold_block <= `NONE;
        next_block <= `L_BLOCK;
        next_angle <= `ANGLE0;
    end
end
endmodule

