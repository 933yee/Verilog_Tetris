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
   output valid_rotate_led
   );
   // pixel
   reg [16:0] pixel_addr;

   // board data
   reg [0:199] boardMemory = 200'b0000010000_0001110000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000; // left_up to right_down
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
   reg start = 1;

   // calculate the coordinates of the boardMemory 
   wire [9:0] memoryX, memoryY;
   twenty_division td1(.dividend(h_cnt-`LEFT_MOST), .out(memoryX));
   twenty_division td2(.dividend(v_cnt-`UP_MOST), .out(memoryY));

   // clk
   wire clk_1s;
   clock_divisor_1s cd1(
        .clk(clk),
        .clk_out(clk_1s),
        .rst(been_ready && key_down[last_change] && last_change == `KEY_CODES_DOWN)
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
    reg drop;
    checklines checklines_(
        .clk(clk), 
        .boardMemory(boardMemory), 
        .fullLine(fullLine),
        .fullLines(fullLines)
    );
    
    // shadow generator
    wire [9:0] shadowX[3:0];
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
        .shadowX1(shadowX[0]), 
        .shadowX2(shadowX[1]), 
        .shadowX3(shadowX[2]), 
        .shadowX4(shadowX[3]), 
        .shadowY1(shadowY[0]), 
        .shadowY2(shadowY[1]), 
        .shadowY3(shadowY[2]), 
        .shadowY4(shadowY[3])
    );



    always@(*) begin
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



   // vga
   always@(*) begin
        if(valid) begin
            if(h_cnt > `LEFT_MOST+1 && h_cnt <= `RIGHT_MOST && v_cnt >= `UP_MOST && v_cnt < `DOWN_MOST) begin
                if(boardMemory[memoryY*`WIDTH+memoryX] == 1'b1) begin
                    if(v_cnt % 20 == 0 || h_cnt % 20 == 0 || v_cnt % 20 == 19 || h_cnt % 20 == 19) begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                    end else if (v_cnt % 20 > 3 && v_cnt % 20 < 16 && h_cnt % 20 > 3 && h_cnt % 20 < 16) begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                    end else if ((h_cnt % 20 == 16 && v_cnt % 20 == 1) || (h_cnt % 20 == 15 && v_cnt % 20 == 2) || (h_cnt % 20 == 14 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 14) || (h_cnt % 20 == 2 && v_cnt % 20 == 15) || (h_cnt % 20 == 1 && v_cnt % 20 == 16)) begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'hf10;
                    end else if ((h_cnt % 20 == 17 && v_cnt % 20 == 1) || (h_cnt % 20 == 16 && v_cnt % 20 == 2) || (h_cnt % 20 == 15 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 15) || (h_cnt % 20 == 2 && v_cnt % 20 == 16) || (h_cnt % 20 == 1 && v_cnt % 20 == 17)) begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'hf20;
                    end else if ((h_cnt % 20 == 18 && v_cnt % 20 == 1) || (h_cnt % 20 == 17 && v_cnt % 20 == 2) || (h_cnt % 20 == 16 && v_cnt % 20 == 3) || (h_cnt % 20 == 3 && v_cnt % 20 == 16) || (h_cnt % 20 == 2 && v_cnt % 20 == 17) || (h_cnt % 20 == 1 && v_cnt % 20 == 18)) begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'hf30;
                    end else if ((h_cnt % 20 == 18 && v_cnt % 20 == 2) || (h_cnt % 20 == 17 && v_cnt % 20 == 3) || (h_cnt % 20 == 16 && v_cnt % 20 == 4) || (h_cnt % 20 == 4 && v_cnt % 20 == 16) || (h_cnt % 20 == 3 && v_cnt % 20 == 17) || (h_cnt % 20 == 2 && v_cnt % 20 == 18)) begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'hf40;
                    end else if ((h_cnt % 20 == 18 && v_cnt % 20 == 3) || (h_cnt % 20 == 17 && v_cnt % 20 == 4) || (h_cnt % 20 == 16 && v_cnt % 20 == 5) || (h_cnt % 20 == 5 && v_cnt % 20 == 16) || (h_cnt % 20 == 4 && v_cnt % 20 == 17) || (h_cnt % 20 == 3 && v_cnt % 20 == 18)) begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'hf50;
                    end else if ((h_cnt % 20 < 16 && v_cnt % 20 < 4) || (h_cnt % 20 < 4 && v_cnt % 20 < 16)) begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'hf00;
                    end else begin
                        {vgaRed, vgaGreen, vgaBlue} = 12'hf60;
                    end
                    // {vgaRed, vgaGreen, vgaBlue} = pixel;
                end else if(shadowY[0] == memoryY && shadowX[0] == memoryX || shadowY[1] == memoryY && shadowX[1] == memoryX|| shadowY[2] == memoryY && shadowX[2] == memoryX|| shadowY[3] == memoryY && shadowX[3] == memoryX)begin
                    {vgaRed, vgaGreen, vgaBlue} = 12'h222;
                end else begin
                    {vgaRed, vgaGreen, vgaBlue} = pixel_back;
                end
            end else begin
                {vgaRed, vgaGreen, vgaBlue} = pixel_back;
            end
        end else begin
            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
        end
   end


    // update game scene
   always@ (posedge clk) begin
        if(drop) begin
            if(fullLines[19]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:189]};
            end else if(fullLines[18]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:179], boardMemory[190:199]};
            end else if(fullLines[17]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:169], boardMemory[180:199]};
            end else if(fullLines[16]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:159], boardMemory[170:199]};
            end else if(fullLines[15]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:149], boardMemory[160:199]};
            end else if(fullLines[14]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:139], boardMemory[150:199]};
            end else if(fullLines[13]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:129], boardMemory[140:199]};
            end else if(fullLines[12]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:119], boardMemory[130:199]};
            end else if(fullLines[11]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:109], boardMemory[120:199]};
            end else if(fullLines[10]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:99], boardMemory[110:199]};
            end else if(fullLines[9]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:89], boardMemory[100:199]};
            end else if(fullLines[8]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:79], boardMemory[90:199]};
            end else if(fullLines[7]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:69], boardMemory[80:199]};
            end else if(fullLines[6]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:59], boardMemory[70:199]};
            end else if(fullLines[5]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:49], boardMemory[60:199]};
            end else if(fullLines[4]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:39], boardMemory[50:199]};
            end else if(fullLines[3]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:29], boardMemory[40:199]};
            end else if(fullLines[2]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:19], boardMemory[30:199]};
            end else if(fullLines[1]) begin
                boardMemory <= {10'b0000000000, boardMemory[0:9], boardMemory[20:199]};
            end else if(fullLines[0]) begin
                boardMemory <= {10'b0000000000, boardMemory[10:199]};
            end
        end else begin
            if(d1 != a1 && d1 != a2 && d1 != a3 && d1 != a4 && d1 != 201) boardMemory[d1] <= 0;
            if(d2 != a1 && d2 != a2 && d2 != a3 && d2 != a4 && d2 != 201) boardMemory[d2] <= 0;
            if(d3 != a1 && d3 != a2 && d3 != a3 && d3 != a4 && d3 != 201) boardMemory[d3] <= 0;
            if(d4 != a1 && d4 != a2 && d4 != a3 && d4 != a4 && d4 != 201) boardMemory[d4] <= 0;
            if(a1 != 201) boardMemory[a1] <= 1;
            if(a2 != 201) boardMemory[a2] <= 1;
            if(a3 != 201) boardMemory[a3] <= 1;
            if(a4 != 201) boardMemory[a4] <= 1;
        end
   end

    // calculate next value
   always @ (posedge clk) begin
       if(start) begin
            start <= 0;
            //S_BLOCK
            // ctrlX[0] <= 4;
            // ctrlX[1] <= 5;
            // ctrlX[2] <= 3;
            // ctrlX[3] <= 4;
            // ctrlY[0] <= 0;
            // ctrlY[1] <= 0;
            // ctrlY[2] <= 1;
            // ctrlY[3] <= 1;
            // boardMemory <= 200'b0000110000_0001100000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000;
            
            //L_BLOCK
            next_ctrlX[0] <= 5;
            next_ctrlX[1] <= 3;
            next_ctrlX[2] <= 4;
            next_ctrlX[3] <= 5;
            next_ctrlY[0] <= 0;
            next_ctrlY[1] <= 1;
            next_ctrlY[2] <= 1;
            next_ctrlY[3] <= 1;

            // boardMemory <= 200'b0000010000_0001110000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000;
            next_block <= `L_BLOCK;
            next_angle <= `ANGLE0;
            drop <= 0;
            d1 <= 201;
            d2 <= 201;
            d3 <= 201;
            d4 <= 201;
            a1 <= 201;
            a2 <= 201;
            a3 <= 201;
            a4 <= 201;
       end else if(clk_1s) begin
            if(validDown) begin
                // next position and original position overlap condition
                if((ctrlY[0]*`WIDTH+ctrlX[0] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                    (ctrlY[0]*`WIDTH+ctrlX[0] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                    (ctrlY[0]*`WIDTH+ctrlX[0] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                    // boardMemory[ctrlY[0]*`WIDTH+ctrlX[0]] <= 0;
                    d1 <= ctrlY[0]*`WIDTH+ctrlX[0];
                end else begin
                    d1 <= 201;
                end
                if((ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[0]+1)*`WIDTH+ctrlX[0]) &&
                    (ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                    (ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                    // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                    d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                end else begin
                    d2 <= 201;
                end
                if((ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                    (ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[0]+1)*`WIDTH+ctrlX[0]) &&
                    (ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                    // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                    d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                end else begin
                    d3 <= 201;
                end
                if((ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                    (ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                    (ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[0]+1)*`WIDTH+ctrlX[0])) begin
                    // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                    d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                end else begin
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
            end else begin
                // drop
                drop <= 1;
            end
       end else if(drop) begin
            d1 <= 201;
            d2 <= 201;
            d3 <= 201;
            d4 <= 201;
            if(fullLine == 0) begin
                //create new block
                drop <= 0;
                case(current_block)
                    `O_BLOCK:begin
                        next_ctrlX[0] <= 5;
                        next_ctrlX[1] <= 3;
                        next_ctrlX[2] <= 4;
                        next_ctrlX[3] <= 5;
                        next_ctrlY[0] <= 0;
                        next_ctrlY[1] <= 1;
                        next_ctrlY[2] <= 1;
                        next_ctrlY[3] <= 1;
                        a1 <= 5;
                        a2 <= `WIDTH + 3;
                        a3 <= `WIDTH + 4;
                        a4 <= `WIDTH + 5;
                        // boardMemory[5] <= 1'b1;
                        // boardMemory[`WIDTH + 3] <= 1'b1;
                        // boardMemory[`WIDTH + 4] <= 1'b1;
                        // boardMemory[`WIDTH + 5] <= 1'b1;
                        next_block <= `L_BLOCK;
                    end
                    `L_BLOCK:begin
                        next_ctrlX[0] <= 3;
                        next_ctrlX[1] <= 3;
                        next_ctrlX[2] <= 4;
                        next_ctrlX[3] <= 5;
                        next_ctrlY[0] <= 0;
                        next_ctrlY[1] <= 1;
                        next_ctrlY[2] <= 1;
                        next_ctrlY[3] <= 1;
                        a1 <= 3;
                        a2 <= `WIDTH + 3;
                        a3 <= `WIDTH + 4;
                        a4 <= `WIDTH + 5;
                        // boardMemory[3] <= 1'b1;
                        // boardMemory[`WIDTH + 3] <= 1'b1;
                        // boardMemory[`WIDTH + 4] <= 1'b1;
                        // boardMemory[`WIDTH + 5] <= 1'b1;
                        next_block <= `J_BLOCK;
                    end
                    `J_BLOCK:begin
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
                        a3 <= `WIDTH + 3;
                        a4 <= `WIDTH + 4;
                        // boardMemory[4] <= 1'b1;
                        // boardMemory[`WIDTH + 5] <= 1'b1;
                        // boardMemory[`WIDTH + 3] <= 1'b1;
                        // boardMemory[`WIDTH + 4] <= 1'b1;
                        next_block <= `S_BLOCK;
                    end
                    `S_BLOCK:begin
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
                        a3 <= `WIDTH + 4;
                        a4 <= `WIDTH + 5;
                        // boardMemory[3] <= 1'b1;
                        // boardMemory[4] <= 1'b1;
                        // boardMemory[`WIDTH + 4] <= 1'b1;
                        // boardMemory[`WIDTH + 5] <= 1'b1;
                        next_block <= `Z_BLOCK;
                    end
                    `Z_BLOCK:begin
                        next_ctrlX[0] <= 3;
                        next_ctrlX[1] <= 4;
                        next_ctrlX[2] <= 5;
                        next_ctrlX[3] <= 6;
                        next_ctrlY[0] <= 0;
                        next_ctrlY[1] <= 0;
                        next_ctrlY[2] <= 0;
                        next_ctrlY[3] <= 0;
                        a1 <= 3;
                        a2 <= 4;
                        a3 <= 5;
                        a4 <= 6;
                        // boardMemory[3] <= 1'b1;
                        // boardMemory[4] <= 1'b1;
                        // boardMemory[5] <= 1'b1;
                        // boardMemory[6] <= 1'b1;
                        next_block <= `I_BLOCK;
                    end
                    `I_BLOCK:begin
                        next_ctrlX[0] <= 4;
                        next_ctrlX[1] <= 3;
                        next_ctrlX[2] <= 4;
                        next_ctrlX[3] <= 5;
                        next_ctrlY[0] <= 0;
                        next_ctrlY[1] <= 1;
                        next_ctrlY[2] <= 1;
                        next_ctrlY[3] <= 1;
                        a1 <= 4;
                        a2 <= `WIDTH + 3;
                        a3 <= `WIDTH + 4;
                        a4 <= `WIDTH + 5;
                        // boardMemory[4] <= 1'b1;
                        // boardMemory[`WIDTH + 3] <= 1'b1;
                        // boardMemory[`WIDTH + 4] <= 1'b1;
                        // boardMemory[`WIDTH + 5] <= 1'b1;
                        next_block <= `T_BLOCK;
                    end
                    `T_BLOCK:begin
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
                        a3 <= `WIDTH + 4;
                        a4 <= `WIDTH + 5;
                        // boardMemory[4] <= 1'b1;
                        // boardMemory[5] <= 1'b1;
                        // boardMemory[`WIDTH + 4] <= 1'b1;
                        // boardMemory[`WIDTH + 5] <= 1'b1;
                        next_block <= `O_BLOCK;
                    end
                endcase
                
                next_angle <= `ANGLE0;
            end
       end else if (been_ready && key_down[last_change] == 1'b1) begin
            
            case (last_change)
                `KEY_CODES_UP:begin
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
                            default:begin
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
                        end else begin
                            d1 <= 201;
                        end
                        if((ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[0]+1)*`WIDTH+ctrlX[0]) &&
                           (ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                           (ctrlY[1]*`WIDTH+ctrlX[1] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                            // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                            d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                        end else begin
                            d2 <= 201;
                        end
                        if((ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                           (ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[0]+1)*`WIDTH+ctrlX[0]) &&
                           (ctrlY[2]*`WIDTH+ctrlX[2] != (ctrlY[3]+1)*`WIDTH+ctrlX[3])) begin
                            // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                            d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                        end else begin
                            d3 <= 201;
                        end
                        if((ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[1]+1)*`WIDTH+ctrlX[1]) &&
                           (ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[2]+1)*`WIDTH+ctrlX[2]) &&
                           (ctrlY[3]*`WIDTH+ctrlX[3] != (ctrlY[0]+1)*`WIDTH+ctrlX[0])) begin
                            // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                            d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                        end else begin
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
                    end else begin
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
                        end else begin
                            d1 <= 201;
                        end
                        if((ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[0]*`WIDTH+(ctrlX[0]-1+`WIDTH)%`WIDTH) &&
                           (ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH) &&
                           (ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[3]*`WIDTH+(ctrlX[3]-1+`WIDTH)%`WIDTH)) begin
                            // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                            d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                        end else begin
                            d2 <= 201;
                        end
                        if((ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[1]*`WIDTH+(ctrlX[1]-1+`WIDTH)%`WIDTH) &&
                           (ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[0]*`WIDTH+(ctrlX[0]-1+`WIDTH)%`WIDTH) &&
                           (ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[3]*`WIDTH+(ctrlX[3]-1+`WIDTH)%`WIDTH)) begin
                            // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                            d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                        end else begin
                            d3 <= 201;
                        end
                        if((ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[1]*`WIDTH+(ctrlX[1]-1+`WIDTH)%`WIDTH) &&
                           (ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[2]*`WIDTH+(ctrlX[2]-1+`WIDTH)%`WIDTH) &&
                           (ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[0]*`WIDTH+(ctrlX[0]-1+`WIDTH)%`WIDTH)) begin
                            // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                            d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                        end else begin
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
                        end else begin
                            d1 <= 201;
                        end
                        if((ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[0]*`WIDTH+(ctrlX[0]+1)%`WIDTH) &&
                           (ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH) &&
                           (ctrlY[1]*`WIDTH+ctrlX[1] != ctrlY[3]*`WIDTH+(ctrlX[3]+1)%`WIDTH)) begin
                            // boardMemory[ctrlY[1]*`WIDTH+ctrlX[1]] <= 0;
                            d2 <= ctrlY[1]*`WIDTH+ctrlX[1];
                        end else begin
                            d2 <= 201;
                        end
                        if((ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH) &&
                           (ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[0]*`WIDTH+(ctrlX[0]+1)%`WIDTH) &&
                           (ctrlY[2]*`WIDTH+ctrlX[2] != ctrlY[3]*`WIDTH+(ctrlX[3]+1)%`WIDTH)) begin
                            // boardMemory[ctrlY[2]*`WIDTH+ctrlX[2]] <= 0;
                            d3 <= ctrlY[2]*`WIDTH+ctrlX[2];
                        end else begin
                            d3 <= 201;
                        end
                        if((ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[1]*`WIDTH+(ctrlX[1]+1)%`WIDTH) &&
                           (ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[2]*`WIDTH+(ctrlX[2]+1)%`WIDTH) &&
                           (ctrlY[3]*`WIDTH+ctrlX[3] != ctrlY[0]*`WIDTH+(ctrlX[0]+1)%`WIDTH)) begin
                            // boardMemory[ctrlY[3]*`WIDTH+ctrlX[3]] <= 0;
                            d4 <= ctrlY[3]*`WIDTH+ctrlX[3];
                        end else begin
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
       end else begin
            a1 <= a1;
            a2 <= a2;
            a3 <= a3;
            a4 <= a4;
            d1 <= d1;
            d2 <= d2;
            d3 <= d3;
            d4 <= d4;
       end
   end
    
endmodule


