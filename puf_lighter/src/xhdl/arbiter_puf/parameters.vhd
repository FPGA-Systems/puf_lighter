--=============================================================================
--company		: www.fpga-systems.ru
--developer		: KeisN13
--e-mail		: fpga-systems@yandex.ru
--description	: parameters of arbiter puf
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

package parameters is
	
	constant C_LENGTH : natural := 24;
	constant C_MUX_TYPE : string := --"LUT";
									"MUXF7";
	constant C_DFF_TYPE : string := --"GENERIC";
									"MACRO";
	alias sl is std_logic;
	alias slv is std_logic_vector;
	
end package;