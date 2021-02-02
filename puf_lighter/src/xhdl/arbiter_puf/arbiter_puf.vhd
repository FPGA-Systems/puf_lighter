--============================================================
--company: www.fpga-systems.ru
--developer: KeisN13
--e-mail: fpga-systems@yandex.ru
--description: arbiter puf top module
--============================================================
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;
use work.parameters.all;

entity arbiter_puf is
	port (
  		ipulse	: in sl;
  		ichallenge : in slv(C_LENGTH - 1 downto 0);
  		oresponse : out sl
	);
end arbiter_puf;

architecture structural of arbiter_puf is

	signal odelay_line_out_1 : sl := '0';
	signal odelay_line_out_2 : sl := '0';
	
begin

	inst_delay_line: entity work.delay_line(rtl)
	port map ( 
		ipulse	=> ipulse ,		--: in sl;
		isel	=> ichallenge, 	--: in slv(c_length - 1 downto 0);
		oout_1 	=> odelay_line_out_1, --: out sl;
		oout_2 	=> odelay_line_out_2	--: out sl
	);
	
	inst_dff: entity work.dff(rtl)
	port map(
		id		=> odelay_line_out_1, --: in sl;
		iclk	=> odelay_line_out_2, --: in sl;
		oq		=> oresponse	--: out sl
	);
end structural;
