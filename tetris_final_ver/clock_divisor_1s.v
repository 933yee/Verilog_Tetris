`timescale 1ns / 1ps
module clock_divisor_1s (clk, clk_out, rst);
output reg clk_out = 1'b0;
input clk, rst;
reg [31:0]count = 32'd0;
always@(posedge clk) begin
    if(rst) begin
        clk_out <= 0;
        count <= 0;
    end
    else if(count == 32'd100000000) begin
        count <= 32'd0;
        clk_out <= 1;
    end
    else begin
        clk_out <= 0;
        count <= count + 1'b1;
    end
end
endmodule
