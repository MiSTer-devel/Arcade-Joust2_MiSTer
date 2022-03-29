---------------------------------------------------------------------------------
-- DE10_lite Top level for sdram loader by Dar (darfpga@aol.fr) (30/11/2019)
-- http://darfpga.blogspot.fr
-- https://sourceforge.net/projects/darfpga/files
-- github.com/darfpga
---------------------------------------------------------------------------------
--
-- release rev 02 : initial release
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
--  8  bits write
--  32 bits read
---------------------------------------------------------------------------------
-- Program sdram content with this joust2 rom loader before programming joust2 
-- game core
--
-- 1) program DE10_lite with joust2 sdram loader 1
-- 2) press key(0) at least once (digit blinks during programming)

-- 3) program DE10_lite with joust2 sdram loader 2
-- 4) press key(0) at least once (digit blinks during programming)

-- 5) program DE10_lite with joust2 core without switching DE10_lite OFF
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
 signal addr_mask : std_logic_vector(17 downto 0);
 signal rom_we    : std_logic;
 signal rom_rd    : std_logic;
 signal rom_di    : std_logic_vector( 7 downto 0);
 signal sm_cycle  : std_logic_vector( 4 downto 0);
 signal rd        : std_logic;
 
 signal sdram_data: std_logic_vector(15 downto 0); 
 signal rom_data  : std_logic_vector(15 downto 0); 
 signal rom_do    : std_logic_vector( 7 downto 0); 
 signal timer     : std_logic_vector( 7 downto 0);
 
 signal graph1_do      : std_logic_vector( 7 downto 0);
 signal graph2_do      : std_logic_vector( 7 downto 0);
 signal graph3_do      : std_logic_vector( 7 downto 0);

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
	
	addr     => "0000000" & (rom_addr and addr_mask), -- 25 bit byte address
	
	we       => rom_we,        -- requests write
	di       => rom_di,        -- data input
	
	rd       => rd,            -- requests data
	sm_cycle => sm_cycle       -- state machine cycle
);

process (clock_40)
begin

	if reset = '1' then 
		rom_addr <= "11"&x"0000";  -- start adress x30000
		timer    <= (others => '0');
		rom_we   <= '0';
		rom_rd   <= '0';
		rd <= '0';
	else

		if rising_edge(clock_40) then

			if rom_rd = '0' then
			
				addr_mask <= (others => '1');
		
				if timer = x"2F" then 

					if rom_addr < x"3FFFF" then   -- 16Ko*(3+1) -> 64Ko
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
			
				addr_mask(1 downto 0) <= "00";

				rom_addr <= sw(9 downto 7)&"00000000"&sw(6 downto 0); 
				
		
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
	graph1_do     when rom_addr(1 downto 0) = "00" else -- 16Ko  -- interleave roms so that 
	graph2_do     when rom_addr(1 downto 0) = "01" else -- 16Ko  -- they can be read with 
	graph3_do     when rom_addr(1 downto 0) = "10" else -- 16Ko  -- burst length = 2 
	x"00";                                              -- 16Ko  
 
-- debug/display

process (clock_120)
begin
	if rising_edge(clock_120) then
		sdram_data <= dram_dq;
		if rom_addr(1) = '0' then		
			if (sm_cycle = 7) then
				rom_data <= sdram_data;
				if rom_addr(0) = '0' then
					rom_do <= sdram_data(15 downto 8);
				else
					rom_do <= sdram_data( 7 downto 0);
				end if;			
			end if;
		else
			if (sm_cycle = 8) then
				rom_data <= sdram_data;
				if rom_addr(0) = '0' then
					rom_do <= sdram_data(15 downto 8);
				else
					rom_do <= sdram_data( 7 downto 0);
				end if;			
			end if;		
		end if;
	end if;
end process;

h0 : entity work.decodeur_7_seg port map(rom_data( 3 downto  0),hex0);
h1 : entity work.decodeur_7_seg port map(rom_data( 7 downto  4),hex1);
h2 : entity work.decodeur_7_seg port map(rom_data(11 downto  8),hex2);
h3 : entity work.decodeur_7_seg port map(rom_data(15 downto 12),hex3);

h4 : entity work.decodeur_7_seg port map(rom_do(3 downto 0),hex4);
h5 : entity work.decodeur_7_seg port map(rom_do(7 downto 4),hex5);

-- ROMS
-- rom20.ic57
graph1_rom : entity work.joust2_graph1
port map(
 clk  => clock_40,
 addr => rom_addr(15 downto 2),
 data => graph1_do
);

-- rom20.ic58
graph2_rom : entity work.joust2_graph2
port map(
 clk  => clock_40,
 addr => rom_addr(15 downto 2),
 data => graph2_do
);

-- rom20.ic41
graph3_rom : entity work.joust2_graph3
port map(
 clk  => clock_40,
 addr => rom_addr(15 downto 2),
 data => graph3_do
);



end struct;
