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
    output validClockwise, 
    output validCounterclockwise 
);
    reg validClockwise, validCounterclockwise;
    always@(*) begin
        case(current_block) 
            `O_BLOCK: begin
                validClockwise = 1;
                validCounterclockwise = 1;
            end
            `L_BLOCK: begin
                
            end
            `J_BLOCK: begin
            
            end
            `S_BLOCK: begin
                
            end
            `Z_BLOCK: begin
            
            end
            `I_BLOCK: begin
            
            end
            `T_BLOCK: begin
            
            end
            default:begin
            end
        endcase
    end

endmodule