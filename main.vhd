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
	port (
		a1,a2,a3: in std_logic_vector (0 to 2);
		d3, d_R7: in std_logic_vector (0 to 15);
		wr_en,clk, reset, valid, z_in, c_in: in std_logic;
		d1,d2: out std_logic_vector(0 to 15)
	);
end component;
component code_memory is
	port(
	    Mem_addr   : in std_logic_vector(0 to 15);
	    clk, Mem_re	: in std_logic;
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
component mux3bit2to1 is
	port(in_1,in_2       : in std_logic_vector(0 to 2);
		sel 	     : in std_logic;
		mux_out	     : out std_logic_vector(0 to 2));
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
component reg_2bit is
	port (
		d: in std_logic_vector(0 to 1);
        clk, reset, enable : in std_logic;
		q: out std_logic_vector(0 to 1)
	);
end component;
component reg_3bit is
	port (
		d: in std_logic_vector(0 to 2);
        clk, reset, enable : in std_logic;
		q: out std_logic_vector(0 to 2)
	);
end component;
component reg_4bit is
	port (
		d: in std_logic_vector(0 to 3);
        clk, reset, enable : in std_logic;
		q: out std_logic_vector(0 to 3)
	);
end component;
component priority_encoder is
	port (
		ir: in std_logic_vector (0 to 7);
		clk, rst: in std_logic;
		Z: inout std_logic_vector(0 to 2);
		F1,F0: out std_logic
	);
end component;
component dep_check is
	port (
		src: in std_logic_vector(0 to 3);
		dest: in std_logic_vector(0 to 3);
		check: out std_logic
	);
end component;
component adder is
	port (
		a: in std_logic_vector(0 to 15);
		b: in std_logic_vector(0 to 15);
		sum: out std_logic_vector(0 to 15)
	);
end component;
component instr_dec is
	port(
		ir : in std_logic_vector(0 to 15);
		Mem_rd, Mem_wr, RF_rd, RF_wr, m7, m5, m3, m4, m8  : out std_logic;
	        Src1, Src2, Dst1 : out std_logic_vector(0 to 3);
	        m1, m2, ALUsel, m6  : out std_logic_vector(0 to 1));
end component;
component z9 is
	port(
		z9_in  : in std_logic_vector(0 to 8);
		z9_out : out std_logic_vector(0 to 15)
	);
end component;
component se9 is
	port(
		se9_in  : in std_logic_vector(0 to 8);
		se9_out : out std_logic_vector(0 to 15)
	);
end component;
component se6 is
	port(
		se6_in  : in std_logic_vector(0 to 5);
		se6_out : out std_logic_vector(0 to 15)
	);
end component;



-- Add more components

--Control Signals----------------------------------------------------------------------------------------------
signal m1,m2,m6, alu_sel_dec,alu_sel_reg,m6_dec,m6_reg				: std_logic_vector(0 to 1);
signal m3,m4,m5,m7,m7_dec,m8_dec,m8_Reg,m8,m5_dec,m5_Reg , m9		: std_logic;
signal m3_dec,m3_reg,m3_ex,m4_dec,m4_reg,m4_ex, en_pip1, en_pip2	: std_logic;
signal m1_dec,m1_reg,m1_ex,m1_mem,m2_dec,m2_reg,m2_ex,m2_mem		: std_logic_vector(0 to 1);
signal m11_pip4,m12_pip4,m12_pip5, m11_pip3,m12_pip1,m12_pip2,m12_pip3, m11_pip5, m12_pc : std_logic := '0';
---------------------------------------------------------------------------------------------------------------

--Connecting Signals-------------------------------------------------------------------------------------------
--signal PC							: std_logic_vector(0 to 15);
signal  pc_in, pc_if, ir_if 		   													: std_logic_vector(0 to 15);
signal se6_dec, pc_dec, se9_dec, z7_dec, ir_dec											: std_logic_vector(0 to 15);
signal valid_dec, RF_WR_dec, mem_WR_dec, mem_RD_dec, RF_RD_dec										: std_logic;
signal src1_dec, src2_dec, dest1_dec													: std_logic_vector(0 to 3);
signal f1f0_dec, f1f0_reg														: std_logic_vector(0 to 1);
signal se6_reg, pc_reg, se9_reg, z7_reg, d1_reg, ir_reg, d2_reg, RF_d1, RF_d2 							: std_logic_vector(0 to 15);
signal RF_a1, RF_a2															: std_logic_vector(0 to 2);
signal RF_WR_reg, mem_WR_reg, mem_RD_reg, valid_reg, RF_RD_reg, RF_WR_mux_reg, mem_WR_mux_reg			: std_logic;
signal src1_reg, src2_reg, dest1_reg, dest1_intrm_reg, src2_intrm_reg							: std_logic_vector(0 to 3);
signal se6_ex, pc_ex, se9_ex, z7_ex, d1_ex, d1_ex_forw, ir_ex, d2_ex, d2_ex_forw   							: std_logic_vector(0 to 15);
signal src1_ex, src2_ex, dest1_ex													: std_logic_vector(0 to 3);
signal d1_mem, z7_mem, d2_mem, alu_out_mem, ir_mem, pc_mem 		   								: std_logic_vector(0 to 15);
signal src1_mem, src2_mem, dest1_mem													: std_logic_vector(0 to 3);
signal ir_WB, alu_out_WB, z7_WB, pc_WB, memdata_WB 			   								: std_logic_vector(0 to 15); 
signal src1_WB, src2_WB, dest1_WB													: std_logic_vector(0 to 3);
signal RF_WR_ex,RF_WR_mux_ex, mem_WR_ex, RF_WR_mem, mem_WR_mem, RF_WR_WB		       								: std_logic;
signal mem_RD_ex, mem_RD_mem,z_mux_mem 									: std_logic;
signal pe3_ex, pe3_mem, pe3_WB, pe3_dec, pe3_reg				   							: std_logic_vector(0 to 2);
signal alu_a,alu_b,alu_out, mem_di, mem_addr, mem_do, WB_d3		   								: std_logic_vector(0 to 15);
signal WB_a3								   								: std_logic_vector(0 to 2);
signal a_zero_ex, z_ex, z_mem, z_WB, c_ex, c_mem, c_WB 											: std_logic;
signal c_out, z_out, valid_mux_ex, valid_ex, valid_mem, valid_mux_mem, valid_WB, valid_mux_reg, valid_mux_dec, valid_mux_if 	: std_logic;
signal alu_sel, valid_alu_sel						   							      	: std_logic_vector(0 to 1);
--Hazardous signals
signal h11, h21, h31, h41, h12, h22, h32, h42, alu_op_ex, alu_op_mem, m10, m11_pip1, m11, m11_pip2, stall_pip3	: std_logic;
signal r7_mux_ex, r7_select_ex, r7_select_mem, r7_select_WB, r7_mem, r7_WB, adc_adz : std_logic;
signal r7_mux_mem, jlr_op_ex, jal_op_ex, lm_sm_reg, pe_cond : std_logic;
signal pc_mux_ex, pc_mux_mem,pc_mux_WB, pc_plus_1, offset, pc_plus_offset, jmp_addr : std_logic_vector(0 to 15);
signal r7_RF_input, next_pc, r7_value,r7_data_ex, pc_WB_plus_1 : std_logic_vector(0 to 15);
---------------------------------------------------------------------------------------------------------------

begin
-- LM / SM are not ordinary
lm_sm_reg <= (not ir_reg(0)) and ir_reg(1) and ir_reg(2) and valid_reg;
pe_cond <= lm_sm_reg and not(f1f0_reg(0) or f1f0_reg(1));  -- (LM or SM) and not(f1 or f0)
process(all)
begin
	if(ir_reg(0 to 3)="0110" and valid_reg='1') then
		dest1_reg<="1"&pe3_reg;
	else
		dest1_reg<=dest1_intrm_reg;
	end if;
		
	if(ir_reg(0 to 3)="0111" and valid_reg='1') then
		src2_reg<="1"&pe3_reg;
	else
		src2_reg<=src2_intrm_reg;
	end if;
end process;	

----
ProgC : reg_16bit port map(d=>pc_in, clk=>clk, reset=>reset, enable=>(not m12_pc), q=>pc_if); 
---------------------------------
-- PC fetches  instruction from code memory
code_mem : code_memory port map(Mem_addr=>pc_if, clk=>clk, Mem_re=>'1', Mem_do=>ir_if);
---------------------------------
-- Pipeline register of IF/Decode 
en_pip1 <= m12_pip1 or pe_cond; -- allowing LM/SM instruction to stall instructions

ir_pip1      : reg_16bit port map( d => ir_if, clk => clk, reset =>  reset, enable => (not en_pip1), q => ir_dec);
pc_pip1      : reg_16bit port map( d => pc_if, clk => clk, reset =>  reset, enable => (not en_pip1), q => pc_dec);
valid_pip1   : reg_1bit  port map( d => valid_mux_if, clk => clk, reset =>  reset, enable => (not en_pip1), q => valid_dec);
valid_mux_if <= not(m10 or m11_pip1);
m11_pip1 <= m11;
---------------------------------
-- Instruction Decoder
PE  : priority_encoder port map(ir => ir_dec(8 to 15), clk=>clk, rst=>reset, Z=>pe3_dec, F1=>f1f0_dec(0), F0 =>f1f0_dec(1));
ins_decode : instr_dec port map(ir=>ir_dec, Mem_rd=>mem_RD_dec, Mem_wr=>mem_WR_dec, RF_rd=>RF_RD_dec, RF_wr=>RF_WR_dec,
m3=> m3_dec, m4 => m4_dec, m5 => m5_dec, m6 => m6_dec, m7 => m7_dec, m8 => m8_dec, src1 => src1_dec, src2 => src2_dec,
dst1 => dest1_dec, m1 => m1_dec, m2 => m2_dec, ALUsel => alu_sel_dec);
valid_mux_dec <= not(m10 or m11_pip2) and valid_dec;
m11_pip2 <= m11;
se9_gen:	se9 port map(se9_in=>ir_dec(7 to 15), se9_out=>se9_dec);
se6_gen:	se6 port map(se6_in=>ir_dec(10 to 15), se6_out=>se6_dec);
z7_gen:  z9 port map(z9_in=>ir_dec(7 to 15), z9_out=>z7_dec);
---------------------------------
-- Pipeline register of Decode/Reg_read
en_pip2 <= m12_pip2 or pe_cond; -- allowing LM/SM instruction to stall instructions

ir_pip2      : reg_16bit port map( d => ir_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => ir_reg);
pc_pip2      : reg_16bit port map( d => pc_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => pc_reg);
RF_WR_pip2   : reg_1bit  port map( d => RF_WR_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => RF_WR_reg);
RF_RD_pip2   : reg_1bit  port map( d => RF_RD_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => RF_RD_reg);
mem_WR_pip2  : reg_1bit  port map( d => mem_WR_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => mem_WR_reg);
mem_RD_pip2  : reg_1bit  port map( d => mem_RD_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => mem_RD_reg);
valid_pip2   : reg_1bit  port map( d => valid_mux_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => valid_reg);
z7_pip2      : reg_16bit port map( d => z7_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => z7_reg);
pe3_pip2     : reg_3bit  port map( d => pe3_dec, clk => clk, reset=>reset, enable =>(not m12_pip2 ), q => pe3_reg);
f1f0_pip2    : reg_2bit  port map( d => f1f0_dec, clk => clk, reset=>reset, enable =>(not m12_pip2), q=> f1f0_reg);
se6_pip2     : reg_16bit port map( d => se6_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => se6_reg);
se9_pip2     : reg_16bit port map( d => se9_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => se9_reg);
src_1_pip2   : reg_4bit  port map( d => src1_dec, clk => clk, reset => reset, enable => (not en_pip2), q=> src1_reg);
src_2_pip2   : reg_4bit  port map( d => src2_dec, clk => clk, reset => reset, enable => (not en_pip2), q=> src2_intrm_reg);
dest_1_pip2  : reg_4bit  port map( d => dest1_dec, clk => clk, reset => reset, enable => (not en_pip2), q=> dest1_intrm_reg);
m1_pip2      : reg_2bit port map( d => m1_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => m1_reg);
m2_pip2      : reg_2bit port map( d => m2_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => m2_reg);
m3_pip2      : reg_1bit port map( d => m3_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => m3_reg);
m4_pip2      : reg_1bit port map( d => m4_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => m4_reg);
m5_pip2      : reg_1bit port map( d => m5_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => m5_reg);
m6_pip2      : reg_2bit port map( d => m6_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => m6_reg);
m7_pip2      : reg_1bit port map( d => m7_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => m7);
m8_pip2      : reg_1bit port map( d => m8_dec, clk => clk, reset =>  reset, enable => (not en_pip2), q => m8_reg);
alu_sel_pip2 : reg_2bit port map( d => alu_sel_dec, clk=>clk, reset=>reset, enable => (not en_pip2), q => alu_sel_reg);
---------------------------------
-- Register Read
RF_a1 <= ir_reg(4 to 6);
mux_reg_a    : mux3bit2to1 port map(in_1 =>ir_reg(7 to 9), in_2 =>pe3_reg, sel => m7, mux_out => RF_a2);
--mux_reg_b    : mux3to1 port map(in_1 => alu_out, in_2 => RF_d1, in_3 => mem_do, sel => m14, mux_out => d1_reg);
--mux_reg_c   : mux2to1 port map(in_1 => RF_d2, in_2 => R7, sel => reg_m1, mux_out => RF_d2_2);
--mux_reg_d    : mux3to1 port map(in_1 => alu_out, in_2 => RF_d2_2, in_3 => mem_do, sel => m13, mux_out => d2_reg);
RegFile      : reg_file    port map(a1=>RF_a1, a2=>RF_a2, a3=>WB_a3, wr_en=>(RF_WR_WB and valid_WB), d3=>WB_d3,
d_R7=>r7_RF_input,valid=>valid_WB, clk=>clk,reset=>reset, c_in=>c_WB, z_in=>z_WB, d1=>RF_d1, d2=>RF_d2);
valid_mux_reg <= not(m10 or m11_pip3 or stall_pip3) and valid_reg;
RF_WR_mux_reg <= not(lm_sm_reg and f1f0_reg(1)) and RF_WR_reg;
mem_WR_mux_reg <= not(lm_sm_reg and f1f0_reg(1)) and mem_WR_reg;
m11_pip3 <= m11;
---------------------------------
-- Pipeline register of Reg_read/Ex
--en_pip3 <= m12_pip3 or pe_cond; -- allowing LM/SM instruction to stall instructions
d1_pip3      : reg_16bit port map( d => d1_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => d1_ex);
d2_pip3      : reg_16bit port map( d => d2_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => d2_ex);
ir_pip3      : reg_16bit port map( d => ir_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => ir_ex);
pc_pip3      : reg_16bit port map( d => pc_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => pc_ex);
RF_WR_pip3   : reg_1bit  port map( d => RF_WR_mux_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => RF_WR_ex);
--RF_RD_pip3   : reg_1bit  port map( d => RF_RD_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => RF_RD_ex);
mem_WR_pip3  : reg_1bit  port map( d => mem_WR_mux_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => mem_WR_ex);
mem_RD_pip3  : reg_1bit  port map( d => mem_RD_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => mem_RD_ex);
valid_pip3   : reg_1bit  port map( d => valid_mux_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => valid_ex);
z7_pip3      : reg_16bit port map( d => z7_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => z7_ex);
pe3_pip3     : reg_3bit  port map( d => pe3_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => pe3_ex);
se6_pip3     : reg_16bit port map( d => se6_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => se6_ex);
se9_pip3     : reg_16bit port map( d => se9_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => se9_ex);
src_1_pip3   : reg_4bit  port map( d => src1_reg, clk => clk, reset => reset, enable => (not m12_pip3), q=> src1_ex);
src_2_pip3   : reg_4bit  port map( d => src2_reg, clk => clk, reset => reset, enable => (not m12_pip3), q=> src2_ex);
dest_1_pip3  : reg_4bit  port map( d => dest1_reg, clk => clk, reset => reset, enable => (not m12_pip3), q=> dest1_ex);
m1_pip3      : reg_2bit port map( d => m1_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => m1_ex);
m2_pip3      : reg_2bit port map( d => m2_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => m2_ex);
m3_pip3      : reg_1bit port map( d => m3_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => m3_ex);
m4_pip3      : reg_1bit port map( d => m4_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => m4_ex);
m5_pip3      : reg_1bit port map( d => m5_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => m5);
m6_pip3      : reg_2bit port map( d => m6_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => m6);
m8_pip3      : reg_1bit port map( d => m8_reg, clk => clk, reset =>  reset, enable => (not m12_pip3), q => m8);
alu_sel_pip3 : reg_2bit port map( d => alu_sel_reg, clk=>clk, reset=>reset, enable => (not m12_pip3), q => alu_sel);
--r7_chge_pip3    : reg_1bit port map( d=> '0'

---------------------------------
-- ALU
valid_alu_sel(0) <= alu_sel(0) and valid_mux_ex;
valid_alu_sel(1) <= alu_sel(1) and valid_mux_ex;
mux_alu_a    : mux2to1 port map(in_1 =>d1_ex, in_2 =>se6_ex, sel=>m5, mux_out=>alu_a);
mux_alu_b    : mux4to1 port map(in_1 =>d2_ex, in_2 =>X"0001",in_3=>d1_ex, in_4=>X"0000", sel => m6, mux_out => alu_b);
ArithLU	     : ALU     port map(alu_a => alu_a, alu_b => alu_b, sel=>valid_alu_sel, reset => reset, carry_in => c_mem, 
zero_in => z_mem, alu_out => alu_out, carry => c_out, zero => z_out, a_zero => a_zero_ex);
valid_mux_ex <= not(m11_pip4) and valid_ex;
RF_WR_mux_ex <= not(adc_adz) and RF_WR_ex;
m11_pip4 <= r7_select_mem or r7_select_WB;
---------------------------------
-- Pipeline register of Ex/Mem
d1_pip4      : reg_16bit port map( d => d1_ex_forw, clk => clk, reset =>  reset, enable => (not m12_pip4), q => d1_mem);
d2_pip4      : reg_16bit port map( d => d2_ex_forw, clk => clk, reset =>  reset, enable => (not m12_pip4), q => d2_mem);
alu_out_pip4 : reg_16bit port map( d => alu_out, clk => clk, reset =>  reset, enable => (not m12_pip4), q => alu_out_mem);
ir_pip4      : reg_16bit port map( d => ir_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => ir_mem);
pc_pip4      : reg_16bit port map( d => pc_mux_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => pc_mem);
RF_WR_pip4   : reg_1bit  port map( d => RF_WR_mux_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => RF_WR_mem);
--RF_RD_pip4   : reg_1bit  port map( d => RF_RD_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => RF_RD_mem);
mem_WR_pip4  : reg_1bit  port map( d => mem_WR_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => mem_WR_mem);
mem_RD_pip4  : reg_1bit  port map( d => mem_RD_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => mem_RD_mem);
valid_pip4   : reg_1bit  port map( d => valid_mux_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => valid_mem);
zero_pip4    : reg_1bit  port map( d => z_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => z_mem);
carry_pip4   : reg_1bit  port map( d => c_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => c_mem);
z7_pip4      : reg_16bit port map( d => z7_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => z7_mem);
pe3_pip4     : reg_3bit  port map( d => pe3_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => pe3_mem);
src_1_pip4   : reg_4bit  port map( d => src1_ex, clk => clk, reset => reset, enable => (not m12_pip4), q=> src1_mem);
src_2_pip4   : reg_4bit  port map( d => src2_ex, clk => clk, reset => reset, enable => (not m12_pip4), q=> src2_mem);
dest1_pip4   : reg_4bit  port map( d => dest1_ex, clk => clk, reset => reset, enable => (not m12_pip4), q=> dest1_mem);
m1_pip4      : reg_2bit port map( d => m1_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => m1_mem);
m2_pip4      : reg_2bit port map( d => m2_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => m2_mem);
m3_pip4      : reg_1bit port map( d => m3_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => m3);
m4_pip4      : reg_1bit port map( d => m4_ex, clk => clk, reset =>  reset, enable => (not m12_pip4), q => m4);
r7_chge_pip4 : reg_1bit port map( d=> r7_mux_ex, clk=>clk, reset=>reset, enable=>(not m12_pip4), q => r7_mem);
---------------------------------
-- Reading, writing from memory
mux_di    : mux2to1     port map(in_1 =>d2_mem, in_2 =>d1_mem, sel => m3, mux_out => mem_di);
mux_addr  : mux2to1     port map(in_1 =>alu_out_mem, in_2 =>d1_mem, sel => m4, mux_out => mem_addr);
memory    : data_memory port map(Mem_di => mem_di, Mem_addr => mem_addr, clk => clk, Mem_we => (mem_WR_mem and valid_mem),
Mem_re => (mem_RD_mem and valid_mem), Mem_do => mem_do);
valid_mux_mem <= not(m11_pip5) and valid_mem;
m11_pip5 <= r7_select_WB;
---------------------------------
-- Pipeline register of Mem/WB 
process(all)
begin
if(ir_mem(0 to 3) = "0100" and valid_mem='1') then
	if(mem_do="0000000000000000") then
		z_mux_mem<='1';
	else
		z_mux_mem<='0';
	end if;
else
	z_mux_mem<=z_mem;
end if;
end process;
		
alu_out_pip5 : reg_16bit port map( d => alu_out_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => alu_out_WB);
ir_pip5      : reg_16bit port map( d => ir_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => ir_WB);
pc_pip5      : reg_16bit port map( d => pc_mux_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => pc_WB);
memdata_pip5 : reg_16bit port map( d => mem_do, clk => clk, reset =>  reset, enable => (not m12_pip5), q => memdata_WB);
RF_WR_pip5   : reg_1bit  port map( d => RF_WR_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => RF_WR_WB);
valid_pip5   : reg_1bit  port map( d => valid_mux_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => valid_WB);
zero_pip5    : reg_1bit  port map( d => z_mux_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => z_WB);
carry_pip5   : reg_1bit  port map( d => c_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => c_WB);
z7_pip5      : reg_16bit port map( d => z7_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => z7_WB);
pe3_pip5     : reg_3bit  port map( d => pe3_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => pe3_WB);
src_1_pip5   : reg_4bit  port map( d => src1_mem, clk => clk, reset => reset, enable => (not m12_pip5), q=> src1_WB);
src_2_pip5   : reg_4bit  port map( d => src2_mem, clk => clk, reset => reset, enable => (not m12_pip5), q=> src2_WB);
dest1_pip5   : reg_4bit  port map( d => dest1_mem, clk => clk, reset => reset, enable => (not m12_pip5), q=> dest1_WB);
m1_pip5      : reg_2bit port map( d => m1_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => m1);
m2_pip5      : reg_2bit port map( d => m2_mem, clk => clk, reset =>  reset, enable => (not m12_pip5), q => m2);
r7_chge_pip5 : reg_1bit port map( d=> r7_mux_mem, clk=>clk, reset=>reset, enable=>(not m12_pip5), q => r7_WB);
---------------------------------
-- Write back (passing apppropriate a3,d3, rf_write_enable)because reg_file already there in reg read stage
mux_a3 : mux3bit4to1 port map(in_1 => ir_WB(4 to 6), in_2 => ir_WB(7 to 9), in_3 => ir_WB(10 to 12), in_4 => pe3_WB, sel => m1, mux_out => WB_a3);
mux_d3 : mux4to1     port map(in_1 => pc_WB, in_2 => memdata_WB, in_3 => z7_WB, in_4 => alu_out_WB, sel =>m2, mux_out => WB_d3);
-- corresponding outputs will be connected to RF   
r7_write: adder port map(a=>pc_WB, b=>"0000000000000001", sum=>pc_WB_plus_1);
RF_r7_inp: mux2to1 port map(in_1=>pc_WB_plus_1, in_2=>pc_mux_WB, sel=>(r7_WB or r7_select_WB), mux_out=>r7_RF_input);

---------------------------------
-- Hazardous - keep out of reach of children
dc1: dep_check port map(src=> src1_reg, dest=>dest1_ex, check=>h11);
dc2: dep_check port map(src=> src1_reg, dest=>dest1_mem, check=>h21);
dc3: dep_check port map(src=> src1_reg, dest=>dest1_WB, check=>h31);
dc4: dep_check port map(src=> src2_reg, dest=>dest1_ex, check=>h12);
dc5: dep_check port map(src=> src2_reg, dest=>dest1_mem, check=>h22);
dc6: dep_check port map(src=> src2_reg, dest=>dest1_WB, check=>h32);
dc7: dep_check port map(src=> src1_ex, dest=>dest1_mem, check=>h41);
dc8: dep_check port map(src=> src2_ex, dest=>dest1_mem, check=>h42);

alu_op_ex <= (not ir_ex(0)) and (not ir_ex(1)) and not(ir_ex(2) and ir_ex(3));
alu_op_mem <= (not ir_mem(0)) and (not ir_mem(1)) and not(ir_mem(2) and ir_mem(3));

process(all)-- d1 forwarding at RR
begin
--alu_out, alu_out_mem, WB_d3, mem_do, pc_reg
	if(RF_a1="111") then  -- querying for R7
		d1_reg <= pc_reg;
	elsif(h11='1' and RF_WR_mux_ex='1' and valid_mux_ex ='1' and valid_mux_reg='1' and RF_RD_reg ='1' and alu_op_ex='1') then -- ALU ALU dep
		d1_reg <= alu_out;
	elsif(h11='1' and ir_ex(0 to 3)="0011" and valid_mux_ex ='1' and valid_mux_reg='1' and RF_RD_reg='1') then -- (anysrc) LHI dep
		d1_reg <= z7_ex;
	elsif(h21 ='1' and RF_WR_mem='1' and valid_mux_mem ='1' and valid_mux_reg='1' and RF_RD_reg ='1' and alu_op_mem='1') then -- ALU X ALU dep
		d1_reg <= alu_out_mem;
	elsif(h21 ='1' and RF_WR_mem='1' and RF_RD_reg ='1' and mem_RD_mem='1' and valid_mux_reg='1' and valid_mux_mem='1')  then-- (any RF_RD) X LOAD dep
		d1_reg <= mem_do;
	elsif(h21='1' and RF_WR_mem='1' and valid_mux_mem ='1' and valid_mux_reg='1' and RF_RD_reg ='1' and ir_mem(0 to 3)="0011") then
		d1_reg <= z7_ex;
	elsif(h31 = '1' and RF_WR_WB='1' and RF_RD_reg ='1' and valid_WB='1' and valid_mux_reg='1')	then -- ALU X X any dep
		d1_reg <= WB_d3;
	elsif(pc_reg=pc_ex and ir_reg(0 to 2)="011" and valid_reg='1') then
		d1_reg <= alu_out;
	else -- normal 
		d1_reg <= RF_d1;
	end if;
end process;

process(all) -- d2 forwarding at RR
begin
	if(RF_a2="111") then -- querying for R7
		d2_reg <= pc_reg;
	elsif(h12='1' and RF_WR_mux_ex='1' and valid_mux_ex ='1' and valid_mux_reg='1' and RF_RD_reg ='1' and alu_op_ex='1') then -- ALU -ALU dep
		d2_reg <= alu_out;
	elsif(h12='1' and ir_ex(0 to 3)="0011" and valid_mux_ex ='1' and valid_mux_reg='1' and RF_RD_reg ='1') then -- (anysrc) LHI dep
		d2_reg <= z7_ex;
	elsif(h22 ='1' and RF_WR_mem='1' and valid_mux_mem ='1' and valid_mux_reg='1' and RF_RD_reg ='1' and alu_op_mem='1') then -- ALU X ALU dep
		d2_reg <= alu_out_mem;
	elsif(h22 ='1' and RF_WR_mem='1' and RF_RD_reg ='1' and mem_RD_mem='1' and valid_mux_reg='1' and valid_mux_mem='1') then-- ALU X LOAD dep
		d2_reg <= mem_do;
	elsif(h22='1' and RF_WR_mem='1' and valid_mux_mem ='1' and valid_mux_reg='1' and RF_RD_reg ='1' and ir_mem(0 to 3)="0011") then --(anysrc)()LHI in mem 
		d2_reg <= z7_mem;
	elsif(h32 = '1' and RF_WR_WB='1' and RF_RD_reg ='1' and valid_WB='1' and valid_mux_reg='1')	then-- ALU X X any dep
		d2_reg <= WB_d3;
	else	-- normal 
		d2_reg <= RF_d2;
	end if;
end process;

process(all) -- d1 forw at Ex for SW, d2 forw at Ex for JLR
begin
	if(h41='1' and mem_RD_mem='1' and RF_WR_mem='1' and mem_WR_mem='1' and valid_mux_mem='1' and valid_mux_ex='1') then -- SW LW forw
		d1_ex_forw <= mem_do;
	else	-- normal
		d1_ex_forw <= d1_ex;
	end if;
	
	if (h42='1' and mem_RD_mem='1' and RF_WR_mem='1' and ir_ex(0 to 3)="1001" and valid_mux_mem='1' and valid_mux_ex='1')  then -- JLR LW forw
		d2_ex_forw <= mem_do;
	else -- normal
		d2_ex_forw <= d2_ex;
	end if;
end process;

process(all)
variable cond1, cond2 : std_logic;
begin
	if (RF_WR_mux_ex='0') then
		z_ex <= z_mux_mem;
	elsif (alu_op_ex='1') then
		z_ex <= z_out;
	else
		z_ex <= z_mux_mem;
	end if;
	
	c_ex<=c_out;
	
	-- ADZ/NDZ LW modifies zero flag	
	--cond1 := z_mux_mem='0' and ir_ex(0 to 1)="00" and ir_ex(3)='0' and ir(13 to 15)="001";
	cond1 := not (z_mux_mem or ir_ex(0) or ir_ex(1) or ir_ex(3) or ir_ex(13) or ir_ex(14)) and ir_ex(15);
	-- ADC/NDC
	--cond2 := c_mem='0' and ir_ex(0 to 1)="00" and ir_ex(3)='0' and ir(13 to 15)="010";
	cond2 := not (c_mem or ir_ex(0) or ir_ex(1) or ir_ex(3) or ir_ex(13) or ir_ex(15)) and ir_ex(14);
	
	adc_adz <= cond1 or cond2;
	
--	if (cond1='1' or cond2='1') then
--		valid_mux_ex<='0';
--	else
--		valid_mux_ex<=valid_ex;
--	end if;
end process;

--  Stall 
process(all)
variable pc_s1,pip1_s1, pip2_s1, pip3_s1, pc_s2, pip1_s2, pip2_s2, pip3_s2 : std_logic;
begin
	
	-- LW in EX stage any register reader instruction in RR stage
	if(h11='1' and RF_WR_mux_ex='1' and valid_ex='1' and valid_reg='1' and RF_RD_reg='1' and mem_RD_ex='1' and ir_reg(0 to 3)/="0101") then
		-- not SW then stall 
		pc_s1  :='1';
		pip1_s1:='1';
		pip2_s1:='1';
		pip3_s1:='1';
	else
		pc_s1  :='0';
		pip1_s1:='0';
		pip2_s1:='0';
		pip3_s1:='0';
	end if;
	-- no SW exception for Source 2 as S2 of SW also uses ALU.
	if(h12='1' and RF_WR_mux_ex='1' and valid_ex='1' and valid_reg='1' and RF_RD_reg='1' and mem_RD_ex='1') then
		pc_s2  :='1';
		pip1_s2:='1';
		pip2_s2:='1';
		pip3_s2:='1';
	else
		pc_s2  :='0';
		pip1_s2:='0';
		pip2_s2:='0';
		pip3_s2:='0';
	end if;	
	m12_pc <= pc_s1 or pc_s2;
	m12_pip1 <= pip1_s1 or pip1_s2;
	m12_pip2 <= pip2_s1 or pip2_s2;
	stall_pip3 <= pip3_s1 or pip3_s2;
end process;
-- END OF HAZARDOUS AREA

-- BEGINS THE TERRITORY OF R7
offset_adder: adder port map(a=>pc_ex, b=>offset, sum=>pc_plus_offset);
mux_m8: mux2to1 port map(in_1=>se6_ex, in_2=>se9_ex, sel=>m8, mux_out=>offset);
mux_m9: mux2to1 port map(in_1=>pc_plus_offset, in_2=>d2_ex, sel=>m9, mux_out=>jmp_addr);
mux_m10: mux2to1 port map(in_1=>pc_plus_1, in_2=> jmp_addr, sel=>m10, mux_out=>next_pc);
mux_m11: mux2to1 port map(in_1=>next_pc, in_2=> r7_value, sel=>m11, mux_out=>pc_in);
pc_incrementer: adder port map(a=>pc_if, b=>"0000000000000001", sum=>pc_plus_1);

-- 1 if JLR ir_ex(0 to 3)="1001"
jlr_op_ex <= ir_ex(0) and ir_ex(3) and (not ir_ex(1)) and (not ir_ex(2));
jal_op_ex <= ir_ex(0) and not(ir_ex(1) or ir_ex(2) or ir_ex(3));
m9 <= jlr_op_ex;
m10 <= valid_mux_ex and (a_zero_ex or jlr_op_ex or jal_op_ex);
-- R7 modify business
m11 <= r7_select_ex or r7_select_mem or r7_select_WB;

process(all)
begin 
	-- EX stage ALU operation or LHI
	if(valid_mux_ex='1' and dest1_ex="1111" and (alu_op_ex='1' or ir_ex(0 to 3)="0011")) then
		r7_mux_ex<='1';
		r7_select_ex<='1';
	else
		r7_select_ex<='0';
		if(m10='1') then -- beq or jlr or jal
			r7_mux_ex<='1';
		else 
			r7_mux_ex<='0';
		end if;
	end if;
	
	--MEM stage  LW or LM
	if(r7_mem='1') then
		r7_mux_mem<='1';
		r7_select_mem<='0';
	elsif(valid_mux_mem='1' and dest1_mem="1111" and (ir_mem(0 to 3)="0110" or ir_mem(0 to 3)="0100")) then
		r7_mux_mem<='1';
		r7_select_mem<='1';
	else
		r7_mux_mem<='0';
		r7_select_mem<='0';
	end if;
	
	--WB stage 
	if (r7_WB='1') then
		r7_select_WB <='0';
	elsif(WB_a3="111" and valid_WB='1') then
		r7_select_WB <='1';
	else
		r7_select_WB <='0';
	end if;
	
	-- correct PC going into pip4 for Ex stage
	if(r7_select_ex='1') then
		pc_mux_ex <= r7_data_ex;
	elsif(m10='1') then
		pc_mux_ex <= jmp_addr;
	else
		pc_mux_ex <= pc_ex;
	end if;
	
	-- correct PC going into pip5 for mem stage
	if(r7_select_mem='1') then
		pc_mux_mem <= mem_do;
	else
		pc_mux_mem <= pc_mem;
	end if;
	
	-- correct PC going into reg-file for WB stage
	if(r7_select_WB='1') then
		pc_mux_WB <= WB_d3;
	else
		pc_mux_WB <= pc_WB;
	end if;
	
	-- correct value of R7 to be loaded into PC register
	if(alu_op_ex='1') then
		r7_data_ex <= alu_out;
	else
		r7_data_ex <= z7_ex;
	end if;
	
	if(r7_select_ex='1') then
		r7_value<=r7_data_ex;
	elsif(r7_select_mem='1') then
		r7_value <= mem_do;
	else
		r7_value <= WB_d3;
	end if;
end process;
end behave;
