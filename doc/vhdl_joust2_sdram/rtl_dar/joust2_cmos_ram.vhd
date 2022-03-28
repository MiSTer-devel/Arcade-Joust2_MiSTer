-- -----------------------------------------------------------------------
--
-- Syntiac's generic VHDL support",x"iles.
--
-- -----------------------------------------------------------------------
-- Copyright 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
--
-- Modified April 2016 by Dar (darfpga@aol.fr) 
-- http://darfpga.blogspot.fr
--   Remove address register when writing
--
-- Modifies March 2022 by Dar 
--   Add init data with joust2 cmos value
-- -----------------------------------------------------------------------
--
-- gen_rwram.vhd init with joust2 cmos value
--
-- -----------------------------------------------------------------------
--
-- generic ram.
--
-- -----------------------------------------------------------------------
-- joust2 cmos settings --
--
--@00-01: Extra man every          - BCD 00 to 99
--@02-03: Men for for 1 credit     - BCD 01 to 99
--@04-05: High score to date allwd - BCD 00 to 01 - No / Yes
--@06-07: Sound in attract mode    - BCD 00 to 01 - No / Yes
--@08-09: Pricing selection        - BCD 00 to 09 - Custom / free play
--@0A-0B: Left coin slot units     - BCD 00 to 99 
--@0C-0D: Center coin slot units   - BCD 00 to 99 
--@0E-0F: Right coin slot units    - BCD 00 to 99 
--@10-11: Unit for credit          - BCD 01 to 99 
--@12-13: Unit for bonus credit    - BCD 00 to 99 
--@14-15: Min unit                 - BCD 00 to 99 
--@16-17: Difficulty               - BCD 00 to 09 
--@18-19: Letters for High score   - BCD 03 to 20 
--@1A-1B: Restore factory settings - BCD 00 to 01 - No / Yes
--@1C-1D: Clear bookkeeping        - BCD 00 to 01 - No / Yes
--@1E-1F: High score reset         - BCD 00 to 01 - No / Yes
--@20-21: Auto cycle               - BCD 00 to 01 - No / Yes
--@22-23: Set attract mode message - BCD 00 to 01 - No / Yes
--@24-25: Set high score name      - BCD 00 to 01 - No / Yes
--@26-57: Message line 1           - LUT 00 -> '0' / 0B -> 'A' ...
--@58-89: Message line 2           - LUT 00 -> '0' / 0B -> 'A' ...
--@8A-8B: Position line 1          - HEX x08 to x46
--@8C-8D: Position line 2          - HEX x08 to x46
--@8E-8F: control sum of settings
--@90-91: ?
-- -----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
-- -----------------------------------------------------------------------
entity joust2_cmos_ram is
	generic (
		dWidth : integer := 8;  -- must be  4",x"or tshoot_cmos_ram
		aWidth : integer := 10  -- must be 10",x"or tshoot_cmos_ram
	);
	port (
		clk : in std_logic;
		we : in std_logic;
		addr : in std_logic_vector((aWidth-1) downto 0);
		d : in std_logic_vector((dWidth-1) downto 0);
		q : out std_logic_vector((dWidth-1) downto 0)
	);
end entity;
-- -----------------------------------------------------------------------
-- tshoot cmos data
-- (ram is 128x4 => only 4 bits/address, that is only 1 hex digit/address)

architecture rtl of joust2_cmos_ram is
subtype addressRange is integer range 0 to ((2**aWidth)-1);
type ramDef is array(addressRange) of std_logic_vector((dWidth-1) downto 0);
	
