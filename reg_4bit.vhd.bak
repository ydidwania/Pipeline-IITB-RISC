library ieee;
use ieee.std_logic_1164.all;

entity reg_3bit is
generic(
		zero3 : std_logic_vector := "000";
		one3 : std_logic_vector := "001"
	);
	port (
		d: in std_logic_vector(0 to 2);
        clk, reset, enable : in std_logic;
		q: out std_logic_vector(0 to 2)
	);
end entity;
architecture behave of reg_3bit is
	begin
		process(clk, enable, reset)
			begin
				if reset='1' then
					q<=zero3;
				elsif (rising_edge(clk) and enable='1') then
--					if reset='1' then
--						q<=zero16;
--					elsif enable='1' then
						q<=d;
					--end if;
				end if;
		end process;
end behave;
