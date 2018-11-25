library ieee;
use ieee.std_logic_1164.all;

entity reg_1bit is
generic(
		zero1 : std_logic := '0';
		one1 : std_logic := '1'
	);
	port (
		d: in std_logic;
        clk, reset, enable : in std_logic;
		q: out std_logic
	);
end entity;
architecture behave of reg_1bit is
	begin
		process(clk, enable, reset)
			begin
				if reset='1' then
					q<=zero1;
				elsif (rising_edge(clk) and enable='1') then
--					if reset='1' then
--						q<=zero16;
--					elsif enable='1' then
						q<=d;
					--end if;
				end if;
		end process;
end behave;
