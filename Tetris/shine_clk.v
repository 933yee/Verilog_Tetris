`timescale 1ns / 1ps
module shine_clk (clk, clk_out, rst);
output reg clk_out = 1'b0;
input clk, rst;
reg [31:0]count = 32'd0;
always@(posedge clk) begin
    if(count == 32'd10000000) begin
        count <= 32'd0;
        clk_out <= ~clk_out;
    end
    else begin
        count <= count + 1'b1;
    end
end
endmodule
