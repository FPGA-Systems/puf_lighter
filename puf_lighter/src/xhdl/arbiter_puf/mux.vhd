--=============================================================================
--company		: www.fpga-systems.ru
--developer		: KeisN13
--e-mail		: fpga-systems@yandex.ru
--description	: simple multiplexer
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
use work.parameters.all;

library unisim;
use unisim.vcomponents.all;

entity mux is
    port ( 
    	ia : in std_logic;
        ib : in std_logic;
        isel : in std_logic;
        oout : out std_logic);
end mux;

architecture rtl of mux is

begin
	inst_mux_as_lut: if C_MUX_TYPE = "LUT" generate
	begin
		oout <= ia when isel = '1' else ib;
	end generate;
	
	inst_mux_as_muxf7: if C_MUX_TYPE = "MUXF7" generate
	begin
		inst_muxf7 : muxf7
		   port map (
			  o => oout,    -- output of mux to general routing
			  i0 => ia,  -- input (tie to lut6 o6 pin)
			  i1 => ib,  -- input (tie to lut6 o6 pin)
			  s => isel     -- input select to mux
		   );
	end generate;
end rtl;
