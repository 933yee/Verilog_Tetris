# FPGA Tetris

A complete Tetris game implemented in Verilog for the Digilent Basys 3 FPGA board. The design renders a 640×480 VGA interface, accepts a PS/2 keyboard, and generates level-dependent music through a Pmod audio output.

## Demo

### Start screen

![Tetris start screen](https://user-images.githubusercontent.com/92087014/221396751-4179d3b0-5151-40e2-a11b-81eff5c4a3e8.jpg)

### Gameplay

![Tetris gameplay](https://user-images.githubusercontent.com/92087014/221396753-ac8d468c-8ee4-4e4e-b1b2-635b08e8152c.jpg)

## Features

- Seven tetromino types with pseudo-random generation.
- Movement and rotation legality checks against walls and settled blocks.
- Hard drop, soft drop, hold, and ghost-piece preview.
- Full-line detection, clearing, board compaction, score, and eight speed levels.
- Start/game-over UI rendered directly by the VGA logic.
- PS/2 make/break scan-code decoding.
- Level-dependent background music with PWM audio output.
- A rotation-valid debug LED.

## Controls

| Key | Action |
| --- | --- |
| Enter | Start the game |
| Left / Right | Move the active piece |
| Down | Soft drop |
| Up | Rotate |
| Space | Hard drop |
| C | Hold/swap the current piece |
| Esc | Leave/reset the current game state |

The Basys 3 center button is mapped to the top-level reset input.

## Architecture

~~~text
PS/2 keyboard
     |
KeyboardDecoder
     |
     v
game FSM + board memory ---- rand_gen
     |       |                 |
     |       +-- validMove / ValidRotate
     |       +-- shadow_gen
     |       +-- checklines
     |
     +----------------------> VGA pixel generator
     |                             |
     |                       vga_controller
     |
     +-- level ------------> MusicMain -> PWM -> Pmod
~~~

The game module owns the board state, current/next/held blocks, score, level, piece coordinates, and drawing logic. Dedicated combinational modules evaluate movement, rotation, shadows, and complete rows. Clock dividers derive the 25 MHz VGA clock and gameplay/music timing signals from the board's 100 MHz oscillator.

## Repository structure

| File/module | Purpose |
| --- | --- |
| Tetris/top.v | Top-level integration |
| Tetris/game.v | Game state, board update, controls, and UI drawing |
| Tetris/validMove.v / validRotate.v | Collision and rotation checks |
| Tetris/checklines.v | Complete-row detection |
| Tetris/shadow_gen.v | Ghost-piece location |
| Tetris/rand_gen.v | Tetromino selection |
| Tetris/KeyboardDecoder.v | PS/2 keyboard interface |
| Tetris/vga.v | 640×480 VGA timing |
| Tetris/Music*.v and PWM.v | Level music and audio output |
| Tetris/bg.coe | Start/background image for block memory |
| Tetris/move.xdc | Basys 3 pin constraints |

## Build for Basys 3

1. Create an RTL project in Xilinx Vivado targeting the Basys 3 device (XC7A35T-1CPG236C).
2. Add the Verilog sources under Tetris and set TOP as the top module.
3. Add Tetris/move.xdc as the constraints file.
4. Create a Block Memory Generator IP named blk_mem_gen_0 with a 12-bit output and at least 76,800 words, then initialize it with Tetris/bg.coe. The top module samples the 320×240 image and scales it to 640×480.
5. Generate the IP output products, run synthesis/implementation, and generate the bitstream.
6. Connect a VGA display and PS/2 keyboard. Connect the expected audio module to Pmod JB if music output is desired.
7. Program the board and press Enter on the keyboard.

## I/O

- VGA: 4 bits each of red, green, and blue plus horizontal/vertical sync.
- Keyboard: PS2_DATA and PS2_CLK.
- Audio: pmod_1 (AIN), pmod_2 (GAIN), and pmod_4 (active-low shutdown).
- Debug: one LED indicating rotation validity.

## Notes

- The Vivado project and generated Block Memory IP are not committed; they must be recreated as described above.
- The constraints file is based on the Basys 3 rev B master XDC and contains the board pin mapping used by the project.
