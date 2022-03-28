# [Arcade: Joust 2](https://en.wikipedia.org/wiki/Joust_2:_Survival_of_the_Fittest) for [MiSTer](https://mister-devel.github.io/MkDocs_MiSTer/)

![Joust 2 Logo](Joust2Logo.png)

Original core developed by [darfpga](https://github.com/darfpga)

Ported to MiSTer by [birdybro](https://github.com/birdybro)

## Description

This is a simulation model of the **Joust 2: Survival of the Fittest** hardware. This is currently an early work in progress as a port.

Original source is located in `doc/`

## Controls

![Joust 2 Controls](controls.jpg)

| Name  | Description         |
| ----- | ------------------- |
| Flap  | You flap your wings |
| Left  | You go left         |
| Right | You go right        |
| Coin  | Put in a coin       |

There is a 1P Start and a 2P Start. These are also called "Transform" in-game.

## OSD Options

Joust 2 had a peculiar system of DIPs. See the manual in `doc/` for the original source of the information.

When you press the "Advance" button in the OSD, this enables you to access the bookkeeping totals by then pressing "Auto Up" in the OSD. Currently the data in here is not saved to the MiSTer but that may come at a later time. 

If you want to change any options, then press "Auto Up" again to see the Game Adjustments menu. Here you use Player 1 right and left to move to whatever option you want to change and then use the Player 2 right and left inputs to modify the desired setting.

If you press "Advance" again, it will return to it's original state, but "Auto Up" now will cycle through various test programs that the arcade board used to have.

High Score reset is another internal button, and it makes the game pause for a second until the high score resets.

## Status

* Both revisions of Joust 2: Survival of the Fittest load and play fine.
* Regular sound effects play fine.
* 2 Player controls work.
* Sometimes audio bugs out, not sure why yet.

## To-Do

* No Speech synthesis or Music yet. Dar is working on it.
* Video_i not implemented.
* Pause not implemented.
* HiScore saving not implemented yet.
* MiSTer DIP system not implemented yet (DIPS are defined away as CPU behavior currently in the PIA)
* Adjust video output for HDMI, it is up and to the right a line or two.

## ROM Files Instructions

ROMs are not included! In order to use this arcade core, you will need to provide the correct ROM file yourself.

To simplify the process .mra files are provided in the releases folder, that specify the required ROMs with their checksums. The ROMs .zip filename refers to the corresponding file from the MAME project.

Please refer to [https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms-and-MRA-files](https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms-and-MRA-files) for information on how to setup and use the environment.

Quick reference for folders and file placement:

```
/_Arcade/<game name>.mra  
/_Arcade/cores/<game rbf>.rbf  
/_Arcade/mame/<mame rom>.zip  
/_Arcade/hbmame/<hbmame rom>.zip  
```

### Original readme from darfpga

```
-------------------------------------------------------------------------------
-- Joust2 by Dar (darfpga@aol.fr) (15 March 2022)
-- http://darfpga.blogspot.fr
-- https://sourceforge.net/projects/darfpga/files
-- github.com/darfpga
--
--  Terasic board MAX10 DE10 Lite
-------------------------------------------------------------------------------
-- gen_ram.vhd & io_ps2_keyboard
-------------------------------- 
-- Copyright 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
-------------------------------------------------------------------------------
-- cpu09l - Version : 0128
-- Synthesizable 6809 instruction compatible VHDL CPU core
-- Copyright (C) 2003 - 2010 John Kent
-------------------------------------------------------------------------------
-- cpu68 - Version 9th Jan 2004 0.8
-- 6800/01 compatible CPU core 
-- GNU public license - December 2002 : John E. Kent
-------------------------------------------------------------------------------
-- Educational use only
-- Do not redistribute synthetized file with roms
-- Do not redistribute roms whatever the form
-- Use at your own risk
-------------------------------------------------------------------------------
--  Video 15KHz is OK, 
--
--  This is not VGA, you have to use a TV set with SCART plug
--
--    SCART(TV) pin  - signal -  VGA(DE10) pin
--               15  -  red   -  1          
--               11  - green  -  2
--                7  -  blue  -  3  
--           5,9,13  -  gnd   -  5,6,7
--   (comp. sync)20  - csync  -  13 (HS)   
--  (fast commut)16  - commut -  14 (VS)
--            17,18  -  gnd   -  8,10 
--
-------------------------------------------------------------------------------
-- Version 0.0 -- 05/03/2022 -- 
--	initial version 
-------------------------------------------------------------------------------
--
-- Main features :
--  PS2 keyboard input @gpio pins 35/34 (beware voltage translation/protection)
--  Audio pwm output   @gpio pins 1/3 (beware voltage translation/protection)
--
-- Uses 1 pll for 12MHz and 120MHz generation from 50MHz
--
-- Board key :
--   0 : reset game
--
-- Keyboard players inputs :
--
--   F3 : Add coin
--   F2 : Start 2 players
--   F1 : Start 1 player
--   SPACE       : Flap 
--   RIGHT arrow : Move right P1
--   LEFT  arrow : Move left  P1
--   UP    arrow : Move right P2
--   DOWN  arrow : Move left  P2
--   CTRL        : 
--   W(Z)        : 
--
-- Keyboard Service inputs French(english) :
--
--   A(Q) : advance
--   U(U) : auto/up (!manual/down)
--   H(H) : high score reset
--
-- To enter service mode press 'advance' key while in game over screen
-- Enter service mode to tune game parameters (difficulty ...)
-- Tuning are lost at power OFF, for permanent tuning edit/set parameters
--   within joust2_cmos_ram.vhd and recompile.
--
-------------------------------------------------------------------------------
-- Use make_joust2_proms.bat to build vhd file and bin from binaries
-- Load sdram with external rom bank -> use sdram_loader_de10_lite.sof + key(0)
-------------------------------------------------------------------------------
-- Program sdram content with this joust2 rom bank loader before 
-- programming joust2 game core :
--
-- 1) program DE10_lite with joust2 sdram loader
-- 2) press key(0) at least once (digit blinks during programming)
-- 3) program DE10_lite with joust2 core without switching DE10_lite OFF
-------------------------------------------------------------------------------
-- Used ROMs by make_joust2_proms.bat

> joust2_prog1
   cpu_2732_ic55_rom2_rev1.4c CRC(08b0d5bd)

> joust2_prog2
   cpu_2732_ic9_rom3_rev2.4d  CRC(951175ce)
   cpu_2732_ic10_rom4_rev2.4f CRC(ba6e0f6c)

> joust2_bank_a
   cpu_2732_ic26_rom19_rev1.10j CRC(4ef5e805)
   cpu_2732_ic24_rom17_rev1.10h CRC(4861f063)
   cpu_2732_ic22_rom15_rev1.9j  CRC(421aafa8)
   cpu_2732_ic20_rom13_rev1.9h  CRC(3432ff55)

> joust2_bank_b
   cpu_2732_ic25_rom18_rev1.10i CRC(47580af5)
   cpu_2732_ic23_rom16_rev1.10g CRC(869b5942)
   cpu_2732_ic21_rom14_rev1.9i  CRC(0bbd867c)
   cpu_2732_ic19_rom12_rev1.9g  CRC(b9221ed1)   

> joust2_bank_c
   cpu_2732_ic18_rom11_rev1.8j CRC(9dc986f9)
   cpu_2732_ic16_rom9_rev2.8h  CRC(56e2b550)
   cpu_2732_ic14_rom7_rev2.6j  CRC(f3bce576)
   cpu_2732_ic12_rom5_rev2.6h  CRC(5f8b4919)

> joust2_bank_d
   cpu_2732_ic17_rom10_rev1.8i CRC(3e01b597)
   cpu_2732_ic15_rom8_rev1.8g  CRC(ff26fb29)
   cpu_2732_ic13_rom6_rev2.6i  CRC(5f107db5)

> joust2_sound
   cpu_2764_ic8_rom1_rev1.0f   CRC(84517c3c)

> joust2_graph1
   vid_27128_ic57_rom20_rev1.8f CRC(572c6b01)

> joust2_graph2
   vid_27128_ic58_rom21_rev1.9f CRC(aa94bf05)

> joust2_graph3
   vid_27128_ic41_rom22_rev1.9d CRC(c41e3daa)

> joust2_decoder
   vid_82s147a_ic60_a-5282-10292.12f CRC(0ea3f7fb)

-------------------------------------------------------------------------------
-- Misc. info
-------------------------------------------------------------------------------
-- Main bus access
--  > Main address bus and data bus by CPU 6809
--  > Main address bus and data bus by DMA (blitter) while CPU is halted.
--
-- CPU and DMA can read/write anywhere from/to entire 64K address space
-- including video ram, color palette, tile map, cmos_ram, peripherals, roms,
-- switched rom banks, ...

--
-- Page register control allows to select misc. banked access (rom, ram). 
-------------------------------------------------------------------------------
-- Video ram : 3 banks of 16Kx8 (dram with ras/cas)
--  > interleaved bank access by CPU, 8bits read/write
--  > interleaved bank access by DMA, 8bits read, 2x4bits independent write
--  > simultaneous (3 banks) access by video scanner, 24bits at once
-- 
-- In original hardware, every 1us there is 1 access to video ram for CPU/DMA
-- and 1 access for video scanner. Thus DMA read/write cycle required 2us when
-- reading source is video ram. DMA read/write cycle required only 1us when
-- reading source is not video ram.
--
-- Higher part of video ram is not displayed on screen and is used as working
-- ram by CPU including stack (SP).
-------------------------------------------------------------------------------
-- Foreground (bitmap - video ram)
--  > 24 bits / 1us => 6 horizontal pixels of 4bits (16 colors)
--  > 6 bits register (64 color banks)
-------------------------------------------------------------------------------
-- Background (tile map : tile is 24x16 pixels)
--
--  > 16 horizontal tiles of 4x6 pixels, 16 vertical tiles of 16 pixels.
--  > map ram 2048x8
--      in  : 7 bits horizontal (4 bits + scroll) + 4 bits vertical
--      out : 128 possible tiles + flip control
--
--  > Graphics 3x8Kx8 roms
--      in  : 2 bits horizontal + 4 bits vertical + 7 bits tile code 
--      out : 24 bits = 6 pixels x 4 bits
--
--  > 24 bits / 1us => 6 horizontal pixels of 4bits (16 colors)
--  > 6 bits register (64 color banks)
-------------------------------------------------------------------------------
-- Palette 1024 colors x 16 bits
--  > in  10 bits from foreground or background data
--  > out 4 bits red, 4 bits green, 4 bits blue, 4 bits intensity 
-------------------------------------------------------------------------------
```
