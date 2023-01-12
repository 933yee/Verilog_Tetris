`timescale 1ns / 1ps
module TOP (
           input clk,
           input rst,
           output [3:0] vgaRed,
           output [3:0] vgaGreen,
           output [3:0] vgaBlue,
           output hsync,
           output vsync,
           inout wire PS2_DATA,
           inout wire PS2_CLK,
           output pmod_1,	//AIN
           output pmod_2,	//GAIN
           output pmod_4,	//SHUTDOWN_N
           output led // debug rotate
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
wire [3:0] level;
clock_divisor clk_wiz_0_inst(
                  .clk(clk),
                  .clk1(clk_25MHz),
                  .clk22(clk_22)
              );

game ga(
         .level(level),
         .clk(clk),
         .rst(rst),
         .h_cnt(h_cnt),
         .v_cnt(v_cnt),
         .pixel_addr(pixel_addr),
         .been_ready(been_ready),
         .key_down(key_down),
         .last_change(last_change),
         .vgaRed(vgaRed),
         .vgaGreen(vgaGreen),
         .vgaBlue(vgaBlue),
         .valid(valid),
         .pixel(pixel),
         .pixel_back(pixel_back),
         .valid_rotate_led(led)
     );

blk_mem_gen_0 blk_mem_gen_0_inst(
                  .clka(clk_25MHz),
                  .wea(0),
                  .addra(((h_cnt>>1)+320*(v_cnt>>1))% 76800),
                  .dina(data[11:0]),
                  .douta(pixel_back)
              );


// blk_mem_gen_1 blk_mem_gen_1_inst(
//         .clka(clk_25MHz),
//         .wea(0),
//         .addra(((h_cnt>>1)+320*(v_cnt>>1))% 76800),
//         .dina(data[11:0]),
//         .douta(pixel)
//     );

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

MusicMain music (
              .clk(clk),
              .reset(rst),
              .level(level),
              .pmod_1(pmod_1),
              .pmod_2(pmod_2),
              .pmod_4(pmod_4)
          );
endmodule
