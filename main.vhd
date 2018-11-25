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

component mux2to1 is
	port(in_1,in_2       : in std_logic_vector(0 to 15);
		sel 	     : in std_logic;
		mux_out	     : out std_logic_vector(0 to 15));
end component;

component reg_16bit is
generic(
		zero16 : std_logic_vector := "0000000000000000";
		one16 : std_logic_vector := "0000000000000001"
	);
	port (
		d: in std_logic_vector(0 to 15);
        clk, reset, enable : in std_logic;
		q: out std_logic_vector(0 to 15)
	);
end component;

component mux3bit4to1 is
	port(in_1,in_2,in_3,in_4 : in std_logic_vector(0 to 2);
		sel 	         : in std_logic_vector(0 to 1);
		mux_out	         : out std_logic_vector(0 to 2));
end component;

component mux4to1 is
	port(in_1,in_2,in_3,in_4 : in std_logic_vector(0 to 15);
		sel 	         : in std_logic_vector(0 to 1);
		mux_out	         : out std_logic_vector(0 to 15));
end component;

component reg_1bit is
	port (
		d: in std_logic;
        clk, reset, enable : in std_logic;
		q: out std_logic
	);
end component;

component reg_3bit is
	port (
		d: in std_logic_vector(0 to 2);
        clk, reset, enable : in std_logic;
		q: out std_logic_vector(0 to 2)
	);
end component;

-- Add more components

--Control Signals----------------------------------------------------------------------------------------------
signal m1,m2 									: std_logic_vector(0 to 1);
signal m3,m4,m5,m6 		        			: std_logic;
signal m11_pip4, m12_pip4,m12_pip5     : std_logic := '0';
---------------------------------------------------------------------------------------------------------------

--Connecting Signals-------------------------------------------------------------------------------------------
signal se6_ex, pc_ex, se9_ex, z7_ex, d1_ex, ir_ex, d2_ex 		   : std_logic_vector(0 to 15);
signal d1_mem, z7_mem, d2_mem, alu_out_mem, ir_mem, pc_mem 		   : std_logic_vector(0 to 15);
signal ir_WB, alu_out_WB, z7_WB, pc_WB, memdata_WB 			   : std_logic_vector(0 to 15); 
signal RF_WR_ex, mem_WR_ex, RF_WR_mem, mem_WR_mem, RF_WR_WB		   : std_logic;
signal RF_RD_ex, mem_RD_ex, RF_RD_mem, mem_RD_mem, RF_RD_WB		   : std_logic;
signal pe3_ex, pe3_mem, pe3_WB						   : std_logic_vector(0 to 2);
signal alu_a,alu_b,alu_out, mem_di, mem_addr, mem_do, WB_d3		   : std_logic_vector(0 to 15);
signal WB_a3								   : std_logic_vector(0 to 2);
signal a_zero_ex, z_ex, z_mem, z_WB, c_ex, c_mem, c_WB : std_logic;
signal cin, zin, alu_reset, valid_mux_ex, valid_ex, valid_mem, valid_WB : std_logic;
signal alu_sel						   : std_logic_vector(0 to 1);
---------------------------------------------------------------------------------------------------------------

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
mux_alu_a    : mux2to1 port map(in_1 => se6_ex, in_2 => d1_ex, sel => m5, mux_out => alu_a);
mux_alu_b    : mux2to1 port map(in_1 => "0000000000000001", in_2 => d2_ex, sel => m6, mux_out => alu_b);
ArithLU	     : ALU     port map(alu_a => alu_a, alu_b => alu_b, sel => alu_sel, reset => alu_reset, carry_in => cin, 
zero_in => zin, alu_out => alu_out, carry => c_ex, zero => z_ex, a_zero => a_zero_ex);
valid_mux_ex <= (not m11_pip4) and valid_ex;
---------------------------------
-- Pipeline register of Ex/Mem
d1_pip4      : reg_16bit port map( d => d1_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => d1_mem);
d2_pip4      : reg_16bit port map( d => d2_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => d2_mem);
alu_out_pip4 : reg_16bit port map( d => alu_out, clk => clk, reset =>  reset, enable => (not m12_pip4), q => alu_out_mem);
ir_pip4      : reg_16bit port map( d => ir_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => ir_mem);
pc_pip4      : reg_16bit port map( d => pc_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => pc_mem);
RF_WR_pip4   : reg_1bit  port map( d => RF_WR_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => RF_WR_mem);
mem_WR_pip4  : reg_1bit  port map( d => mem_WR_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => mem_WR_mem);
mem_RD_pip4  : reg_1bit  port map( d => mem_RD_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => mem_RD_mem);
valid_pip4   : reg_1bit  port map( d => valid_mux_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => valid_mem);
zero_pip4    : reg_1bit  port map( d => z_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => z_mem);
carry_pip4   : reg_1bit  port map( d => c_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => c_mem);
z7_pip4      : reg_16bit port map( d => z7_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => z7_mem);
pe3_pip4     : reg_3bit port map( d => pe3_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => pe3_mem);
---------------------------------
-- Reading, writing from memory
mux_di    : mux2to1     port map(in_1 => d1_mem, in_2 => d2_mem, sel => m3, mux_out => mem_di);
mux_addr  : mux2to1     port map(in_1 => d1_mem, in_2 => alu_out_mem, sel => m4, mux_out => mem_addr);
memory    : data_memory port map(Mem_di => mem_di, Mem_addr => mem_addr, clk => clk, Mem_we => mem_WR_mem,
Mem_re => mem_RD_mem, Mem_do => mem_do);
---------------------------------
-- Pipeline register of Mem/WB 
alu_out_pip5 : reg_16bit port map( d => alu_out_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => alu_out_WB);
ir_pip5      : reg_16bit port map( d => ir_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => ir_WB);
pc_pip5      : reg_16bit port map( d => pc_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => pc_WB);
memdata_pip5 : reg_16bit port map( d => mem_do, clk => clk, reset =>  reset, enable => (not m12_pip5), q => memdata_WB);
RF_WR_pip5   : reg_1bit  port map( d => RF_WR_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => RF_WR_WB);
valid_pip5   : reg_1bit  port map( d => valid_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => valid_WB);
zero_pip5    : reg_1bit  port map( d => z_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => z_WB);
carry_pip5   : reg_1bit  port map( d => c_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => c_WB);
z7_pip5      : reg_16bit port map( d => z7_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => z7_WB);
pe3_pip5     : reg_3bit port map( d => pe3_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => pe3_WB);
---------------------------------
-- Write back (passing apppropriate a3,d3, rf_write_enable)because reg_file already there in reg read stage
mux_a3 : mux3bit4to1 port map(in_1 => pe3_WB, in_2 => ir_WB(10 to 12), in_3 => ir_WB(7 to 9), in_4 => ir_WB(4 to 6), sel => m1, mux_out => WB_a3);
mux_d3 : mux4to1     port map(in_1 => alu_out_WB, in_2 => z7_WB, in_3 => memdata_WB, in_4 => pc_WB, sel =>m2, mux_out => WB_d3);
-- corresponding outputs will be connected to RF   
---------------------------------
end behave;
