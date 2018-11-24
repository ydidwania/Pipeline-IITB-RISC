library ieee;	
use ieee.std_logic_1164.all;

entity mux6to1 is
	port(in_1,in_2,in_3,in_4,in_5,in_6 : in std_logic_vector(0 to 15);
		sel 	                   : in std_logic_vector(0 to 2);
		mux_out	                   : out std_logic_vector(0 to 15));
end entity;

architecture behave of mux6to1 is
begin
	process(sel, in_1, in_2, in_3,in_4,in_5,in_6)
	begin
		case sel is
		when "000" =>
			mux_out <= in_1;
		when "001" =>
			mux_out <= in_2;
		when "010" =>
			mux_out <= in_3;
		when "011" =>
			mux_out <= in_4;
		when "100" =>
			mux_out <= in_5;
		when "101" =>
			mux_out <= in_6;
		when others =>
			mux_out <= in_6;
		end case;
	end process;
end behave;
