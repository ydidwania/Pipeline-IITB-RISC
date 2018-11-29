
library ieee;	
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity code_memory is
	port(
	    Mem_addr   : in std_logic_vector(0 to 15);
	    clk, Mem_re	: in std_logic;
	    Mem_do: out std_logic_vector(0 to 15)
	);
end entity;

architecture comb of code_memory is

type ram_type is array (0 to 63) of std_logic_vector(0 to 15);
--signal RAM: ram_type:= (X"3007", X"3205", X"0050",others => X"0000");
signal RAM : ram_type :=
(
	 0  =>   "0011000000000000",  --lhi = 0000h
	 1  =>   "0011001000000000",   --= 0000h
	 2  =>   "0011010000000001", -- = 0080h
	 3  =>   "0011011000000010", -- = 0100h
	 4  =>   "0011100000000011", -- = 0180h
	 5  =>   "0011101000000100", -- = 0200h
	 6  =>   "0011110000000101",  --lhi = 0280h

--	 7  =>   "0000000001000000", --r0=r1+r0  (sets z)
	 7  =>	"0110000000000000", --lm r0 0 00000000		
--	 8  =>   "0100100000000000", --r4 = "0011000000000000"(mem location 0)
	 8  =>  	"0111110000010000", --sm r6 0 00010000		
--	 9  =>   "0000010011010001", --r2=r2+r3 if z (z = 1)
	 9  =>   "0000010101100000", --r4=r2+r5 
	10  =>   "0100100000000000", --r4 = "0180h"(mem location 0) LW

	11  =>   "1001001100000000", -- JLR r1, R4
	12  =>   "0100100000000000", --r4 = "0011000000000000"(mem location 0)
	13  =>   "0000100101100000", --r4=r4+r5 
	14  =>   "0010110111110001", --R6=R6 NAND R7 IF Z
	15  =>   "0011011000000000", --lhi r3 = 0x0000   


	16  =>   "0110011000101110",-- lm r3 (r5,r3,r2,r1) = (r1 ---> 0)
	17  =>   "0000101110101010",--r5=r5+r6 if C
	18  =>   "0011011100000000", --lhi r3 = 0x8000   
	19  =>   "0011100100000000",-- lhi r4 =  0x8000
	20  =>   "0000011100100000",--r4=r3+r4
	21  =>   "0000101110101010",--r5=r5+r6 if C
	22  =>   "0010101110101010",--r5 = r5 nand r6 if c
	23  =>   "0000011100100000",--r4=r3+r4
	24  =>   "0010101110101010",--r5 = r5 nand r6 if c
	25  =>   "0010000001001000",--r1=r1 nand r0
	26  =>   "0010011001011000",--r3= r3 nand r1
	27  =>   "0011000000000001",-- lhi r0= 1
	28  =>   "0011001000000010",-- lhi r1 = 2
	29  =>   "0011010000000010",-- lhi r2= 2
	30  =>   "1100000001000010",-- beq r0,r1,2
	31  =>   "1100001010000010",-- beq r1,r2,2
	32  =>   "1000011000000010",-- jal r3, 2
	33  =>   "0011100000000000",-- lhi r4,0
	34  =>   "1001011000000000",-- jalr r3,r0 
	
	others => X"0000"

) ;

signal short_address : std_logic_vector(0 to 5);

begin
	short_address <= Mem_addr(10 to 15);
--	Synch_RAM: process(clk)
--	begin
--		if rising_edge (clk) then
--			if Mem_we='1' then
--				RAM(to_integer(unsigned(short_address))) <= Mem_di ;
--			end if;	
--		end if;
		
		--if Mem_re='1' then
		--	Mem_do <=	RAM(to_integer(unsigned(short_address)));
		--end if;
--	end process;
	Mem_do <=	RAM(to_integer(unsigned(short_address)));
end comb;
