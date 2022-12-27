`timescale 1ns / 1ps
module TOP (
           input clk,
           input rst,
           output reg[3:0] vgaRed,
           output reg[3:0] vgaGreen,
           output reg[3:0] vgaBlue,
           output hsync,
           output vsync,
           inout wire PS2_DATA,
           inout wire PS2_CLK,
           output pmod_1,	//AIN
           output pmod_2,	//GAIN
           output pmod_4	//SHUTDOWN_N
       );

//vga
wire [11:0] data;
wire clk_25MHz;
wire clk_22;
wire [16:0] pixel_addr, pixel_back_addr;
wire [11:0] pixel, pixel_back;
wire valid;
wire [9:0] h_cnt; //640
wire [9:0] v_cnt;  //480

//keyboard
wire [511:0] key_down;
wire [8:0] last_change;
wire been_ready;
wire [9:0] ctrl_upMost;
wire [9:0] ctrl_downMost;
wire [9:0] ctrl_leftMost;
wire [9:0] ctrl_rightMost;

reg [8:0] operation;

clock_divisor clk_wiz_0_inst(
        .clk(clk),
        .clk1(clk_25MHz),
        .clk22(clk_22)
    );
    
mem_addr_gen mem_addr_gen_inst(
        .clk(clk),
        .rst(rst),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr),
        .been_ready(been_ready),
        .key_down(key_down),
        .last_change(last_change),
        .ctrl_upMost(ctrl_upMost),
        .ctrl_downMost(ctrl_downMost),
        .ctrl_leftMost(ctrl_leftMost),
        .ctrl_rightMost(ctrl_rightMost)
    );

blk_mem_gen_0 blk_mem_gen_0_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(((h_cnt>>1)+320*(v_cnt>>1))% 76800),
        .dina(data[11:0]),
        .douta(pixel_back)
    ); 


blk_mem_gen_1 blk_mem_gen_1_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel)
    ); 

vga_controller vga_inst(
        .pclk(clk_25MHz),
        .reset(rst),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );

KeyboardDecoder key_de (
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
    );

always@(*)begin
    // if(v_cnt <= downMost && v_cnt >= upMost && h_cnt >= leftMost && h_cnt <= rightMost)begin
    if(v_cnt >= ctrl_upMost && v_cnt < ctrl_downMost && h_cnt > ctrl_leftMost+1 && h_cnt <= ctrl_rightMost+1) begin
        {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;
    end else begin
        {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_back:12'h0;
    end
end
endmodule
