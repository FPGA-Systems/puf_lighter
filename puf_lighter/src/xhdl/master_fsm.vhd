----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2020 20:24:22
-- Design Name: 
-- Module Name: master_fsm - rtl
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
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity master_fsm is
    port ( 
    	   iclk : in std_logic;
           ochallenge : out std_logic_vector (23 downto 0);
           opulse : out std_logic;
           iresponse : in std_logic;
           ird_en : in std_logic;
           ostart : out std_logic;
           odata_valid : out std_logic;
           odata : out std_logic_vector (23 downto 0);
           iforce_challenge : in std_logic);
end master_fsm;

architecture rtl of master_fsm is
	
	signal challenge :  std_logic_vector (23 downto 0) := (others => '0');
	signal pulse :  std_logic := '0';
	signal data :  std_logic_vector (23 downto 0) := (others => '0');
	signal data_valid : std_logic := '0';
	signal start :  std_logic := '0';
	
	type state_type is (s0, s1, s2, s2_1, s3, s4, s5, s6, s7, s8);
	signal state : state_type := s0;
	
	--search challenge
	signal bad_challenge : std_logic := '0';
	constant GOOD_RESP_NUM : natural := 1000;
	signal resp_num : natural range 0 to GOOD_RESP_NUM := 0;
	signal challenge_found : std_logic := '0';
	signal shift : std_logic := '0';
	
	constant RESP_DEFAULT_VALUE : std_logic_vector(23 downto 0) := x"111_111";
	signal resp24 : std_logic_vector(odata'range) := RESP_DEFAULT_VALUE;
	
	constant CNT_LIMIT : natural := 20_000_000;
	signal cnt : natural range 0 to CNT_LIMIT := 0;
	
	signal k : natural range 0 to 24 := 0;
	
	attribute MARK_DEBUG : string;
	attribute MARK_DEBUG of state: signal is "TRUE";
	attribute MARK_DEBUG of challenge: signal is "TRUE";
	attribute MARK_DEBUG of pulse: signal is "TRUE";
	attribute MARK_DEBUG of data: signal is "TRUE";
	attribute MARK_DEBUG of data_valid: signal is "TRUE";
	attribute MARK_DEBUG of start: signal is "TRUE";
	attribute MARK_DEBUG of bad_challenge: signal is "TRUE";
	attribute MARK_DEBUG of resp_num: signal is "TRUE";
	attribute MARK_DEBUG of challenge_found: signal is "TRUE";
	attribute MARK_DEBUG of shift: signal is "TRUE";
	attribute MARK_DEBUG of k: signal is "TRUE";
				
begin
	
	bad_challenge <= '1' when resp24 = x"FFF_FFF" else
					 '1' when resp24 = x"000_000" else
					-- '1' when resp24(18 downto 15) = x"5" else
					 '0';  
	
	process (iclk) 
		variable load_resp24 : std_logic := '0';
	begin
		if rising_edge (iclk)then
		pulse <= '0';
		shift <= '0';
		load_resp24 := '0';
		
		case state is
			--good challenge search
			when s0 => 
				pulse <= '1';
				state <= s1;
				
			when s1 =>
				state <= s2;
				
			when s2 => 
				shift <= '1';
				state <= s2_1;
			
			when s2_1 => 
				state <= s3;
					
			when s3 =>
				if bad_challenge = '1' then
					resp_num <= 0;
					challenge <= challenge + '1';
					load_resp24 := '1';
					state <= s0;
				else
					if k = 23 then
						resp_num <= resp_num + 1;
						state <= s4;
					else
						k <= k + 1;
						state <= s0;
					end if;
				end if;
			
			when s4 =>
				if resp_num = GOOD_RESP_NUM then
					challenge_found <= '1';
					state <= s5;
				else
					challenge_found <= '0';
					state <= s0;
				end if;
			
			--infinit puf response generation	
			when s5 => 
				pulse <= '1';
				if iforce_challenge = '1' then
					state <= s0;
					resp_num <= 0;
					k <= 0;
					challenge <= challenge + 1;
				else
					state <= s6;
				end if;
				
				
			when s6 => 
				state <= s7;
				
			when s7 => 
				shift <= '1';
				state <= s8;
				
			when s8 =>
				state <= s5;
			
			when others => state <= s0;
		end case;
		
		--shift register with load
		if load_resp24 = '1' then
			resp24 <= RESP_DEFAULT_VALUE;
		else
			if shift = '1' then
				for i in 0 to 22 loop
					resp24(i + 1) <= resp24(i);
				end loop;
				resp24(0) <= iresponse;
			end if;
		end if;
		
		if ird_en = '1' then
			data <= resp24;
		end if;
		data_valid <= ird_en;
		
	end if;
	end process;
	
	--strip update
	process (iclk) begin
		if rising_edge(iclk) then
			if challenge_found = '1' then
				cnt <= cnt + 1;
				if cnt = CNT_LIMIT then
					cnt <= 0;
					start <= '1';
				else
					start <= '0';
				end if;
			end if;
		end if;
	end process;
	
	
	odata_valid <= data_valid;
	odata <= data;
	
	ostart <= start;
	opulse <= pulse;
	ochallenge <= challenge;
end rtl;