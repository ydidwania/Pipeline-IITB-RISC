library ieee;	
use ieee.std_logic_1164.all;

entity z9 is
	port(
		z9_in  : in std_logic_vector(0 to 8);
		z9_out : out std_logic_vector(0 to 15)
	);
end entity;

architecture behave of z9 is
begin
	process(z9_in)
	begin
--		z9_out <= (others=>'0');
		z9_out <= z9_in & "0000000";
	end process;
end behave;
