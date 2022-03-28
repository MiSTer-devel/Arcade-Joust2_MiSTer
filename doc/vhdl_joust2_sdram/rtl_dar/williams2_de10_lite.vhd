---------------------------------------------------------------------------------
-- DE10_lite Top level for Joust2 by Dar (darfpga@aol.fr) (05/02/2022)
-- http://darfpga.blogspot.fr
-- https://sourceforge.net/projects/darfpga/files
-- github.com/darfpga
---------------------------------------------------------------------------------
-- Educational use only
-- Do not redistribute synthetized file with roms
-- Do not redistribute roms whatever the form
-- Use at your own risk
---------------------------------------------------------------------------------
-- Use williams2_de10_lite.sdc to compile (Timequest constraints)
---------------------------------------------------------------------------------
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
--   SPACE       : Fire  
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
--   To enter service mode press 'advance' key while in game over screen
--   Enter service mode to tune game parameters (difficulty ...)
--   Tuning are lost at power OFF, for permanent tuning edit/set parameters
--     within joust2_cmos_ram.vhd and recompile.
--
---------------------------------------------------------------------------------
--  Use make_joust2_proms.bat to build vhd file and bin from binaries
--  Load sdram with external rom bank -> use sdram_loader_de10_lite.sof + key(0)
---------------------------------------------------------------------------------
--  Other details : see williams2.vhd
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
--use work.usb_report_pkg.all;

entity williams2_de10_lite is
port(
 max10_clk1_50  : in std_logic;
-- max10_clk2_50  : in std_logic;
-- adc_clk_10     : in std_logic;
-- ledr           : out std_logic_vector(9 downto 0);
 key            : in std_logic_vector(1 downto 0);
 sw             : in std_logic_vector(9 downto 0);

 dram_ba    : out std_logic_vector(1 downto 0);
 dram_ldqm  : out std_logic;
 dram_udqm  : out std_logic;
 dram_ras_n : out std_logic;
 dram_cas_n : out std_logic;
 dram_cke   : out std_logic;
 dram_clk   : out std_logic;
 dram_we_n  : out std_logic;
 dram_cs_n  : out std_logic;
 dram_dq    : inout std_logic_vector(15 downto 0);
 dram_addr  : out std_logic_vector(12 downto 0);

 hex0 : out std_logic_vector(7 downto 0);
 hex1 : out std_logic_vector(7 downto 0);
 hex2 : out std_logic_vector(7 downto 0);
 hex3 : out std_logic_vector(7 downto 0);
 hex4 : out std_logic_vector(7 downto 0);
 hex5 : out std_logic_vector(7 downto 0);

 vga_r     : out std_logic_vector(3 downto 0);
 vga_g     : out std_logic_vector(3 downto 0);
 vga_b     : out std_logic_vector(3 downto 0);
 vga_hs    : out std_logic;
 vga_vs    : out std_logic;
 
-- gsensor_cs_n : out   std_logic;
-- gsensor_int  : in    std_logic_vector(2 downto 0); 
-- gsensor_sdi  : inout std_logic;
-- gsensor_sdo  : inout std_logic;
-- gsensor_sclk : out   std_logic;

-- arduino_io      : inout std_logic_vector(15 downto 0); 
-- arduino_reset_n : inout std_logic;
 
 gpio          : inout std_logic_vector(35 downto 0)
);
end williams2_de10_lite;

architecture struct of williams2_de10_lite is

