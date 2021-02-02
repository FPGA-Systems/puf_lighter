----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.12.2020 21:44:50
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
    Port ( iclk : in STD_LOGIC;
           oled : out STD_LOGIC;
           iforce_challenge : in std_logic;
           idimmer : in std_logic_vector(3 downto 0)
           );
end top;

architecture structure of top is
attribute DONT_TOUCH : string;
attribute DONT_TOUCH of structure : architecture is "yes";
	signal clk : std_logic;
	signal rd_en : std_logic;
	signal data : std_logic_vector(23 downto 0);
	signal data_valid : std_logic;
	signal start : std_logic;
	signal done : std_logic;
	
	component clk_wiz_0
	port
	 (-- Clock in ports
	  -- Clock out ports
	  oclk          : out    std_logic;
	  clk_in1           : in     std_logic
	 );
	end component;
	
	
begin
	
  ist_clk_wiz : clk_wiz_0
  Port map( 
    oclk => clk,
    clk_in1 => iclk
  ); 
	
	inst_test_ws2812b: entity work.test_ws2812b(rtl_2)
	port map ( 
    	iclk => clk,
        ird_en => rd_en,
        idone => done,
        ostart => start,   
        odata => data,
        odata_valid => data_valid 
     );
	
	inst_ws2812b: entity work.ws2812b(rtl)
	generic map(
		C_LENGTH => 9,
		C_CLK  =>25 --ns
	)
    port map( 
    
    iclk   		=> clk,
    istart 		=> start,
    ord_en 		=> rd_en,
    idata  		=> data,
    idata_valid => data_valid,
    oled 		=> oled,
    odone		=> done
 );
 
 
end structure;

architecture led_strip of top is 
	
	signal clk : std_logic;
	
	signal led_ord_en : std_logic;
	signal led_odone : std_logic;
	
	component clk_wiz_0
	port
	 (-- Clock in ports
	  -- Clock out ports
	  oclk          : out    std_logic;
	  clk_in1           : in     std_logic
	 );
	end component;
	
	signal master_fsm_ochallenge :  std_logic_vector(23 downto 0);	
	signal master_fsm_opulse 	 :  std_logic;
	signal master_fsm_ostart 	 :  std_logic;
	signal master_fsm_odata_valid 	 :  std_logic;
	signal master_fsm_odata :  std_logic_vector(23 downto 0);
	
	signal puf_oresponse : std_logic;
	
	signal data_dim :  std_logic_vector(23 downto 0);
	
begin
	
	ist_clk_wiz : clk_wiz_0
  	Port map( 
    	oclk => clk,
    	clk_in1 => iclk
  	); 
	
	inst_master_fsm : entity work.master_fsm(rtl)
	port map ( 
    	   iclk 		 => clk,
           ochallenge 	 => master_fsm_ochallenge,
           opulse 		 => master_fsm_opulse,
           iresponse	 => puf_oresponse,
           ird_en		 => led_ord_en,
           ostart		 => master_fsm_ostart,
           odata_valid	 => master_fsm_odata_valid,
           odata 		 => master_fsm_odata,
           iforce_challenge	=> iforce_challenge
    );
	
	
	inst_arbiter_puf : entity work.arbiter_puf(structural)
	port map(
  		ipulse	=> master_fsm_opulse,
  		ichallenge => master_fsm_ochallenge,
  		oresponse => puf_oresponse
	);
	
	inst_ws2812b: entity work.ws2812b(rtl)
	generic map(
		C_LENGTH => 60,
		C_CLK  =>25 --ns
	)
    port map( 
    
    iclk   		=> clk,
    istart 		=> master_fsm_ostart,
    ord_en 		=> led_ord_en,
    idata  		=> data_dim, --master_fsm_odata,
    idata_valid => master_fsm_odata_valid,
    oled 		=> oled,
    odone		=> open
 );

 data_dim(23) <= '0' when idimmer(0) = '1' or idimmer(1) = '1' or idimmer(2) = '1' or idimmer(3) = '1' else master_fsm_odata(23);
 data_dim(22) <= '0' when idimmer(1) = '1' or idimmer(2) = '1' or idimmer(3) = '1' else master_fsm_odata(22);
 data_dim(21) <= '0' when idimmer(2) = '1' or idimmer(3) = '1' else master_fsm_odata(21);
 data_dim(20) <= '0' when idimmer(3) = '1' else master_fsm_odata(20);
	

 data_dim(7) <= '0' when idimmer(0) = '1' or idimmer(1) = '1' or idimmer(2) = '1' or idimmer(3) = '1' else master_fsm_odata(7);
 data_dim(6) <= '0' when idimmer(1) = '1' or idimmer(2) = '1' or idimmer(3) = '1' else master_fsm_odata(6);
 data_dim(5) <= '0' when idimmer(2) = '1' or idimmer(3) = '1' else master_fsm_odata(5);
 data_dim(4) <= '0' when idimmer(3) = '1' else master_fsm_odata(4);

 data_dim(15) <= '0' when idimmer(0) = '1' or idimmer(1) = '1' or idimmer(2) = '1' or idimmer(3) = '1' else master_fsm_odata(15);
 data_dim(14) <= '0' when idimmer(1) = '1' or idimmer(2) = '1' or idimmer(3) = '1' else master_fsm_odata(14);
 data_dim(13) <= '0' when idimmer(2) = '1' or idimmer(3) = '1' else master_fsm_odata(13);
 data_dim(12) <= '0' when idimmer(3) = '1' else master_fsm_odata(12);	
 
 data_dim(19 downto 16) <= 	master_fsm_odata(19 downto 16);
 data_dim(3 downto 0) <= 	master_fsm_odata(3 downto 0);
 data_dim(11 downto 8) <= 	master_fsm_odata(11 downto 8);

end architecture;
