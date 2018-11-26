library ieee;
use ieee.std_logic_1164.all;

entity dep_check is
	port (
		src: in std_logic_vector(0 to 3);
		dest: in std_logic_vector(0 to 3);
		check: out std_logic
	);
end entity;
architecture behave of dep_check is
	begin
		process(src, dest)
			begin
				if (src(1 to 3) = dest(1 to 3) and src(0)='1' and dest(0)='1') then
					check<='1';
				else
					check<='0';
				end if;
		end process;
end behave;
