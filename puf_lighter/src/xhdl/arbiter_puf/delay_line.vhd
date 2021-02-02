--=============================================================================
--company		: www.fpga-systems.ru
--developer		: KeisN13
--e-mail		: fpga-systems@yandex.ru
--description	: two line of multiplexers for arbiter puf
--				  has parameter C_LENGTH - length of the chain multeplexers
--version		: 1.0
--============================================================================= 
--                                  CHANGES LOG                              --
-------------------------------------------------------------------------------
--  who/when  | ver |            changes description                         --        
-------------------------------------------------------------------------------
--  KeisN13   | 1.0 | Initial version of module
-------------------------------------------------------------------------------
--
--============================================================================= 
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;
use work.parameters.all;

entity delay_line is
	port ( 
		ipulse : in std_logic;
		isel	: in std_logic_vector (C_LENGTH - 1 downto 0);
		oout_1 : out std_logic ;
		oout_2 : out std_logic 
	);
end delay_line;

architecture rtl of delay_line is
	
	signal net : slv(2*C_LENGTH + 1 downto 0) := (others => '0');

	attribute dont_touch : string;
	attribute dont_touch of net: signal is "true";
	
begin

	net(0) <= ipulse;
	net(1) <= net(0);
	
	inst_mux_pair:  for i in 1 to C_LENGTH generate
						
		begin
	
		inst_mux_1 : entity work.mux(rtl)
		port map(
			ia 	=> net(i*2-1),
			ib 	=> net(i*2-2),
			isel	=> isel(i-1),
			oout	=> net(i*2)
		);
		
		inst_mux_2 : entity work.mux(rtl)
		port map(
			ia 	=> net(i*2-2),
			ib 	=> net(i*2-1),
			isel	=> isel(i-1),
			oout	=> net(i*2+1)
		);
	end generate;
		
	oout_1 <= 	net((C_LENGTH)*2);
	oout_2 <= 	net((C_LENGTH)*2+1);
	

end rtl;