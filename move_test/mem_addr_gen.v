`timescale 1ns / 1ps
`include "global.v"

module mem_addr_gen(
   input clk,
   input rst,
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   input [511:0] key_down,
   input [8:0] last_change,
   input been_ready,
   output [16:0] pixel_addr,
   output [9:0] ctrl_upMost,
   output [9:0] ctrl_downMost,
   output [9:0] ctrl_leftMost,
   output [9:0] ctrl_rightMost
   );

//    localparam KEY_CODES_UP = `KEY_CODES_UP;
//    localparam KEY_CODES_DOWN = `KEY_CODES_DOWN;
//    localparam KEY_CODES_LEFT = `KEY_CODES_LEFT;
//    localparam KEY_CODES_RIGHT = `KEY_CODES_RIGHT;
//    localparam UP_MOST = `UP_MOST;
//    localparam DOWN_MOST = `DOWN_MOST;
//    localparam LEFT_MOST = `LEFT_MOST;
//    localparam RIGHT_MOST = `RIGHT_MOST;


   reg [16:0] pixel_addr;
   reg [7:0] position;
   reg [9:0] ctrl_upMost = `UP_MOST;
   reg [9:0] ctrl_downMost = 10'd80;
   reg [9:0] ctrl_leftMost = 10'd300;
   reg [9:0] ctrl_rightMost = 10'd340;   
//    always@(*)begin
//         pixel_addr <= ((h_cnt>>1)+320*(v_cnt>>1)+ position*320)% 76800;
//    end  

   always @ (posedge clk) begin
       if (been_ready && key_down[last_change] == 1'b1) begin
            case (last_change)
                `KEY_CODES_UP: begin
                    if(ctrl_upMost - 20 >= `UP_MOST) begin
                        ctrl_upMost <= ctrl_upMost - 20;
                        ctrl_downMost <= ctrl_downMost - 20;
                    end else begin
                        ctrl_upMost <= ctrl_upMost;
                        ctrl_downMost <= ctrl_downMost;
                    end
                    // if(position < 236)begin
                        // position <= position + 2'd3;
                    // end else begin
                        // position <= 0;
                    // end 
                end
                `KEY_CODES_DOWN: begin
                    if(ctrl_downMost + 20 <= `DOWN_MOST) begin
                        ctrl_upMost <= ctrl_upMost + 20;
                        ctrl_downMost <= ctrl_downMost + 20;
                    end else begin
                        ctrl_upMost <= ctrl_upMost;
                        ctrl_downMost <= ctrl_downMost;
                    end
                    // position <= position - 2'd3;
                    
                end 
                `KEY_CODES_LEFT: begin
                    if(ctrl_leftMost - 20 >= `LEFT_MOST) begin
                        ctrl_leftMost <= ctrl_leftMost - 20;
                        ctrl_rightMost <= ctrl_rightMost - 20;
                    end else begin
                        ctrl_leftMost <= ctrl_leftMost;
                        ctrl_rightMost <= ctrl_rightMost;
                    end
                    // position <= position - 2'd3;      
                end 
                `KEY_CODES_RIGHT: begin
                    if(ctrl_rightMost + 20 <= `RIGHT_MOST) begin
                        ctrl_leftMost <= ctrl_leftMost + 20;
                        ctrl_rightMost <= ctrl_rightMost + 20;
                    end else begin
                        ctrl_leftMost <= ctrl_leftMost;
                        ctrl_rightMost <= ctrl_rightMost;
                    end
                    // position <= position - 2'd3;
                    
                end 
                default: begin
                    ctrl_upMost <= ctrl_upMost;
                    ctrl_downMost <= ctrl_downMost;
                    // position <= position;
                end
            endcase
        end
   end
    
endmodule
