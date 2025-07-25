# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a MiSTer FPGA implementation of the arcade game "Joust 2: Survival of the Fittest" for the MiSTer platform. The project is a hardware simulation/emulation of the original Williams arcade hardware from the 1980s.

## Build System and Development Commands

This project uses Intel Quartus Prime (version 17.0) for FPGA synthesis and place-and-route:

- **Primary project file**: `Arcade-Joust2.qpf` (Quartus Project File)
- **Settings file**: `Arcade-Joust2.qsf` (Quartus Settings File) 
- **Main source file**: `Arcade-Joust2.sv` (SystemVerilog top-level module)
- **File list**: `files.qip` (Quartus IP file listing all source files)

### Build Commands
- Build the project using Quartus Prime GUI or command-line tools
- Clean build artifacts: `clean.bat` (Windows batch file that removes temporary files and build directories)

## Architecture and Core Components

### Top-Level Architecture
- **Main module**: `emu` in `Arcade-Joust2.sv` - MiSTer framework integration
- **Core logic**: `williams2` module in `rtl/williams2.vhd` - Main arcade hardware implementation

### Key Directories
- `rtl/` - Core hardware description files (VHDL/Verilog)
- `sys/` - MiSTer system files and framework components  
- `doc/` - Documentation, ROM information, and reference materials
- `releases/` - Binary releases (.rbf files and .mra arcade definitions)

### Core Components
- **CPU**: 6809 processor implementation (`rtl/cpu09l_128.vhd`)
- **Sound**: Williams CVSD sound board (`rtl/williams_cvsd_board.vhd`, `rtl/joust2_sound_board.vhd`)
- **Audio synthesis**: JT51 YM2151 implementation (`rtl/jt51/`)
- **Video**: Custom Williams video hardware with 4-bit RGB + intensity
- **Input**: PIA 6821 for joystick/button handling (`rtl/pia6821.vhd`)
- **Memory**: CMOS RAM for settings (`rtl/joust2_cmos_ram.vhd`)

### Hardware Specifics
- Target FPGA: Cyclone V (5CSEBA6U23I7)
- Clock domains: 50MHz input, 48MHz/12MHz generated via PLL
- Video output: 15kHz standard with scandoubler support
- ROM loading: Via MiSTer's HPS interface during startup

### File Organization
- VHDL files use `.vhd` extension for hardware description
- SystemVerilog uses `.sv` extension  
- Quartus-specific files: `.qpf`, `.qsf`, `.qip`, `.sdc`
- Build system uses Tcl scripts in `sys/` directory

## Development Notes

- The project implements the original Williams hardware behavior including the unique DIP switch system
- ROM files are loaded via `.mra` (MRA = MiSTer Rom Alternative) files
- Video timing matches original 15kHz arcade monitors
- Sound system includes both sound effects and music synthesis (though speech synthesis is not yet implemented)
- The codebase maintains separation between MiSTer framework code (`sys/`) and core arcade logic (`rtl/`)

## Known Limitations
- Speech synthesis not implemented
- Pause functionality not implemented  
- HiScore saving not implemented
- MiSTer DIP system not fully integrated (handled via CPU behavior)