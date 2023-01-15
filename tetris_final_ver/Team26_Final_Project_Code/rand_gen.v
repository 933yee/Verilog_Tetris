
`timescale 1ns / 1ps
`include "global.v"

module rand_gen (
           input clk,
           input rst,
           output [3:0]random_block,
           input drop
       );
reg [3:0] rec;
reg [3:0] random_block;
reg [2:0] cnt;
reg [3:0] delay;
always@(*) begin
    if(delay == 4'b1000)
        random_block = rec;
end
always@(posedge clk) begin
    if(rst) begin
        cnt <= 1;
        delay <= 4'b0000;
    end
    else begin
        if(drop) begin
            rec <= cnt;
            delay <= 4'b0001;
        end
        else begin
            delay <= {delay[2:0], 1'b0};
        end
        if(cnt == 7)
            cnt <= 1;
        else
            cnt <= cnt + 1;
    end
end

endmodule
