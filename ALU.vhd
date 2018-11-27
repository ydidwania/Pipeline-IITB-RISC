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
		 reset, carry_in, zero_in  :  in std_logic;
	    alu_out 		: out std_logic_vector(0 to 15);
	    carry,zero,a_zero  : out std_logic);
end entity;

architecture behave of alu is
	begin
		process(alu_a,alu_b,sel, reset, carry_in, zero_in)
		variable op : std_logic_vector(0 to 15);
		variable z,c : std_logic :='0';
		begin
			case (sel) is			
				when "00" =>			--add without modifying flags
					op 		:= std_logic_vector(unsigned(alu_a) + unsigned(alu_b));
					carry <= carry_in;
					zero <= zero_in;
					a_zero <='0';
				
				when "01" =>			--add and modify zero and carry flag
					op 		:= std_logic_vector(unsigned(alu_a) + unsigned(alu_b));
					a_zero <='0';
					if (alu_a(0) = alu_b(0) and op(0) /= alu_a(0)) then
						carry<='1';
					else
						carry<='0';
					end if;
					if(op = "0000000000000000") then
						zero<= '1';
					else
						zero<='0';
					end if;
					
				when "10" =>			--NAND and modify zero flags
					op 		:= (alu_a nand alu_b);
					carry<=carry_in;
					a_zero <='0';
					if(op = "0000000000000000") then
						zero<= '1';
					else
						zero<='0';
					end if;
					
				when  others=>
					op 		:= std_logic_vector(unsigned(alu_a) - unsigned(alu_b));
					carry<= carry_in;
					zero <= zero_in;
					if(op = "0000000000000000") then
						a_zero <= '1';
					else
						a_zero <='0';
					end if;

			end case;
		
		if reset='1' then
			alu_out<=zero16;
		else
			alu_out <= op;
		end if;
	end process;
end behave;	
