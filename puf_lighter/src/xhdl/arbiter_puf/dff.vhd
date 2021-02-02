--=============================================================================
--company		: www.fpga-systems.ru
--developer		: KeisN13
--e-mail		: fpga-systems@yandex.ru
--description	: simple D-flipflop
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

library unisim;
use unisim.vcomponents.all;

library work;
use work.parameters.all;

entity dff is
	port (
		id		: in std_logic ;
		iclk	: in std_logic ;		
		oq		: out std_logic 
	);
end dff;

architecture rtl of dff is

begin
	
	dff_generic: if C_DFF_TYPE = "GENERIC" generate	
	begin
		dff: process(iclk)
		begin
			if rising_edge (iclk) then
				oq <= id;
			end if;
		end process;
	end generate;
	
	dff_macro: if C_DFF_TYPE = "MACRO" generate
	begin
		inst_fdre : fdre
		   generic map (
			  init => '0') -- initial value of register ('0' or '1')  
		   port map (
			  q => oq,      -- data output
			  c => iclk,      -- clock input
			  ce => '1',    -- clock enable input
			  r => '0',      -- synchronous reset input
			  d => id       -- data input
		   );
	end generate;
end rtl;
