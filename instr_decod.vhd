library ieee;	
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity instr_dec is
	port(
		ir : in std_logic_vector(0 to 15);
		Mem_rd, Mem_wr, RF_rd, RF_wr, m7, m5, m3, m4, m8  : out std_logic;
	        Src1, Src2, Dst1 : out std_logic_vector(0 to 3);
	        m1, m2, ALUsel, m6  : out std_logic_vector(0 to 1));
end entity;

architecture behave of instr_dec is

signal a :std_logic;
	begin

		Mem_wr <= (not ir(0)) and ir(1) and ir(3); 
		Mem_rd <= (not ir(0)) and ir(1) and (not ir(3));
		RF_rd <= not ( ((not ir(0)) and (not ir(1)) and ir(2) and ir(3)) or (ir(0) and (not ir(1)) and (not ir(2)) and (not ir(3))));
		RF_wr <= not ( ((not ir(0)) and ir(1) and ir(3)) or (ir(0) and ir(1) and (not ir(2)) and (not ir(3))));
		m7 <= (not ir(0)) and ir(1) and ir(2); -- LM or SM
		m5 <= ((not ir(0)) and ir(1) and (not ir(2))) or ((not ir(0)) and (not ir(1)) and (not ir(2)) and ir(3)); -- LW or SW or ADI
		m6(0) <= (not ir(0)) and (not ir(1)) and (not ir(2)) and ir(3); -- ADI
		m6(1) <= (not ir(0)) and ir(1) and ir(2); -- LM or SM
		m3 <= (not ir(0)) and ir(1) and (not ir(2)) and ir(3);  -- SW
		m4 <= (not ir(0)) and ir(1) and ir(2); -- LM or SM
		m1(1) <= ((not ir(0)) and (not ir(1)) and (not ir(2)) and ir(3)) or ((not ir(0)) and ir(1) and ir(2) and (not ir(3))); --ADI or LM
		m1(0) <= ((not ir(0)) and (not ir(1)) and (not ir(3))) or ((not ir(0)) and ir(1) and ir(2) and (not ir(3))); -- ADD or ADC or ADZ or NDU or NDC or NDZor LM
		m2(1) <= not ((ir(0) and (not ir(1)) and (not ir(2))) or ((not ir(0)) and (not ir(1)) and ir(2) and ir(3))); -- not( LHI or JAL or JLR)
		m2(0) <= not (((not ir(0)) and ir(1) and (not ir(3))) or (ir(0) and (not ir(1)) and (not ir(2)))); -- not ( LW or LM or JAL or JLR)
		ALUsel(1) <= ((not ir(0)) and (not ir(1)) and (not ir(2))) or (ir(0) and ir(1) and (not ir(2)) and (not ir(3))); -- ADD(of any kind) or BEQ
		ALUsel(0) <= ((not ir(0)) and (not ir(1)) and ir(2) and (not ir(3))) or (ir(0) and ir(1) and (not ir(2)) and (not ir(3))); -- Nand(of any kind) or BEQ
		m8 <= ir(0) and (not ir(1)) and (not ir(2)) and ir(3);  -- JLR
		Src1(0) <= not (((not ir(0)) and (not ir(1)) and ir(2) and ir(3)) or ((not ir(0)) and ir(1) and (not ir(2)) and (not ir(3))) or (ir(0) and (not ir(1)) and (not ir(2)))); -- not(LHI or LW or JAL or JLR)
		Src2(0) <= not (((not ir(0)) and (not ir(1)) and ir(2) and ir(3)) or ((not ir(0)) and (not ir(1)) and (not ir(2)) and ir(3)) or ((not ir(0)) and ir(1) and ir(2)) or (ir(0) and (not ir(1)) and (not ir(2)) and (not ir(3)))); -- not(ADI or LHI or LM or SM or JAL)
		Dst1(0) <= not (((not ir(0)) and ir(1) and ir(2)) or (ir(0) and ir(1) and (not ir(2)) and (not ir(3))) or ((not ir(0)) and ir(1) and (not ir(2)) and ir(3))); --not(SW or LM or SM or BEQ)
		Src1(1 to 3) <= ir(4 to 6); 
		Src2(1 to 3) <= ir(7 to 9);
		
		a <= ((not ir(0)) and (not ir(1)) and ir(2) and ir(3)) or ((not ir(0)) and  ir(1) and (not ir(2)) and (not ir(3))) or (ir(0) and (not ir(1)) and (not ir(2))); --(LHI or LW or JAL or JLR)
		
		process(a, ir, Dst1)
		begin		
			if (ir(0 to 3) = "0001") then
				Dst1(1 to 3) <= ir(7 to 9);
			elsif 
				(a='1') then
				Dst1(1 to 3) <= ir(4 to 6);
			else
				Dst1(1 to 3) <= ir(10 to 12);
			end if;
		end process;
end behave;	
