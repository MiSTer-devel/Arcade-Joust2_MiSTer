---------------------------------------------------------------------------------
-- DE10_lite Top level for sdram loader by Dar (darfpga@aol.fr) (30/11/2019)
-- http://darfpga.blogspot.fr
-- https://sourceforge.net/projects/darfpga/files
-- github.com/darfpga
---------------------------------------------------------------------------------
--
-- release rev 00 : initial release
--
---------------------------------------------------------------------------------
-- Educational use only
-- Do not redistribute synthetized file with roms
-- Do not redistribute roms whatever the form
-- Use at your own risk
---------------------------------------------------------------------------------
-- Use sdram_loader_de10_lite.sdc to compile (Timequest constraints)
-- /!\
-- Don't forget to set device configuration mode with memory initialization 
--  (Assignments/Device/Pin options/Configuration mode)
---------------------------------------------------------------------------------
--  8 bits write
--  8 bits read
---------------------------------------------------------------------------------
-- Program sdram content with this turkey shoot rom bank loader before programming
-- turkey shoot game core :
--
-- 1) program DE10_lite with joust2 sdram loader
-- 2) press key(0) at least once (digit blinks during programming)
-- 3) program DE10_lite with joust2 core without switching DE10_lite OFF
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;

entity sdram_loader_de10_lite is
port(
 max10_clk1_50  : in std_logic;
-- max10_clk2_50  : in std_logic;
-- adc_clk_10     : in std_logic;
 ledr           : out std_logic_vector(9 downto 0);
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
 hex5 : out std_logic_vector(7 downto 0)

-- vga_r     : out std_logic_vector(3 downto 0);
-- vga_g     : out std_logic_vector(3 downto 0);
-- vga_b     : out std_logic_vector(3 downto 0);
-- vga_hs    : inout std_logic;
-- vga_vs    : inout std_logic;
 
-- gsensor_cs_n : out   std_logic;
-- gsensor_int  : in    std_logic_vector(2 downto 0); 
-- gsensor_sdi  : inout std_logic;
-- gsensor_sdo  : inout std_logic;
-- gsensor_sclk : out   std_logic;

-- arduino_io      : inout std_logic_vector(15 downto 0); 
-- arduino_reset_n : inout std_logic;
 
-- gpio          : inout std_logic_vector(35 downto 0)
);
end sdram_loader_de10_lite;


architecture struct of sdram_loader_de10_lite is

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
 signal clock_40  : std_logic;
 signal clock_12  : std_logic;
 signal reset     : std_logic;
 
 signal clock_120       : std_logic;
 signal clock_120_sdram : std_logic; -- (-2ns w.r.t clock_120)
 
 signal dram_dqm        : std_logic_vector(1 downto 0);

 alias reset_n         : std_logic is key(0);

 signal rom_addr  : std_logic_vector(17 downto 0);
 signal rom_we    : std_logic;
 signal rom_rd    : std_logic;
 signal rom_di    : std_logic_vector( 7 downto 0);
 signal sm_cycle  : std_logic_vector( 4 downto 0);
 signal rd        : std_logic;
 
 signal rom_data  : std_logic_vector(15 downto 0); 
 signal timer     : std_logic_vector( 7 downto 0);
 
 signal sp_rom_addr    : std_logic_vector(14 downto 0);
 signal rom_bank_a_do  : std_logic_vector( 7 downto 0);
 signal rom_bank_b_do  : std_logic_vector( 7 downto 0);
 signal rom_bank_c_do  : std_logic_vector( 7 downto 0);
 signal rom_bank_d_do  : std_logic_vector( 7 downto 0);

begin

reset <= not reset_n;

clocks : entity work.max10_pll_120M_sdram
port map(
 inclk0 => max10_clk1_50,
 c0 => clock_120,
 c1 => clock_120_sdram,
 c2 => clock_40,
 c3 => clock_12,
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
	
	addr     => "0000000" & rom_addr, -- 25 bit byte address
	
	we       => rom_we,        -- requests write
	di       => rom_di,        -- data input
	
	rd       => rd,            -- requests data
	sm_cycle => sm_cycle       -- state machine cycle
);

process (clock_40)
begin

	if reset = '1' then 
		rom_addr <= (others => '0');
		timer    <= (others => '0');
		rom_we   <= '0';
		rom_rd   <= '0';
		rd <= '0';
	else

		if rising_edge(clock_40) then

			if rom_rd = '0' then 
		
				if timer = x"2F" then 

					if rom_addr < x"1FFFF" then   -- joust2 128 ko = 32Ko*4
						rom_addr <= rom_addr + 1;
					else
						rom_rd <= '1';
					end if;
				
					timer <= (others => '0');
				
				else
					timer <= timer +1;			
				end if;
			
				if timer > 2 then rom_we <= '1'; end if;
				if timer > 6 then rom_we <= '0'; end if;
			
			else 
				rom_addr <= '0'&sw(9 downto 8)&"0000000" & sw(7 downto 0); 
				
		
				if timer = x"0F" then 				
					timer <= (others => '0');
				else
					timer <= timer +1;			
				end if;
			
				if timer > 2 then rd <= '1'; end if;
				if timer > 6 then rd <= '0'; end if;

			end if;
			
		end if;
		
	end if;
	
end process;

rom_di <=
rom_bank_a_do when rom_addr(16 downto 15) = "00" else
rom_bank_b_do when rom_addr(16 downto 15) = "01" else
rom_bank_c_do when rom_addr(16 downto 15) = "10" else
rom_bank_d_do when rom_addr(16 downto 15) = "11";
 
-- debug/display

process (clock_120)
begin
	if rising_edge(clock_120) then
    rom_data <= dram_dq;
	end if;
end process;

h0 : entity work.decodeur_7_seg port map(rom_data( 3 downto  0),hex0);
h1 : entity work.decodeur_7_seg port map(rom_data( 7 downto  4),hex1);
h2 : entity work.decodeur_7_seg port map(rom_data(11 downto  8),hex2);
h3 : entity work.decodeur_7_seg port map(rom_data(15 downto 12),hex3);

-- ROMS

bank_a_rom : entity work.joust2_bank_a
port map(
 clk  => clock_40,
 addr => rom_addr(14 downto 0),
 data => rom_bank_a_do
);

bank_b_rom : entity work.joust2_bank_b
port map(
 clk  => clock_40,
 addr => rom_addr(14 downto 0),
 data => rom_bank_b_do
);

bank_c_rom : entity work.joust2_bank_c
port map(
 clk  => clock_40,
 addr => rom_addr(14 downto 0),
 data => rom_bank_c_do
);

bank_d_rom : entity work.joust2_bank_d
port map(
 clk  => clock_40,
 addr => rom_addr(14 downto 0),
 data => rom_bank_d_do
);


end struct;
