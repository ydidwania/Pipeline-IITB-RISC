library ieee;	
use ieee.std_logic_1164.all;

entity mux2to1 is
	port(in_1,in_2       : in std_logic_vector(0 to 15);
		sel 	     : in std_logic;
		mux_out	     : out std_logic_vector(0 to 15));
end entity;

architecture behave of mux2to1 is
begin
	process(sel, in_1, in_2)
	begin
		case sel is
		when '0' =>
			mux_out <= in_1;
		when others =>
			mux_out <= in_2;
		end case;
	end process;
end behave;
