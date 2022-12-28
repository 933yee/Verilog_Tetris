`timescale 1ns / 1ps
`include "global.v"

module validMove(
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
    output validLeft, 
    output validRight, 
    output validDown
);
    reg validLeft, validRight, validDown;
    
    // tmp registers
    reg [3:0]lr, rr;
    reg validDown_next;


    always@(posedge clk) begin
        validLeft <= lr[0] & lr[1] & lr[2] & lr[3];
        validRight <= rr[0] & rr[1] & rr[2] & rr[3];
        validDown <= validDown_next;
    end

    always@(*)begin
        // left move
        // check whether there are some blocks on the left side exist 

        // four blocks
        if(ctrlX1 == 0) begin
            if(ctrlY1 * `WIDTH + `WIDTH - 1 == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY1 * `WIDTH + `WIDTH - 1 == ctrlY3 * `WIDTH + ctrlX3 ||
               ctrlY1 * `WIDTH + `WIDTH - 1 == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY1 * `WIDTH + `WIDTH - 1] == 0) begin
                lr[0] = 1;
            end else begin
                lr[0] = 0;
            end
        end else begin
            if(ctrlY1 * `WIDTH + ctrlX1 - 1 == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY1 * `WIDTH + ctrlX1 - 1 == ctrlY3 * `WIDTH + ctrlX3 ||
               ctrlY1 * `WIDTH + ctrlX1 - 1 == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY1 * `WIDTH + ctrlX1 - 1] == 0) begin
                lr[0] = 1;
            end else begin
                lr[0] = 0;
            end
        end

        if(ctrlX2 == 0) begin
            if(ctrlY2 * `WIDTH + `WIDTH - 1 == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY2 * `WIDTH + `WIDTH - 1 == ctrlY3 * `WIDTH + ctrlX3 ||
               ctrlY2 * `WIDTH + `WIDTH - 1 == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY2 * `WIDTH + `WIDTH - 1] == 0) begin
                lr[1] = 1;
            end else begin
                lr[1] = 0;
            end
        end else begin
            if(ctrlY2 * `WIDTH + ctrlX2 - 1 == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY2 * `WIDTH + ctrlX2 - 1 == ctrlY3 * `WIDTH + ctrlX3 ||
               ctrlY2 * `WIDTH + ctrlX2 - 1 == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY2 * `WIDTH + ctrlX2 - 1] == 0) begin
                lr[1] = 1;
            end else begin
                lr[1] = 0;
            end
        end

        if(ctrlX3 == 0) begin
            if(ctrlY3 * `WIDTH + `WIDTH - 1 == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY3 * `WIDTH + `WIDTH - 1 == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY3 * `WIDTH + `WIDTH - 1 == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY3 * `WIDTH + `WIDTH - 1] == 0) begin
                lr[2] = 1;
            end else begin
                lr[2] = 0;
            end
        end else begin
            if(ctrlY3 * `WIDTH + ctrlX3 - 1 == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY3 * `WIDTH + ctrlX3 - 1 == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY3 * `WIDTH + ctrlX3 - 1 == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY3 * `WIDTH + ctrlX3 - 1] == 0) begin
                lr[2] = 1;
            end else begin
                lr[2] = 0;
            end
        end

        if(ctrlX4 == 0) begin
            if(ctrlY4 * `WIDTH + `WIDTH - 1 == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY4 * `WIDTH + `WIDTH - 1 == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY4 * `WIDTH + `WIDTH - 1 == ctrlY3 * `WIDTH + ctrlX3 ||
               boardMemory[ctrlY4 * `WIDTH + `WIDTH - 1] == 0) begin
                lr[3] = 1;
            end else begin
                lr[3] = 0;
            end
        end else begin
            if(ctrlY4 * `WIDTH + ctrlX4 - 1 == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY4 * `WIDTH + ctrlX4 - 1 == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY4 * `WIDTH + ctrlX4 - 1 == ctrlY3 * `WIDTH + ctrlX3 ||
               boardMemory[ctrlY4 * `WIDTH + ctrlX4 - 1] == 0) begin
                lr[3] = 1;
            end else begin
                lr[3] = 0;
            end
        end

        // right move
        if(ctrlX1 == `WIDTH - 1) begin
            if(ctrlY1 * `WIDTH == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY1 * `WIDTH == ctrlY3 * `WIDTH + ctrlX3 ||
               ctrlY1 * `WIDTH == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY1 * `WIDTH] == 0) begin
                rr[0] = 1;
            end else begin
                rr[0] = 0;
            end
        end else begin
            if(ctrlY1 * `WIDTH + ctrlX1 + 1 == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY1 * `WIDTH + ctrlX1 + 1 == ctrlY3 * `WIDTH + ctrlX3 ||
               ctrlY1 * `WIDTH + ctrlX1 + 1 == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY1 * `WIDTH + ctrlX1 + 1] == 0) begin
                rr[0] = 1;
            end else begin
                rr[0] = 0;
            end
        end

        if(ctrlX2 == `WIDTH - 1) begin
            if(ctrlY2 * `WIDTH == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY2 * `WIDTH == ctrlY3 * `WIDTH + ctrlX3 ||
               ctrlY2 * `WIDTH == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY2 * `WIDTH] == 0) begin
                rr[1] = 1;
            end else begin
                rr[1] = 0;
            end
        end else begin
            if(ctrlY2 * `WIDTH + ctrlX2 + 1 == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY2 * `WIDTH + ctrlX2 + 1 == ctrlY3 * `WIDTH + ctrlX3 ||
               ctrlY2 * `WIDTH + ctrlX2 + 1 == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY2 * `WIDTH + ctrlX2 + 1] == 0) begin
                rr[1] = 1;
            end else begin
                rr[1] = 0;
            end
        end

        if(ctrlX3 == `WIDTH - 1) begin
            if(ctrlY3 * `WIDTH == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY3 * `WIDTH == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY3 * `WIDTH == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY3 * `WIDTH] == 0) begin
                rr[2] = 1;
            end else begin
                rr[2] = 0;
            end
        end else begin
            if(ctrlY3 * `WIDTH + ctrlX3 + 1 == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY3 * `WIDTH + ctrlX3 + 1 == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY3 * `WIDTH + ctrlX3 + 1 == ctrlY4 * `WIDTH + ctrlX4 ||
               boardMemory[ctrlY3 * `WIDTH + ctrlX3 + 1] == 0) begin
                rr[2] = 1;
            end else begin
                rr[2] = 0;
            end
        end

        if(ctrlX4 == `WIDTH - 1) begin
            if(ctrlY4 * `WIDTH == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY4 * `WIDTH == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY4 * `WIDTH == ctrlY3 * `WIDTH + ctrlX3 ||
               boardMemory[ctrlY4 * `WIDTH] == 0) begin
                rr[3] = 1;
            end else begin
                rr[3] = 0;
            end
        end else begin
            if(ctrlY4 * `WIDTH + ctrlX4 + 1 == ctrlY1 * `WIDTH + ctrlX1 ||
               ctrlY4 * `WIDTH + ctrlX4 + 1 == ctrlY2 * `WIDTH + ctrlX2 ||
               ctrlY4 * `WIDTH + ctrlX4 + 1 == ctrlY3 * `WIDTH + ctrlX3 ||
               boardMemory[ctrlY4 * `WIDTH + ctrlX4 + 1] == 0) begin
                rr[3] = 1;
            end else begin
                rr[3] = 0;
            end
        end

        // down move
        if((ctrlY1+1) * `WIDTH + ctrlX1 < 200 && (ctrlY2+1) * `WIDTH + ctrlX2 < 200 && (ctrlY3+1) * `WIDTH + ctrlX3 < 200 && (ctrlY4+1) * `WIDTH + ctrlX4 < 200) begin
            if(((ctrlY1+1) * `WIDTH + ctrlX1 == ctrlY2 * `WIDTH + ctrlX2 || 
                (ctrlY1+1) * `WIDTH + ctrlX1 == ctrlY3 * `WIDTH + ctrlX3 || 
                (ctrlY1+1) * `WIDTH + ctrlX1 == ctrlY4 * `WIDTH + ctrlX4 ||
                boardMemory[(ctrlY1+1) * `WIDTH + ctrlX1] == 0) && 

                ((ctrlY2+1) * `WIDTH + ctrlX2 == ctrlY1 * `WIDTH + ctrlX1 || 
                (ctrlY2+1) * `WIDTH + ctrlX2 == ctrlY3 * `WIDTH + ctrlX3 || 
                (ctrlY2+1) * `WIDTH + ctrlX2 == ctrlY4 * `WIDTH + ctrlX4 ||
                boardMemory[(ctrlY2+1) * `WIDTH + ctrlX2] == 0) && 

                ((ctrlY3+1) * `WIDTH + ctrlX3 == ctrlY2 * `WIDTH + ctrlX2 || 
                (ctrlY3+1) * `WIDTH + ctrlX3 == ctrlY1 * `WIDTH + ctrlX1 || 
                (ctrlY3+1) * `WIDTH + ctrlX3 == ctrlY4 * `WIDTH + ctrlX4 ||
                boardMemory[(ctrlY3+1) * `WIDTH + ctrlX3] == 0) && 

                ((ctrlY4+1) * `WIDTH + ctrlX4 == ctrlY2 * `WIDTH + ctrlX2 || 
                (ctrlY4+1) * `WIDTH + ctrlX4 == ctrlY3 * `WIDTH + ctrlX3 || 
                (ctrlY4+1) * `WIDTH + ctrlX4 == ctrlY1 * `WIDTH + ctrlX1 ||
                boardMemory[(ctrlY4+1) * `WIDTH + ctrlX4] == 0)
                )begin
                validDown_next = 1;
            end else begin
                validDown_next = 0;
            end
        end else begin
            validDown_next = 0;
        end
    end
endmodule