library ieee;	
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity alu is
generic(
		zero16 : std_logic_vector := "0000000000000000";
		one16 : std_logic_vector := "0000000000000001"
	);
	port(
		alu_a,alu_b	   : in std_logic_vector(0 to 15);
	    sel		      : in std_logic_vector(0 to 1);
		 reset, rf_wr, clk  :  in std_logic;
	    alu_out 		: out std_logic_vector(0 to 15);
	    carry,zero,a_zero  : out std_logic);
end entity;

architecture behave of alu is
	begin
		process(alu_a,alu_b,sel, clk, rf_wr, reset)
		variable op : std_logic_vector(0 to 15);
		variable z,c : std_logic :='0';
		begin
			case (sel) is
			
				when "00" =>			--add without modifying flags
					op 		:= std_logic_vector(unsigned(alu_a) + unsigned(alu_b));
				when "01" =>			--add and modify zero and carry flag
					op 		:= std_logic_vector(unsigned(alu_a) + unsigned(alu_b));
				when "10" =>			--NAND and modify zero flags
					op 		:= (alu_a nand alu_b);
				when  others=>
					op 		:= std_logic_vector(unsigned(alu_a) - unsigned(alu_b));
			end case;
		
		if reset='1' then
			alu_out<=zero16;
		else
			alu_out <= op;
		end if;
		
		if(op = "0000000000000000") then
			z := '1';
		else
			z :='0';
		end if;
		
		if (alu_a(0) = alu_b(0) and op(0) /= alu_a(0)) then
			c:='1';
		else
			c:='0';
		end if;
		
		a_zero <= z;
		
		if reset = '1' then
			carry <= '0';
		elsif (rising_edge(clk) and (sel="01" and rf_wr='0')) then
			carry  <= c;	
		end if;
		
		if reset = '1' then
			zero <= '0';
		elsif (rising_edge(clk) and (sel="01" or sel="10")) then
			zero   <= z;			
		end if;
	end process;
end behave;	
