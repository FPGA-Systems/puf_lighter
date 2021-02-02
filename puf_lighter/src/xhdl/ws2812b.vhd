----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.12.2020 20:16:17
-- Design Name: 
-- Module Name: ws2812b - rtl
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ws2812b is
	generic (
		C_LENGTH : natural := 3;
		C_CLK : natural := 50 --ns
	);
    port ( 
    
    iclk : in std_logic;
    istart : in std_logic;
    ord_en : out std_logic;
    idata : in std_logic_vector (23 downto 0);
    idata_valid : in std_logic;
    oled : out std_logic;
    odone: out std_logic
 );
end ws2812b;

architecture rtl of ws2812b is
	--time in ns
	constant T0H : natural := 350/C_CLK;
	constant T1H : natural := 900/C_CLK;
	constant T0L : natural := 900/C_CLK;
	constant T1L : natural := 350/C_CLK;
	constant TRES : natural := 70_000/C_CLK;
	
	type state_type is (S0, S0_0, S1, S2, S3, s3_1, s3_2,  S4, s4_1, s4_2, S5, S6, S7, S8);
	signal state : state_type := S0;
	signal state_cnt : state_type range S0 to S1 := S0;
	
	signal cnt : natural range 0 to TRES := 0;
	signal cnt_value : natural range 0 to TRES := 0;
	signal cnt_start : std_logic := '0';
	signal cnt_finish : std_logic := '0';
	
	
	signal rd_en : std_logic := '0';
	signal led : std_logic := '0';
	signal done : std_logic := '0';
	
	signal led_num : natural range 0 to C_LENGTH := 0;
	signal bit_num : natural range 0 to 23 := 0;
begin
	
	process (iclk) begin
		if rising_edge(iclk) then
			
			rd_en <= '0';
			led <= '0';
			done <= '0';
			cnt_start <= '0';
			
			case state is 
				when S0 => if (istart = '1') then
								state <= s0_0;
								led_num <= 0;
								bit_num <= 23;
								rd_en <= '1';
							end if;
							
				when S0_0 => if (idata_valid = '1') then
								state <= s2;
							end if;
							

				
				when s2 => if (idata(bit_num) = '0') then
								cnt_value <= T0H - 3;
								state <= s3;
							else
								cnt_value <= T1H-3;								
								state <= s4;
							end if;
							cnt_start <= '1';
							
				when S3 =>  led <= '1';
							if (cnt_finish = '1') then
								state <= s3_1;
							end if;
				
				when s3_1 => cnt_value <= T0L-6;
								cnt_start <= '1';
								state <= s3_2;
								
				when s3_2 => if (cnt_finish = '1') then
								state <= s5;
							end if;
							
				when S4 =>  led <= '1';
							if (cnt_finish = '1') then
								state <= s4_1;
							end if;
				
				when s4_1 => cnt_value <= T1L-6;
								cnt_start <= '1';
								state <= s4_2;
								
				when s4_2 => if (cnt_finish = '1') then
								state <= s5;								
							end if;
							
				when S5 => if (bit_num = 0) then
								bit_num <= 23;
								led_num <= led_num + 1;								
								state <= s6;								
							else
								state <= s2;
								bit_num <= bit_num - 1;
							end if;
							
				when s6 =>	 if (led_num = C_LENGTH ) then
							state <= S8;
							led_num <= 0;
							cnt_start <= '1';
							cnt_value <= TRES;
						else
							state <= S0_0;
							rd_en <= '1';
						end if;
						
				when s8 => if (cnt_finish = '1') then
								state <= s0;
								done <= '1';
							end if;
								
				when others => state <= s0;
			end case;
			
			
		end if;
	end process;
	
	process (iclk) begin
		if rising_edge(iclk) then
			cnt_finish <= '0';
			case state_cnt is
				when S0 => cnt <= 0;
							if (cnt_start = '1') then
								state_cnt <= s1;								
							end if;
							
				when S1 => if (cnt = cnt_value) then
								cnt_finish <= '1';
								state_cnt <= s0;						
							else
								cnt <= cnt + 1;
								state_cnt <= s1;
							end if;
				when others => state_cnt <= s0;
			end case;
		end if;
	end process;
	
	ord_en <= rd_en;
	oled <= led;
	odone <= done;
	
end rtl;
