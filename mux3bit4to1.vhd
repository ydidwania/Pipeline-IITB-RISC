library ieee;	
use ieee.std_logic_1164.all;

entity mux3bit4to1 is
	port(in_1,in_2,in_3,in_4 : in std_logic_vector(0 to 2);
		sel 	         : in std_logic_vector(0 to 1);
		mux_out	         : out std_logic_vector(0 to 2));
end entity;

architecture behave of mux3bit4to1 is
begin
	process(sel, in_1, in_2, in_3, in_4)
	begin
		case sel is
		when "00" =>
			mux_out <= in_1;
		when "01" =>
			mux_out <= in_2;
		when "10" =>
			mux_out <= in_3;
		when others =>
			mux_out <= in_4;
		end case;
	end process;
end behave;
