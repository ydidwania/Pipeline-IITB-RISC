library ieee;
use ieee.std_logic_1164.all;

entity reg_2bit is
generic(
		zero2 : std_logic_vector := "00";
		one2 : std_logic_vector := "01"
	);
	port (
		d: in std_logic_vector(0 to 1);
        clk, reset, enable : in std_logic;
		q: out std_logic_vector(0 to 1)
	);
end entity;
architecture behave of reg_2bit is
	begin
		process(clk, enable, reset)
			begin
				if reset='1' then
					q<=zero2;
				elsif (rising_edge(clk) and enable='1') then
--					if reset='1' then
--						q<=zero16;
--					elsif enable='1' then
						q<=d;
					--end if;
				end if;
		end process;
end behave;