signal ram: ramDef := (
x"2",x"5",x"0",x"5",x"0",x"1",x"0",x"1",x"0",x"3",x"0",x"1",x"0",x"4",x"0",x"1",
x"0",x"1",x"0",x"0",x"0",x"0",x"0",x"5",x"0",x"3",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"A",x"0",x"A",x"0",x"A",x"0",x"A",x"0",x"A",
x"0",x"A",x"0",x"A",x"1",x"A",x"1",x"C",x"0",x"F",x"1",x"D",x"0",x"F",x"1",x"8",
x"1",x"E",x"0",x"F",x"0",x"E",x"0",x"A",x"0",x"C",x"2",x"3",x"3",x"2",x"0",x"A",
x"0",x"A",x"0",x"A",x"0",x"A",x"0",x"A",x"2",x"1",x"1",x"3",x"1",x"6",x"1",x"6",
x"1",x"3",x"0",x"B",x"1",x"7",x"1",x"D",x"0",x"A",x"0",x"F",x"1",x"6",x"0",x"F",
x"0",x"D",x"1",x"E",x"1",x"C",x"1",x"9",x"1",x"8",x"1",x"3",x"0",x"D",x"1",x"D",
x"0",x"A",x"1",x"3",x"1",x"8",x"0",x"D",x"2",x"E",x"2",x"5",x"2",x"9",x"5",x"7",
x"5",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"1",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
x"0",x"0",x"0",x"0",x"1",x"4",x"1",x"9",x"1",x"F",x"1",x"D",x"1",x"E",x"0",x"A",
x"2",x"1",x"1",x"3",x"1",x"6",x"1",x"6",x"1",x"3",x"0",x"B",x"1",x"7",x"1",x"D",
x"0",x"A",x"0",x"A",x"0",x"A",x"0",x"A",x"0",x"A",x"0",x"A",x"2",x"1",x"1",x"3",
x"1",x"6",x"1",x"0",x"1",x"0",x"2",x"6",x"8",x"6",x"0",x"E",x"0",x"F",x"1",x"1",
x"B",x"0",x"0",x"4",x"8",x"4",x"9",x"3",x"1",x"D",x"1",x"F",x"0",x"F",x"D",x"0",
x"0",x"4",x"7",x"1",x"1",x"3",x"1",x"C",x"1",x"4",x"0",x"E",x"7",x"0",x"0",x"4",
x"6",x"1",x"7",x"5",x"1",x"E",x"1",x"4",x"0",x"E",x"1",x"0",x"0",x"4",x"5",x"2",
x"2",x"2",x"1",x"4",x"1",x"C",x"1",x"8",x"6",x"0",x"0",x"4",x"4",x"2",x"1",x"0",
x"1",x"4",x"1",x"9",x"0",x"F",x"F",x"0",x"0",x"4",x"3",x"2",x"1",x"7",x"1",x"5",
x"2",x"0",x"0",x"E",x"7",x"0",x"0",x"4",x"2",x"9",x"9",x"9",x"2",x"1",x"0",x"C",
x"0",x"E",x"4",x"0",x"0",x"4",x"1",x"0",x"1",x"1",x"1",x"7",x"1",x"6",x"0",x"A",
x"7",x"0",x"0",x"4",x"0",x"5",x"2",x"3",x"0",x"D",x"0",x"A",x"1",x"1",x"7",x"0",
x"0",x"3",x"9",x"9",x"0",x"9",x"1",x"E",x"1",x"4",x"0",x"F",x"F",x"0",x"0",x"3",
x"8",x"0",x"0",x"1",x"1",x"1",x"2",x"1",x"1",x"D",x"0",x"0",x"0",x"3",x"7",x"2",
x"1",x"0",x"1",x"7",x"0",x"A",x"1",x"7",x"E",x"0",x"0",x"3",x"6",x"1",x"9",x"1",
x"0",x"B",x"1",x"6",x"0",x"A",x"6",x"0",x"0",x"3",x"5",x"1",x"0",x"1",x"1",x"1",
x"0",x"A",x"1",x"D",x"5",x"0",x"0",x"3",x"4",x"2",x"1",x"1",x"1",x"5",x"1",x"3",
x"1",x"7",x"A",x"0",x"0",x"3",x"3",x"5",x"6",x"7",x"1",x"A",x"1",x"0",x"2",x"4",
x"8",x"0",x"0",x"3",x"2",x"8",x"9",x"0",x"1",x"4",x"0",x"B",x"1",x"8",x"7",x"0",
x"0",x"3",x"1",x"9",x"0",x"1",x"1",x"A",x"2",x"0",x"0",x"B",x"8",x"0",x"0",x"3",
x"0",x"1",x"5",x"7",x"1",x"0",x"0",x"A",x"1",x"C",x"8",x"0",x"0",x"2",x"9",x"2",
x"3",x"0",x"1",x"4",x"1",x"3",x"1",x"7",x"0",x"0",x"0",x"2",x"8",x"7",x"7",x"7",
x"1",x"C",x"0",x"A",x"2",x"1",x"B",x"0",x"0",x"2",x"7",x"9",x"8",x"7",x"1",x"4",
x"1",x"1",x"0",x"E",x"4",x"0",x"0",x"2",x"6",x"9",x"5",x"9",x"1",x"5",x"0",x"F",
x"1",x"8",x"D",x"0",x"0",x"2",x"5",x"8",x"8",x"8",x"1",x"7",x"0",x"A",x"1",x"1",
x"C",x"0",x"0",x"2",x"4",x"6",x"7",x"5",x"0",x"E",x"1",x"9",x"1",x"8",x"A",x"0",
x"0",x"2",x"3",x"3",x"1",x"0",x"1",x"8",x"0",x"A",x"1",x"1",x"A",x"0",x"0",x"2",
x"2",x"9",x"1",x"7",x"0",x"D",x"1",x"C",x"0",x"C",x"6",x"0",x"0",x"2",x"2",x"5",
x"5",x"2",x"1",x"6",x"0",x"A",x"1",x"5",x"2",x"0",x"0",x"2",x"0",x"5",x"2",x"2",
x"1",x"4",x"1",x"7",x"0",x"D",x"0",x"0",x"0",x"1",x"7",x"6",x"3",x"5",x"1",x"1",
x"1",x"6",x"0",x"C",x"9",x"0",x"0",x"1",x"6",x"5",x"3",x"5",x"0",x"F",x"0",x"E",
x"0",x"A",x"7",x"0",x"0",x"1",x"5",x"5",x"0",x"5",x"0",x"E",x"1",x"4",x"2",x"1",
x"4",x"0",x"0",x"1",x"4",x"3",x"1",x"5",x"1",x"8",x"0",x"A",x"1",x"D",x"F",x"0",
x"0",x"1",x"3",x"1",x"0",x"9",x"1",x"4",x"0",x"F",x"1",x"0",x"9",x"0",x"0",x"1",
x"2",x"0",x"1",x"0",x"0",x"C",x"0",x"B",x"0",x"E",x"8",x"0",x"0",x"1",x"1",x"7",
x"5",x"5",x"0",x"C",x"1",x"C",x"1",x"3",x"5",x"0",x"0",x"1",x"0",x"5",x"0",x"2",
x"1",x"7",x"0",x"B",x"0",x"E",x"3",x"0",x"0",x"0",x"9",x"4",x"0",x"5",x"2",x"4",
x"0",x"B",x"0",x"D",x"B",x"0",x"0",x"0",x"8",x"3",x"1",x"1",x"2",x"0",x"0",x"B",
x"2",x"2",x"9",x"0",x"0",x"0",x"7",x"0",x"0",x"1",x"1",x"4",x"1",x"C",x"1",x"8",
x"0",x"0",x"0",x"4",x"4",x"2",x"1",x"0",x"1",x"4",x"1",x"9",x"0",x"F",x"0",x"0",
x"0",x"4",x"3",x"2",x"1",x"7",x"1",x"5",x"2",x"0",x"0",x"E",x"0",x"0",x"0",x"4",
x"2",x"9",x"9",x"9",x"2",x"1",x"0",x"C",x"0",x"E",x"0",x"0",x"0",x"4",x"1",x"0",
x"1",x"1",x"1",x"7",x"1",x"6",x"0",x"A",x"0",x"0",x"0",x"4",x"0",x"5",x"2",x"3",
x"0",x"D",x"0",x"A",x"1",x"1",x"0",x"0",x"0",x"3",x"9",x"9",x"0",x"9",x"0",x"0");

signal rAddrReg : std_logic_vector((aWidth-1) downto 0);
signal qReg : std_logic_vector((dWidth-1) downto 0);

begin
-- -----------------------------------------------------------------------
-- Signals to entity interface
-- -----------------------------------------------------------------------
--	q <= qReg;
-- -----------------------------------------------------------------------
-- Memory write
-- -----------------------------------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
			if we = '1' then
				ram(to_integer(unsigned(addr))) <= d;
			end if;
		end if;
	end process;
-- -----------------------------------------------------------------------
-- Memory read
-- -----------------------------------------------------------------------
process(clk)
	begin
		if rising_edge(clk) then
--			qReg <= ram(to_integer(unsigned(rAddrReg)));
--			rAddrReg <= addr;
--			qReg <= ram(to_integer(unsigned(addr)));
			q <= ram(to_integer(unsigned(addr)));
		end if;
	end process;
--q <= ram(to_integer(unsigned(addr)));
end architecture;