component sdram is
port (

 sd_data : inout std_logic_vector(15 downto 0);
 sd_addr : out   std_logic_vector(12 downto 0);
 sd_dqm  : out   std_logic_vector(1 downto 0);
 sd_ba   : out   std_logic_vector(1 downto 0);
 sd_cs   : out   std_logic;
 sd_we   : out   std_logic;
 sd_ras  : out   std_logic;
 sd_cas  : out   std_logic;

 init    : in std_logic;
 clk     : in std_logic;
	
 addr    : in std_logic_vector(24 downto 0);
 
 we      : in std_logic;
 di      : in std_logic_vector(7 downto 0);
 
 rd      : in std_logic;	
 sm_cycle: out std_logic_vector( 4 downto 0)
 
); end component sdram;

 signal pll_locked: std_logic;
 signal clock_120       : std_logic;
 signal clock_120_sdram : std_logic; -- (-2ns w.r.t clock_120)
 signal clock_40  : std_logic;
 signal clock_12   : std_logic;
 
 signal reset     : std_logic;
 
 signal timer     : std_logic_vector( 7 downto 0);
 signal rom_rd    : std_logic;
 signal rom_addr  : std_logic_vector(16 downto 0);
 signal rom_data  : std_logic_vector(15 downto 0);
 signal rom_do    : std_logic_vector( 7 downto 0);
 signal rom_cycle : std_logic_vector( 4 downto 0);
 signal dram_dqm  : std_logic_vector( 1 downto 0);
 signal sdram_data: std_logic_vector(15 downto 0);

-- signal max3421e_clk : std_logic;
 
 signal r         : std_logic_vector(3 downto 0);
 signal g         : std_logic_vector(3 downto 0);
 signal b         : std_logic_vector(3 downto 0);
 signal intensity : std_logic_vector(3 downto 0);
 signal ri        : std_logic_vector(7 downto 0);
 signal gi        : std_logic_vector(7 downto 0);
 signal bi        : std_logic_vector(7 downto 0);
 signal csync     : std_logic;
 signal blankn    : std_logic;
 
 signal audio           : std_logic_vector( 7 downto 0);
 signal pwm_accumulator : std_logic_vector(12 downto 0);

 alias reset_n         : std_logic is key(0);
 alias ps2_clk         : std_logic is gpio(35); --gpio(0);
 alias ps2_dat         : std_logic is gpio(34); --gpio(1);
 alias pwm_audio_out_l : std_logic is gpio(1);  --gpio(2);
 alias pwm_audio_out_r : std_logic is gpio(3);  --gpio(3);
 
 signal kbd_intr      : std_logic;
 signal kbd_scancode  : std_logic_vector(7 downto 0);
 signal joyHBCPPFRLDU : std_logic_vector(9 downto 0);
 signal keys_HUA      : std_logic_vector(2 downto 0);

-- signal start : std_logic := '0';
-- signal usb_report : usb_report_t;
-- signal new_usb_report : std_logic := '0';
 
 signal seven_seg : std_logic_vector( 7 downto 0);

signal dbg_out : std_logic_vector(31 downto 0);


begin

reset <= not reset_n;

-- tv15Khz_mode <= sw();

--arduino_io not used pins
--arduino_io(7) <= '1'; -- to usb host shield max3421e RESET
--arduino_io(8) <= 'Z'; -- from usb host shield max3421e GPX
--arduino_io(9) <= 'Z'; -- from usb host shield max3421e INT
--arduino_io(13) <= 'Z'; -- not used
--arduino_io(14) <= 'Z'; -- not used

clocks : entity work.max10_pll_120M_sdram
port map(
 inclk0 => max10_clk1_50,
 c0 => clock_120,         -- 120MHz 
 c1 => clock_120_sdram,   -- 120MHz -2ns for sdram
 c2 => clock_40,          -- N.U.
 c3 => clock_12,          -- 12MHz core clock
 locked => pll_locked
);

dram_ldqm <= dram_dqm(0); 
dram_udqm <= dram_dqm(1);
dram_cke  <= '1';
dram_clk  <= clock_120_sdram;

sdram_if : sdram
port map(
   -- sdram interface
	sd_data => dram_dq,    -- 16 bit bidirectional data bus
	sd_addr => dram_addr,  -- 13 bit multiplexed address bus
	sd_dqm  => dram_dqm,   -- two byte masks
	sd_ba   => dram_ba,    -- two banks
	sd_cs   => dram_cs_n,  -- a single chip select
	sd_we   => dram_we_n,  -- write enable
	sd_ras  => dram_ras_n, -- row address select
	sd_cas  => dram_cas_n, -- columns address select

	-- cpu/chipset interface
	init     => not pll_locked, -- init signal after FPGA config to initialize RAM
	clk      => clock_120,	    -- sdram is accessed at up to 128MHz
	
	addr     => "00000000" & rom_addr, -- 25 bit byte address
	
	we       => '0',           -- requests write
	di       => x"FF",         -- data input
	
	rd       => rom_rd,        -- requests data
	sm_cycle => rom_cycle      -- state machine cycle
);

