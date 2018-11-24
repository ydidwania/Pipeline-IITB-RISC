library ieee;	
use ieee.std_logic_1164.all;

entity se9 is
	port(
		se9_in  : in std_logic_vector(0 to 8);
		se9_out : out std_logic_vector(0 to 15)
	);
end entity;

architecture behave of se9 is
begin
	process(se9_in)
		variable ext: std_logic_vector(0 to 6);
	begin
		ext := (others=>se9_in(0));
		se9_out <= ext & se9_in;
	end process;
end behave;
