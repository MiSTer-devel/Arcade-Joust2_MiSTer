//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [48:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,
	output        HDMI_FREEZE,

`ifdef MISTER_FB
	// Use framebuffer in DDRAM (USE_FB=1 in qsf)
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
	//Secondary SDRAM
	//Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);

///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;

assign VGA_F1 = 0;
assign VGA_SCALER  = 0;
assign HDMI_FREEZE = 0;
assign FB_FORCE_BLANK = 0;

assign AUDIO_MIX = 0;

assign LED_DISK  = 0;
assign LED_POWER = 0;
assign BUTTONS   = 0;

//////////////////////////////////////////////////////////////////

assign LED_USER  = ioctl_download;

wire [1:0] ar = status[9:8];

assign VIDEO_ARX = (!ar) ? (status[2] ? 9'd282 : 9'd241) : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? (status[2] ? 9'd241 : 9'd282) : 12'd0;

// Status Bit Map:
//              Upper                          Lower
// 0         1         2         3          4         5         6
// 01234567890123456789012345678901 23456789012345678901234567890123
// 0123456789ABCDEFGHIJKLMNOPQRSTUV 0123456789ABCDEFGHIJKLMNOPQRSTUV
// X XXXX  XXXXX

`include "build_id.v" 
localparam CONF_STR = {
	"A.JOUST2;;",
	"-;",
	"H0O89,Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"H0O2,Orientation,Vert,Horz;",
	"O35,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"-;",
	"OA,Advance,Off,On;",
	"OB,Auto Up,Off,On;",
	"OC,High Score Reset,Off,On;",
	"-;",
	"R0,Reset;",
	"J1,Flap,Transform(Start),Coin;",
	"jn,A,Start,Select,R,L;",
	"V,v",`BUILD_DATE 
};

wire        forced_scandoubler;
wire        direct_video;
wire        video_rotated;

wire        ioctl_download;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [ 7:0] ioctl_dout;
wire [15:0] ioctl_index;

wire [ 1:0] buttons;
wire [31:0] status;
wire [10:0] ps2_key;

wire [15:0] joy1,joy2;
wire [15:0] joy = joy1 | joy2;

wire [21:0] gamma_bus;

hps_io #(.CONF_STR(CONF_STR)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),

	.buttons(buttons),
	.status(status),
	.status_menumask({direct_video}),

	.forced_scandoubler(forced_scandoubler),
	.video_rotated(video_rotated),
	.gamma_bus(gamma_bus),
	.direct_video(direct_video),

	.ioctl_download(ioctl_download),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_index(ioctl_index),

	.joystick_0(joy1),
	.joystick_1(joy2)
);

///////////////////////   CLOCKS   ///////////////////////////////

wire   clk_sys;
wire   pll_locked;
wire   clk_48,clk_12;
assign clk_sys = clk_12;

pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_48),
	.outclk_1(clk_12),
	.locked(pll_locked)
);

wire reset = RESET | status[0] | buttons[1] | ioctl_download;

//////////////////////////////////////////////////////////////////

wire m_left_1  = joy1[1];
wire m_right_1 = joy1[0];
wire m_flap_1  = joy1[4];
wire m_start1  = joy1[5];

wire m_left_2  = joy2[1];
wire m_right_2 = joy2[0];
wire m_flap_2  = joy2[4];
wire m_start2  = joy2[5];

wire m_coin    = joy[6];

// DISPLAY
wire hblank, vblank;
wire hs, vs;

wire [ 3:0] r,g,b,intensity;
wire [ 7:0] ri,gi,bi;

wire [7:0] color_lut[256] = '{
    8'd19, 8'd21, 8'd23,  8'd25,  8'd26,  8'd29,  8'd32,  8'd35,  8'd38,  8'd43,  8'd49,  8'd56,  8'd65,  8'd76,  8'd96,  8'd108,
    8'd21, 8'd22, 8'd24,  8'd26,  8'd28,  8'd30,  8'd34,  8'd37,  8'd40,  8'd45,  8'd52,  8'd59,  8'd68,  8'd80,  8'd101, 8'd114,
    8'd22, 8'd24, 8'd26,  8'd28,  8'd30,  8'd33,  8'd36,  8'd39,  8'd43,  8'd48,  8'd55,  8'd63,  8'd73,  8'd86,  8'd107, 8'd121,
    8'd24, 8'd25, 8'd27,  8'd29,  8'd32,  8'd35,  8'd38,  8'd42,  8'd46,  8'd52,  8'd59,  8'd67,  8'd77,  8'd91,  8'd114, 8'd129,
    8'd25, 8'd27, 8'd29,  8'd31,  8'd34,  8'd37,  8'd40,  8'd45,  8'd48,  8'd54,  8'd62,  8'd71,  8'd81,  8'd96,  8'd121, 8'd137,
    8'd27, 8'd28, 8'd31,  8'd34,  8'd36,  8'd39,  8'd44,  8'd48,  8'd52,  8'd58,  8'd66,  8'd76,  8'd87,  8'd103, 8'd129, 8'd146,
    8'd29, 8'd31, 8'd34,  8'd36,  8'd39,  8'd43,  8'd47,  8'd52,  8'd56,  8'd63,  8'd72,  8'd82,  8'd94,  8'd111, 8'd140, 8'd158,
    8'd32, 8'd34, 8'd37,  8'd39,  8'd43,  8'd46,  8'd51,  8'd56,  8'd61,  8'd68,  8'd78,  8'd89,  8'd102, 8'd120, 8'd151, 8'd171,
    8'd32, 8'd35, 8'd38,  8'd41,  8'd44,  8'd48,  8'd53,  8'd59,  8'd64,  8'd72,  8'd83,  8'd94,  8'd109, 8'd129, 8'd161, 8'd182,
    8'd36, 8'd38, 8'd42,  8'd45,  8'd48,  8'd53,  8'd59,  8'd65,  8'd70,  8'd79,  8'd90,  8'd104, 8'd119, 8'd141, 8'd177, 8'd201,
    8'd40, 8'd43, 8'd46,  8'd50,  8'd54,  8'd59,  8'd65,  8'd72,  8'd79,  8'd88,  8'd101, 8'd115, 8'd133, 8'd157, 8'd198, 8'd224,
    8'd45, 8'd48, 8'd52,  8'd57,  8'd61,  8'd66,  8'd74,  8'd81,  8'd88,  8'd98,  8'd113, 8'd129, 8'd149, 8'd176, 8'd221, 8'd249,
    8'd50, 8'd54, 8'd58,  8'd64,  8'd68,  8'd75,  8'd83,  8'd91,  8'd99,  8'd111, 8'd128, 8'd146, 8'd169, 8'd200, 8'd249, 8'd253,
    8'd58, 8'd63, 8'd68,  8'd74,  8'd79,  8'd87,  8'd96,  8'd106, 8'd116, 8'd129, 8'd148, 8'd169, 8'd195, 8'd231, 8'd253, 8'd254,
    8'd71, 8'd76, 8'd83,  8'd89,  8'd96,  8'd105, 8'd116, 8'd128, 8'd139, 8'd156, 8'd179, 8'd205, 8'd236, 8'd252, 8'd254, 8'd254,
    8'd91, 8'd97, 8'd105, 8'd114, 8'd123, 8'd133, 8'd147, 8'd161, 8'd176, 8'd196, 8'd223, 8'd249, 8'd252, 8'd254, 8'd254, 8'd255
};

always @(posedge clk_48) begin : colorPalette
    ri = ~| intensity ? 8'd0 : color_lut[{r, intensity}];
    gi = ~| intensity ? 8'd0 : color_lut[{g, intensity}];
    bi = ~| intensity ? 8'd0 : color_lut[{b, intensity}];
end

reg ce_pix;
always @(posedge clk_48) begin
	reg [2:0] div;
	div <= div + 1'd1;
	ce_pix <= !div;
end

wire no_rotate  = status[2] | direct_video ;
wire rotate_ccw = 1;
wire flip       = 0;

screen_rotate screen_rotate (.*);

arcade_video #(313,24,1) arcade_video
(
	.*,

	.clk_video(clk_48),

	.RGB_in({ri[7:0],gi[7:0],bi[7:0]}),
	.HBlank(hblank),
	.VBlank(vblank),
	.HSync(~hs),
	.VSync(~vs),

	.fx(status[5:3])
);


wire [7:0] audio;
assign AUDIO_L = {audio, 6'd0};
assign AUDIO_R = AUDIO_L;
assign AUDIO_S = 0;

williams2 williams2
(
	.clock_12(clk_12),
	.reset(reset),

	.dn_addr(ioctl_addr[17:0]),
	.dn_data(ioctl_dout),
	.dn_wr(ioctl_wr && ioctl_index==0),

	.video_r(r),
	.video_g(g),
	.video_b(b),
	.video_i(intensity),
	.video_hblank(hblank),
	.video_vblank(vblank),
	.video_hs(hs),
	.video_vs(vs),

	.audio_out(audio),

	.btn_auto_up(status[10]),
	.btn_advance(status[11]),
	.btn_high_score_reset(status[12]),

	.btn_coin(m_coin),
	.btn_start_1(m_start1),
	.btn_start_2(m_start2),

	.btn_left_1(m_left_1),
	.btn_right_1(m_right_1),
	.btn_trigger1_1(m_flap_1),
	
	.btn_left_2(m_left_2),
	.btn_right_2(m_right_2),
	.btn_trigger1_2(m_flap_2),

	.sw_cocktail_table(), // not implemented yet by dar
	.seven_seg(), // [7:0] 

	.dbg_out() // [31:0]
);

endmodule
