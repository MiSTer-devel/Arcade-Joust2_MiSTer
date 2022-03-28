---------------------------------------------------------------------------------
-- DE10_lite Top level for Williams cvsd board by Dar (darfpga@aol.fr) (25/03/2022)
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
-- Features :
--   - mc6809
--
--   - pia6821 : mono
--   - hc55516 : mono
--   - ym2151  : stereo
--    
-- Controls :
--   sw0 to sw7 : select sound code 0-255 
--	  => listen to e.g. x01,x02,x03,x04,x05, x30,x31,32,x36,x37 and many others 
--
--   key 0 : reset
--   key 1 : trigger sound
---------------------------------------------------------------------------------
--  Use make_joust2_proms.bat to build vhd file and bin from binaries
--
-- > joust2_bg_sound_bank_a
--     snd_27256_rom23_rev1.u4   CRC(3af6b47d) IC_U4
--
-- > joust2_bg_sound_bank_b
--     snd_27256_rom24_rev1.u19  CRC(e7f9ed2e) IC_U19
--
-- > joust2_bg_sound_bank_c
--     snd_27256_rom25_rev1.u20  CRC(c85b29f7) IC_U20
--
---------------------------------------------------------------------------------
--  Other details : see williams2.vhd
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;

entity williams2_de10_lite is
port(
 max10_clk1_50  : in std_logic;
-- max10_clk2_50  : in std_logic;
-- adc_clk_10     : in std_logic;
-- ledr           : out std_logic_vector(9 downto 0);
 key            : in std_logic_vector(1 downto 0);
 sw             : in std_logic_vector(9 downto 0);

-- dram_ba    : out std_logic_vector(1 downto 0);
-- dram_ldqm  : out std_logic;
-- dram_udqm  : out std_logic;
-- dram_ras_n : out std_logic;
-- dram_cas_n : out std_logic;
-- dram_cke   : out std_logic;
-- dram_clk   : out std_logic;
-- dram_we_n  : out std_logic;
-- dram_cs_n  : out std_logic;
-- dram_dq    : inout std_logic_vector(15 downto 0);
-- dram_addr  : out std_logic_vector(12 downto 0);

 hex0 : out std_logic_vector(7 downto 0);
 hex1 : out std_logic_vector(7 downto 0);
 hex2 : out std_logic_vector(7 downto 0);
 hex3 : out std_logic_vector(7 downto 0);
 hex4 : out std_logic_vector(7 downto 0);
 hex5 : out std_logic_vector(7 downto 0);

-- vga_r     : out std_logic_vector(3 downto 0);
-- vga_g     : out std_logic_vector(3 downto 0);
-- vga_b     : out std_logic_vector(3 downto 0);
-- vga_hs    : out std_logic;
-- vga_vs    : out std_logic;
 
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

 signal clock_12   : std_logic;
 
 signal reset     : std_logic;
 
 signal audio           : std_logic_vector( 7 downto 0);
 signal speech          : std_logic_vector(15 downto 0);
 signal ym2151_left     : signed(15 downto 0);
 signal ym2151_right    : signed(15 downto 0);

 signal pwm_accumulator_l : std_logic_vector(12 downto 0);
 signal pwm_accumulator_r : std_logic_vector(12 downto 0);

 alias reset_n         : std_logic is key(0);
 alias pwm_audio_out_l : std_logic is gpio(1);  --gpio(2);
 alias pwm_audio_out_r : std_logic is gpio(3);  --gpio(3);
 
 signal sound_trig    : std_logic;
 
 signal dbg_out : std_logic_vector(31 downto 0);

begin

reset <= not reset_n;

clocks : entity work.max10_pll_120M_sdram
port map(
 inclk0 => max10_clk1_50,
 c0 => open, -- clock_120,         -- 120MHz 
 c1 => open, -- clock_120_sdram,   -- 120MHz -2ns for sdram
 c2 => open, -- clock_40,          -- N.U.
 c3 => clock_12,          -- 12MHz core clock
 locked => open
);


sound_trig <= not key(1);

-- Williams cvsd board
williams2 : entity work.williams_cvsd_board
port map(
 clock_12     => clock_12,
 reset        => reset,
 
 sound_select => sw(7 downto 0),
 sound_trig   => sound_trig,

 speech_out   => speech,
 ym2151_left  => ym2151_left,
 ym2151_right => ym2151_right,

 dbg_out => dbg_out

);

h0 : entity work.decodeur_7_seg port map(dbg_out( 3 downto  0),hex0);
h1 : entity work.decodeur_7_seg port map(dbg_out( 7 downto  4),hex1);
h2 : entity work.decodeur_7_seg port map(dbg_out(11 downto  8),hex2);
h3 : entity work.decodeur_7_seg port map(dbg_out(15 downto 12),hex3);
hex4 <= (others => '1');
hex5 <= (others => '1');

-- pwm sound output
process(clock_12)  -- use same clock as sound_board
begin
  if rising_edge(clock_12) then
		pwm_accumulator_l  <=  std_logic_vector(
			unsigned('0' & pwm_accumulator_l(11 downto 0))
			+ unsigned('0' & ym2151_left(15 downto 6))
			+ unsigned('0' & speech(15 downto 6))
         + unsigned('0' & audio & "00"));
			
		pwm_accumulator_r  <=  std_logic_vector(
			unsigned('0' & pwm_accumulator_r(11 downto 0))
			+ unsigned('0' & ym2151_right(15 downto 6))
			+ unsigned('0' & speech(15 downto 6))
         + unsigned('0' & audio & "00"));
  end if;
end process;

pwm_audio_out_l <= pwm_accumulator_l(12);
pwm_audio_out_r <= pwm_accumulator_r(12); 


end struct;
