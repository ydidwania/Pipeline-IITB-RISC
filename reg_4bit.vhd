library ieee;
use ieee.std_logic_1164.all;

entity reg_4bit is
generic(
		zero4 : std_logic_vector := "0000";
		one4 : std_logic_vector := "0001"
	);
	port (
		d: in std_logic_vector(0 to 3);
        clk, reset, enable : in std_logic;
		q: out std_logic_vector(0 to 3)
	);
end entity;
architecture behave of reg_4bit is
	begin
		process(clk, enable, reset)
			begin
				if reset='1' then
					q<=zero4;
				elsif (rising_edge(clk) and enable='1') then
--					if reset='1' then
--						q<=zero16;
--					elsif enable='1' then
						q<=d;
					--end if;
				end if;
		end process;
end behave;