process (clock_120)
begin
	if falling_edge(clock_120) then
		sdram_data <= dram_dq;
		if rom_cycle = 8 then
			rom_data <= sdram_data;
			if rom_addr(0) = '0' then
				rom_do <= sdram_data(15 downto 8);
			else
				rom_do <= sdram_data( 7 downto 0);
			end if;
		end if;
	end if;
end process;

-- dbg read sdram
--process (clock_40)
--begin
--	if reset = '1' then 
--		timer    <= (others => '0');
--		rom_rd <= '0';
--	else
--		if rising_edge(clock_40) then
--			--rom_addr <= sw(9 downto 8)&"0000000" & sw(7 downto 0); 
--			if timer = x"0F" then 				
--				timer <= (others => '0');
--			else
--				timer <= timer +1;			
--			end if;		
--			if timer > 2 then rom_rd <= '1'; end if;
--			if timer > 6 then rom_rd <= '0'; end if;			
--		end if;
--	end if;
--end process;

-- Williams2

williams2 : entity work.williams2
port map(
 clock_12     => clock_12,
 reset        => reset,
 
 rom_addr => rom_addr,
 rom_do   => rom_do,
 rom_rd   => rom_rd,
 
-- tv15Khz_mode => tv15Khz_mode,
 video_r      => r,
 video_g      => g,
 video_b      => b,
 video_i      => intensity,
 video_csync  => csync,
 video_blankn => blankn,
 video_hs     => open, --hsync, -- not tested
 video_vs     => open, --vsync, -- not tested
 audio_out    => audio,

 btn_advance          => keys_HUA(0),
 btn_auto_up          => keys_HUA(1),
 btn_high_score_reset => keys_HUA(2),
 btn_coin             => joyHBCPPFRLDU(7),
 btn_start_1          => joyHBCPPFRLDU(5),
 btn_start_2          => joyHBCPPFRLDU(6),
  
 btn_left_1     => joyHBCPPFRLDU(2),
 btn_right_1    => joyHBCPPFRLDU(3),
 btn_trigger1_1 => joyHBCPPFRLDU(4),

 btn_left_2     => joyHBCPPFRLDU(0),
 btn_right_2    => joyHBCPPFRLDU(1),
 btn_trigger1_2 => joyHBCPPFRLDU(4),

 sw_coktail_table  => '0', -- 1 for coktail table, 0 for upright cabinet (todo)
 
 seven_seg =>  seven_seg, 

 dbg_out => dbg_out

);

ri <= r*intensity;
gi <= g*intensity;
bi <= b*intensity;

vga_r <= ri(7 downto 4) when blankn = '1' else "0000";
vga_g <= gi(7 downto 4) when blankn = '1' else "0000";
vga_b <= bi(7 downto 4) when blankn = '1' else "0000";

-- synchro composite/ synchro horizontale
vga_hs <= csync;
-- vga_hs <= csync when tv15Khz_mode = '1' else hsync;
-- commutation rapide / synchro verticale
vga_vs <= '1';
-- vga_vs <= '1'   when tv15Khz_mode = '1' else vsync;

--sound_string <= "00" & audio & "000" & "00" & audio & "000";

-- get scancode from keyboard
--process (reset, clock_24)
--begin
--	if reset='1' then
--		clock_12  <= '0';
--	else 
--		if rising_edge(clock_24) then
--				clock_12  <= not clock_12;
--		end if;
--	end if;
--end process;


keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_12, -- use same clock as williams2 core
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);

-- translate scancode to joystick
joystick : entity work.kbd_joystick
port map (
  clk          => clock_12, -- use same clock as williams2 core
  kbdint       => kbd_intr,
  kbdscancode  => std_logic_vector(kbd_scancode), 
  joyHBCPPFRLDU => joyHBCPPFRLDU,
  keys_HUA     => keys_HUA
);

-- usb host for max3421e arduino shield (modified)

