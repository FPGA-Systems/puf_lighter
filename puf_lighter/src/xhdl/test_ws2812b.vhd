----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.12.2020 21:21:41
-- Design Name: 
-- Module Name: test_ws2812b - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_ws2812b is
    port ( iclk : in std_logic;
           ird_en : in std_logic;
           idone : in std_logic;
           
           odata : out std_logic_vector (23 downto 0);
           odata_valid : out std_logic;
           ostart : out std_logic);
end test_ws2812b;

architecture rtl of test_ws2812b is
	
	signal data : std_logic_vector (odata'range) := (others => '0');
	signal data_valid : std_logic := '0';
	signal start : std_logic := '0';
	
	type state_type is (s0, s1, s2, s3, s4 ,s5, s6);
	signal state : state_type := s0;
	attribute MARK_DEBUG : string;
	attribute MARK_DEBUG of data : signal is "yes";
	
	signal cnt : std_logic_vector (31 downto 0) := (others => '0');
begin
	
	process(iclk) begin
		if rising_edge(iclk) then
			
			start <= '0';
			data_valid <= '0';
			
			case state is
			
			when s0 => start <= '1';
						if (ird_en = '1') then
							start <= '0';
							state <= s1;
						end if;
						
			when s1 => data_valid <= '1';
						data <= x"FFFFFF";
						state <= s2;
						
			when s2 => if (ird_en = '1') then
							state <= s3;
						end if;	
						
			when s3 => data_valid <= '1';
						data <= x"000000";
						state <= s4;
						
			when s4 => 	if (ird_en = '1') then
							state <= s5;
						end if;	
						
			when s5 => data_valid <= '1';
						data <= x"0F0000";--cnt(31 downto 8);
						state <= s6;
			
			
			when s6 => if (idone = '1') then
							state <= S0;
						end if;						
			when others => state <= s0;
		end case;
		
		cnt <= cnt + 1;
		
	end if;
end process;
		
		
		
		odata <= data;
		odata_valid <= data_valid;
		ostart <= start;
		
end rtl;

architecture rtl_2 of test_ws2812b is
	
-- Constant and signal declarations
-- Add these before begin keyword in architecture
constant clock_cycles : natural := 9; -- Specify Number of clock cycles to shift
constant data_width  : natural := 24; -- Specify data width

signal sreg_in  : std_logic_vector(data_width-1 downto 0); -- Shift register Input
signal sreg_out : std_logic_vector(data_width-1 downto 0); -- Shift register Output

type array_slv is array (clock_cycles-1 downto 0) of std_logic_vector(data_width-1 downto 0);
signal sreg : array_slv := (
 x"010000",
 x"020000",
 x"030000",
 x"040000",
 x"050000",
 x"060000",
 x"070000",
 x"080000",
 x"090000"
);

signal tick : std_logic := '0';
signal cnt : natural := 0;

	
	
begin
	
	-- Add the below after begin keyword in architecture
process (iclk)
begin
   if iclk'event and iclk='1' then
      if (ird_en = '1' or tick = '1') then
       for i in 0 to clock_cycles-2 loop
           sreg(i+1) <= sreg(i);
       end loop;
       sreg(0) <= sreg(clock_cycles-1); 
      end if;
      
      odata_valid <= ird_en;
      
      cnt <= cnt +1;
      if (cnt = 900_000) then
      	tick <= '1';
      	cnt <= 0;
      else
      	tick <= '0';
      end if;
   end if;
end process;
	
	ostart <= tick;
	odata <= sreg(clock_cycles-1);
end rtl_2;
