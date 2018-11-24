library ieee;	
use ieee.std_logic_1164.all;

entity main is
	port(
	   clk, reset, clk_50  			   : in std_logic
		--clk_50 					: in std_logic
	);
end entity;

architecture behave of main is

component Instr_Decoder is
	port(	instruction          : in std_logic_vector(0 to 15);
			rf_wr, mem_wr			: out std_logic;
			se6, se9, z9 			: out std_logic_vector(0 to 15)
			-- Add as and when reqd
	);
end component;

component ALU
	port(	alu_a,alu_b	   : in std_logic_vector(0 to 15);
			sel		      : in std_logic_vector(0 to 1);
			reset, carry_in, zero_in  :  in std_logic;
			alu_out 		: out std_logic_vector(0 to 15);
			carry,zero,a_zero  : out std_logic
	);
end component;
-- carry_in and zero_in will be  from the pipekine register of Ex/Mem 

component reg_file is
	port(	a1,a2,a3				: in std_logic_vector (0 to 2);
			d3						: in std_logic_vector (0 to 15);
			wr_en,clk, reset	: in std_logic;
			d1,d2,R7				: out std_logic_vector(0 to 15)
	);
end component;

component code_memory is
	port(	Mem_di, Mem_addr   : in std_logic_vector(0 to 15);
			clk, Mem_we, Mem_re	: in std_logic;
			Mem_do: out std_logic_vector(0 to 15)
	);
end component;
-- Disable write to code mem by Mem_we=0 permanently

component data_memory is
	port(	Mem_di, Mem_addr   : in std_logic_vector(0 to 15);
			clk, Mem_we, Mem_re	: in std_logic;
			Mem_do: out std_logic_vector(0 to 15)
	);
end component;
-- Add more components


begin
---------------------------------
-- PC fetches  instruction from code memory
---------------------------------
-- Pipeline register of IF/Decode 
---------------------------------
-- Instruction Decoder
---------------------------------
-- Pipeline register of Decode/Reg_read
---------------------------------
-- Register Read
---------------------------------
-- Pipeline register of Reg_read/Ex
---------------------------------
-- ALU
---------------------------------
-- Pipeline register of Ex/Mem
---------------------------------
-- Reading, writing from memory
---------------------------------
-- Pipeline register of Mem/WB 
---------------------------------
-- Write back (passing apppropriate a3,d3, rf_write_enable)because reg_file already there in reg read stage
---------------------------------
end behave;