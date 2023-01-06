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
    output [9:0] shadowY1,
    output [9:0] shadowY2,
    output [9:0] shadowY3,
    output [9:0] shadowY4

);
    reg [9:0] shadowY1, shadowY2, shadowY3, shadowY4;
    reg [9:0] cnt [18:0];
    always@(*) begin
        if(cnt[18] != 30) begin
            shadowY1 = ctrlY1;
            shadowY2 = ctrlY2;
            shadowY3 = ctrlY3;
            shadowY4 = ctrlY4;
        end else if(cnt[0] != 30) begin
            shadowY1 = ctrlY1+cnt[0];
            shadowY2 = ctrlY2+cnt[0];
            shadowY3 = ctrlY3+cnt[0];
            shadowY4 = ctrlY4+cnt[0];
        end else if(cnt[1] != 30) begin
            shadowY1 = ctrlY1+cnt[1];
            shadowY2 = ctrlY2+cnt[1];
            shadowY3 = ctrlY3+cnt[1];
            shadowY4 = ctrlY4+cnt[1];
        end else if(cnt[2] != 30) begin
            shadowY1 = ctrlY1+cnt[2];
            shadowY2 = ctrlY2+cnt[2];
            shadowY3 = ctrlY3+cnt[2];
            shadowY4 = ctrlY4+cnt[2];
        end
        else if(cnt[3] != 30) begin
            shadowY1 = ctrlY1+cnt[3];
            shadowY2 = ctrlY2+cnt[3];
            shadowY3 = ctrlY3+cnt[3];
            shadowY4 = ctrlY4+cnt[3];
        end
        else if(cnt[4] != 30) begin
            shadowY1 = ctrlY1+cnt[4];
            shadowY2 = ctrlY2+cnt[4];
            shadowY3 = ctrlY3+cnt[4];
            shadowY4 = ctrlY4+cnt[4];
        end
        else if(cnt[5] != 30) begin
            shadowY1 = ctrlY1+cnt[5];
            shadowY2 = ctrlY2+cnt[5];
            shadowY3 = ctrlY3+cnt[5];
            shadowY4 = ctrlY4+cnt[5];
        end
        else if(cnt[6] != 30) begin
            shadowY1 = ctrlY1+cnt[6];
            shadowY2 = ctrlY2+cnt[6];
            shadowY3 = ctrlY3+cnt[6];
            shadowY4 = ctrlY4+cnt[6];
        end
        else if(cnt[7] != 30) begin
            shadowY1 = ctrlY1+cnt[7];
            shadowY2 = ctrlY2+cnt[7];
            shadowY3 = ctrlY3+cnt[7];
            shadowY4 = ctrlY4+cnt[7];
        end
        else if(cnt[8] != 30) begin
            shadowY1 = ctrlY1+cnt[8];
            shadowY2 = ctrlY2+cnt[8];
            shadowY3 = ctrlY3+cnt[8];
            shadowY4 = ctrlY4+cnt[8];
        end
        else if(cnt[9] != 30) begin
            shadowY1 = ctrlY1+cnt[9];
            shadowY2 = ctrlY2+cnt[9];
            shadowY3 = ctrlY3+cnt[9];
            shadowY4 = ctrlY4+cnt[9];
        end
        else if(cnt[10] != 30) begin
            shadowY1 = ctrlY1+cnt[10];
            shadowY2 = ctrlY2+cnt[10];
            shadowY3 = ctrlY3+cnt[10];
            shadowY4 = ctrlY4+cnt[10];
        end
        else if(cnt[11] != 30) begin
            shadowY1 = ctrlY1+cnt[11];
            shadowY2 = ctrlY2+cnt[11];
            shadowY3 = ctrlY3+cnt[11];
            shadowY4 = ctrlY4+cnt[11];
        end
        else if(cnt[12] != 30) begin
            shadowY1 = ctrlY1+cnt[12];
            shadowY2 = ctrlY2+cnt[12];
            shadowY3 = ctrlY3+cnt[12];
            shadowY4 = ctrlY4+cnt[12];
        end
        else if(cnt[13] != 30) begin
            shadowY1 = ctrlY1+cnt[13];
            shadowY2 = ctrlY2+cnt[13];
            shadowY3 = ctrlY3+cnt[13];
            shadowY4 = ctrlY4+cnt[13];
        end
        else if(cnt[14] != 30) begin
            shadowY1 = ctrlY1+cnt[14];
            shadowY2 = ctrlY2+cnt[14];
            shadowY3 = ctrlY3+cnt[14];
            shadowY4 = ctrlY4+cnt[14];
        end
        else if(cnt[15] != 30) begin
            shadowY1 = ctrlY1+cnt[15];
            shadowY2 = ctrlY2+cnt[15];
            shadowY3 = ctrlY3+cnt[15];
            shadowY4 = ctrlY4+cnt[15];
        end
        else if(cnt[16] != 30) begin
            shadowY1 = ctrlY1+cnt[16];
            shadowY2 = ctrlY2+cnt[16];
            shadowY3 = ctrlY3+cnt[16];
            shadowY4 = ctrlY4+cnt[16];
        end
        else if(cnt[17] != 30) begin
            shadowY1 = ctrlY1+cnt[17];
            shadowY2 = ctrlY2+cnt[17];
            shadowY3 = ctrlY3+cnt[17];
            shadowY4 = ctrlY4+cnt[17];
        end else begin
            shadowY1 = ctrlY1;
            shadowY2 = ctrlY2;
            shadowY3 = ctrlY3;
            shadowY4 = ctrlY4;
        end
        
    end
    always@(posedge clk) begin
        if((ctrlY1 >= 19 || ctrlY2 >= 19 || ctrlY3 >= 19 || ctrlY4 >= 19
                    || boardMemory[(ctrlY1 + 1)*`WIDTH + ctrlX1] && ((ctrlY1 + 1) != ctrlY2 || ctrlX1 != ctrlX2) && ((ctrlY1 + 1) != ctrlY3 || ctrlX1 != ctrlX3) && ((ctrlY1 + 1) != ctrlY4 || ctrlX1 != ctrlX4)
                    || boardMemory[(ctrlY2 + 1)*`WIDTH + ctrlX2] && ((ctrlY2 + 1) != ctrlY1 || ctrlX1 != ctrlX2) && ((ctrlY2 + 1) != ctrlY3 || ctrlX3 != ctrlX2) && ((ctrlY2 + 1) != ctrlY4 || ctrlX2 != ctrlX4) 
                    || boardMemory[(ctrlY3 + 1)*`WIDTH + ctrlX3] && ((ctrlY3 + 1) != ctrlY2 || ctrlX3 != ctrlX2) && ((ctrlY3 + 1) != ctrlY1 || ctrlX1 != ctrlX3) && ((ctrlY3 + 1) != ctrlY4 || ctrlX3 != ctrlX4) 
                    || boardMemory[(ctrlY4 + 1)*`WIDTH + ctrlX4] && ((ctrlY4 + 1) != ctrlY2 || ctrlX4 != ctrlX2) && ((ctrlY4 + 1) != ctrlY3 || ctrlX4 != ctrlX3) && ((ctrlY4 + 1) != ctrlY1 || ctrlX1 != ctrlX4)
                    ))begin
                        cnt[18] <= 0;
            end 
        else begin
            cnt[18] <= 30;
        end
        if((ctrlY1 >= 18 || ctrlY2 >= 18 || ctrlY3 >= 18 || ctrlY4 >= 18
                    || boardMemory[(ctrlY1 + 2)*`WIDTH + ctrlX1] && ((ctrlY1 + 2) != ctrlY2 || ctrlX1 != ctrlX2) && ((ctrlY1 + 2) != ctrlY3 || ctrlX1 != ctrlX3) && ((ctrlY1 + 2) != ctrlY4 || ctrlX1 != ctrlX4)
                    || boardMemory[(ctrlY2 + 2)*`WIDTH + ctrlX2] && ((ctrlY2 + 2) != ctrlY1 || ctrlX1 != ctrlX2) && ((ctrlY2 + 2) != ctrlY3 || ctrlX3 != ctrlX2) && ((ctrlY2 + 2) != ctrlY4 || ctrlX2 != ctrlX4) 
                    || boardMemory[(ctrlY3 + 2)*`WIDTH + ctrlX3] && ((ctrlY3 + 2) != ctrlY2 || ctrlX3 != ctrlX2) && ((ctrlY3 + 2) != ctrlY1 || ctrlX1 != ctrlX3) && ((ctrlY3 + 2) != ctrlY4 || ctrlX3 != ctrlX4) 
                    || boardMemory[(ctrlY4 + 2)*`WIDTH + ctrlX4] && ((ctrlY4 + 2) != ctrlY2 || ctrlX4 != ctrlX2) && ((ctrlY4 + 2) != ctrlY3 || ctrlX4 != ctrlX3) && ((ctrlY4 + 2) != ctrlY1 || ctrlX1 != ctrlX4) 
                     )) begin
                        cnt[0] <= 1;
            end 
        else begin
            cnt[0] <= 30;
        end
            if((ctrlY1 >= 17 || ctrlY2 >= 17 || ctrlY3 >= 17 || ctrlY4 >= 17
                    || boardMemory[(ctrlY1 + 3)*`WIDTH + ctrlX1] && (ctrlY1+3)!= ctrlY4
                    || boardMemory[(ctrlY2 + 3)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 3)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 3)*`WIDTH + ctrlX4] 
                     )) begin
                        cnt[1] <= 2;
            end 
        else begin
            cnt[1] <= 30;
        end
            if((ctrlY1 >= 16 || ctrlY2 >= 16 || ctrlY3 >= 16 || ctrlY4 >= 16
                    || boardMemory[(ctrlY1 + 4)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 4)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 4)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 4)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[2] <= 3;
            end 
        else begin
            cnt[2] <= 30;
        end
            if((ctrlY1 >= 15 || ctrlY2 >= 15 || ctrlY3 >= 15 || ctrlY4 >= 15
                    || boardMemory[(ctrlY1 + 5)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 5)*`WIDTH + ctrlX2]  
                    || boardMemory[(ctrlY3 + 5)*`WIDTH + ctrlX3]
                    || boardMemory[(ctrlY4 + 5)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[3] <= 4;
            end 
        else begin
            cnt[3] <= 30;
        end
            if((ctrlY1 >= 14 || ctrlY2 >= 14 || ctrlY3 >= 14 || ctrlY4 >= 14
                    || boardMemory[(ctrlY1 + 6)*`WIDTH + ctrlX1]
                    || boardMemory[(ctrlY2 + 6)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 6)*`WIDTH + ctrlX3]
                    || boardMemory[(ctrlY4 + 6)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[4] <= 5;
            end 
        else begin
            cnt[4] <= 30;
        end
            if((ctrlY1 >= 13 || ctrlY2 >= 13 || ctrlY3 >= 13 || ctrlY4 >= 13
                    || boardMemory[(ctrlY1 + 7)*`WIDTH + ctrlX1]
                    || boardMemory[(ctrlY2 + 7)*`WIDTH + ctrlX2]
                    || boardMemory[(ctrlY3 + 7)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 7)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[5] <= 6;
            end 
        else begin
            cnt[5] <= 30;
        end
            if((ctrlY1 >= 12 || ctrlY2 >= 12 || ctrlY3 >= 12 || ctrlY4 >= 12
                    || boardMemory[(ctrlY1 + 8)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 8)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 8)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 8)*`WIDTH + ctrlX4]
                    )) begin
                        cnt[6] <= 7;
            end 
        else begin
            cnt[6] <= 30;
        end
            if((ctrlY1 >= 11 || ctrlY2 >= 11 || ctrlY3 >= 11 || ctrlY4 >= 11
                    || boardMemory[(ctrlY1 + 9)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 9)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 9)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 9)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[7] <= 8;
            end 
        else begin
            cnt[7] <= 30;
        end
            if((ctrlY1 >= 10 || ctrlY2 >= 10 || ctrlY3 >= 10 || ctrlY4 >= 10
                    || boardMemory[(ctrlY1 + 10)*`WIDTH + ctrlX1]
                    || boardMemory[(ctrlY2 + 10)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 10)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 10)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[8] <= 9;
            end 
        else begin
            cnt[8] <= 30;
        end
            if((ctrlY1 >= 9 || ctrlY2 >= 9 || ctrlY3 >= 9 || ctrlY4 >= 9
                    || boardMemory[(ctrlY1 + 11)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 11)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 11)*`WIDTH + ctrlX3]
                    || boardMemory[(ctrlY4 + 11)*`WIDTH + ctrlX4]  
                    )) begin
                        cnt[9] <= 10;
            end 
        else begin
            cnt[9] <= 30;
        end
            if((ctrlY1 >= 8 || ctrlY2 >= 8 || ctrlY3 >= 8 || ctrlY4 >= 8
                    || boardMemory[(ctrlY1 + 12)*`WIDTH + ctrlX1]
                    || boardMemory[(ctrlY2 + 12)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 12)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 12)*`WIDTH + ctrlX4]
                    )) begin
                        cnt[10] <= 11;
            end 
        else begin
            cnt[10] <= 30;
        end
            if((ctrlY1 >= 7 || ctrlY2 >= 7 || ctrlY3 >= 7 || ctrlY4 >= 7
                    || boardMemory[(ctrlY1 + 13)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 13)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 13)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 13)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[11] <= 12;
            end 
        else begin
            cnt[11] <= 30;
        end
            if((ctrlY1 >= 6 || ctrlY2 >= 6 || ctrlY3 >= 6 || ctrlY4 >= 6
                    || boardMemory[(ctrlY1 + 14)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 14)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 14)*`WIDTH + ctrlX3]
                    || boardMemory[(ctrlY4 + 14)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[12] <= 13;
            end 
        else begin
            cnt[12] <= 30;
        end
            if((ctrlY1 >= 5 || ctrlY2 >= 5 || ctrlY3 >= 5 || ctrlY4 >= 5
                    || boardMemory[(ctrlY1 + 15)*`WIDTH + ctrlX1]
                    || boardMemory[(ctrlY2 + 15)*`WIDTH + ctrlX2]  
                    || boardMemory[(ctrlY3 + 15)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 15)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[13] <= 14;
            end 
        else begin
            cnt[13] <= 30;
        end
            if((ctrlY1 >= 4 || ctrlY2 >= 4 || ctrlY3 >= 4 || ctrlY4 >= 4
                    || boardMemory[(ctrlY1 + 16)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 16)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 16)*`WIDTH + ctrlX3]
                    || boardMemory[(ctrlY4 + 16)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[14] <= 15;
            end 
        else begin
            cnt[14] <= 30;
        end
            if((ctrlY1 >= 3 || ctrlY2 >= 3 || ctrlY3 >= 3 || ctrlY4 >= 3
                    || boardMemory[(ctrlY1 + 17)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 17)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 17)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 17)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[15] <= 16;
            end 
        else begin
            cnt[15] <= 30;
        end
            if((ctrlY1 >= 2 || ctrlY2 >= 2 || ctrlY3 >= 2 || ctrlY4 >= 2
                    || boardMemory[(ctrlY1 + 18)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 18)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 18)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 18)*`WIDTH + ctrlX4] 
                    )) begin
                        cnt[16] <= 17;
            end 
        else begin
            cnt[16] <= 30;
        end
            if((ctrlY1 >= 1 || ctrlY2 >= 1 || ctrlY3 >= 1 || ctrlY4 >= 1
                    || boardMemory[(ctrlY1 + 19)*`WIDTH + ctrlX1] 
                    || boardMemory[(ctrlY2 + 19)*`WIDTH + ctrlX2] 
                    || boardMemory[(ctrlY3 + 19)*`WIDTH + ctrlX3] 
                    || boardMemory[(ctrlY4 + 19)*`WIDTH + ctrlX4]
                    )) begin
                        cnt[17] <= 18;
            end 
        else begin
            cnt[17] <= 30;
        end
                    
                    
    end    
endmodule