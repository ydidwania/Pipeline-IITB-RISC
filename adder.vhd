library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity adder is
generic(
		one16 : std_logic_vector := "0000000000000001"
	);
	port (
		a: in std_logic_vector(0 to 15);
		b: in std_logic_vector(0 to 15);
		sum: out std_logic_vector(0 to 15)
	);
end entity;
architecture behave of adder is
	begin
		process(a, b)
			variable op : std_logic_vector(0 to 15);
			begin
				op := std_logic_vector(unsigned(a) + unsigned(b));
				sum <= op;
		end process;
end behave;