--max3421e_clk <= clock_11;
--usb_host : entity work.usb_host_max3421e
--port map(
-- clk     => max3421e_clk,
-- reset   => reset,
-- start   => start,
-- 
-- usb_report => usb_report,
-- new_usb_report => new_usb_report,
-- 
-- spi_cs_n  => arduino_io(10), 
-- spi_clk   => arduino_io(13),
-- spi_mosi  => arduino_io(11),
-- spi_miso  => arduino_io(12)
--);

-- usb keyboard report decoder

--keyboard_decoder : entity work.usb_keyboard_decoder
--port map(
-- clk     => max3421e_clk,
-- 
-- usb_report => usb_report,
-- new_usb_report => new_usb_report,
-- 
-- joyBCPPFRLDU  => joyBCPPFRLDU
--);

-- usb joystick decoder (konix drakkar wireless)

--joystick_decoder : entity work.usb_joystick_decoder
--port map(
-- clk     => max3421e_clk,
-- 
-- usb_report => usb_report,
-- new_usb_report => new_usb_report,
-- 
-- joyBCPPFRLDU  => open --joyBCPPFRLDU
--);

-- debug display

--ledr(8 downto 0) <= joyBCPPFRLDU;
--
--h0 : entity work.decodeur_7_seg port map(rom_data( 3 downto  0),hex0);
--h1 : entity work.decodeur_7_seg port map(rom_data( 7 downto  4),hex1);
--h2 : entity work.decodeur_7_seg port map(rom_data(11 downto  8),hex2);
--h3 : entity work.decodeur_7_seg port map(rom_data(15 downto 12),hex3);

h0 : entity work.decodeur_7_seg port map(dbg_out( 3 downto  0),hex0);
h1 : entity work.decodeur_7_seg port map(dbg_out( 7 downto  4),hex1);
h2 : entity work.decodeur_7_seg port map(dbg_out(11 downto  8),hex2);
h3 : entity work.decodeur_7_seg port map(dbg_out(15 downto 12),hex3);
--h4 : entity work.decodeur_7_seg port map(dbg_out(19 downto 16),hex4);

hex5 <= seven_seg;

-- audio for sgtl5000 

--sample_data <= "00" & audio & "000" & "00" & audio & "000";				

-- Clock 1us for ym_8910

--p_clk_1us_p : process(max10_clk1_50)
--begin
--	if rising_edge(max10_clk1_50) then
--		if cnt_1us = 0 then
--			cnt_1us  <= 49;
--			clk_1us  <= '1'; 
--		else
--			cnt_1us  <= cnt_1us - 1;
--			clk_1us <= '0'; 
--		end if;
--	end if;	
--end process;	 

-- sgtl5000 (teensy audio shield on top of usb host shield)

--e_sgtl5000 : entity work.sgtl5000_dac
--port map(
-- clock_18   => clock_18,
-- reset      => reset,
-- i2c_clock  => clk_1us,  
--
-- sample_data  => sample_data,
-- 
-- i2c_sda   => arduino_io(0), -- i2c_sda, 
-- i2c_scl   => arduino_io(1), -- i2c_scl, 
--
-- tx_data   => arduino_io(2), -- sgtl5000 tx
-- mclk      => arduino_io(4), -- sgtl5000 mclk 
-- 
-- lrclk     => arduino_io(3), -- sgtl5000 lrclk
-- bclk      => arduino_io(6), -- sgtl5000 bclk   
-- 
-- -- debug
-- hex0_di   => open, -- hex0_di,
-- hex1_di   => open, -- hex1_di,
-- hex2_di   => open, -- hex2_di,
-- hex3_di   => open, -- hex3_di,
-- 
-- sw => sw(7 downto 0)
--);

-- pwm sound output
process(clock_12)  -- use same clock as sound_board
begin
  if rising_edge(clock_12) then
    pwm_accumulator  <=  std_logic_vector(unsigned('0' & pwm_accumulator(11 downto 0)) + unsigned('0' & audio & "00"));
  end if;
end process;

pwm_audio_out_l <= pwm_accumulator(12);
pwm_audio_out_r <= pwm_accumulator(12); 


end struct;
