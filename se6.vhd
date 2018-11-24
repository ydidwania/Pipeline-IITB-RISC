library ieee;	
use ieee.std_logic_1164.all;

entity se6 is
	port(
		se6_in  : in std_logic_vector(0 to 5);
		se6_out : out std_logic_vector(0 to 15)
	);
end entity;

architecture behave of se6 is
begin
	process(se6_in)
		variable ext: std_logic_vector(0 to 9);
	begin
		ext := (others=>se6_in(0));
		se6_out <= ext &  se6_in;
	end process;
end behave;
