library std;
use std .standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity reg_file is
	port (
		a1,a2,a3: in std_logic_vector (0 to 2);
		d3, d_R7: in std_logic_vector (0 to 15);
		wr_en,clk, reset, valid, z_in, c_in: in std_logic;
		d1,d2: out std_logic_vector(0 to 15)
	);
end entity;
architecture behave of reg_file is

	component reg_16bit is
		port (
			d: in std_logic_vector(0 to 15);
			clk, reset, enable : in std_logic;
			q: out std_logic_vector(0 to 15)
		);
	end component;
	component reg_1bit is
		port (
			d: in std_logic;
			clk, reset, enable : in std_logic;
			q: out std_logic
		);
	end component;
	type reg_array is array (0 to 7) of std_logic_vector(0 to 15);
	signal registers_out: reg_array;
	signal registers_in: reg_array;
	signal carry_flag, zero_flag: std_logic;
	signal enable: std_logic_vector(0 to 7);

begin
    r0: reg_16bit port map(d=>registers_in(0), clk=>clk, reset=>reset, enable=>enable(0), q=>registers_out(0));
    r1: reg_16bit port map(d=>registers_in(1), clk=>clk, reset=>reset, enable=>enable(1), q=>registers_out(1));
    r2: reg_16bit port map(d=>registers_in(2), clk=>clk, reset=>reset, enable=>enable(2), q=>registers_out(2));
    r3: reg_16bit port map(d=>registers_in(3), clk=>clk, reset=>reset, enable=>enable(3), q=>registers_out(3));
    r4: reg_16bit port map(d=>registers_in(4), clk=>clk, reset=>reset, enable=>enable(4), q=>registers_out(4));
    r5: reg_16bit port map(d=>registers_in(5), clk=>clk, reset=>reset, enable=>enable(5), q=>registers_out(5));
    r6: reg_16bit port map(d=>registers_in(6), clk=>clk, reset=>reset, enable=>enable(6), q=>registers_out(6));
    reg7: reg_16bit port map(d=>registers_in(7), clk=>clk, reset=>reset, enable=>valid, q=>registers_out(7));
	 zeroReg :  reg_1bit port map(d=>z_in, clk=>clk, reset=>reset, enable=>valid, q=>zero_flag);
	 carryReg :  reg_1bit port map(d=>c_in, clk=>clk, reset=>reset, enable=>valid, q=>carry_flag);
	 
	 registers_in(7) <= d_R7;
	 
    process(a1,a2,a3,d3,wr_en, d_R7)
		  variable reg_no1, reg_no2, reg_no3 : integer;
		  variable reg_enable : std_logic_vector(0 to 7);
    begin
		reg_no1 := to_integer(unsigned(a1));
      d1<=registers_out(reg_no1);
		
		reg_no2 := to_integer(unsigned(a2));
		d2<=registers_out(reg_no2);
		
		reg_enable := "00000000";
		reg_no3 := to_integer(unsigned(a3));
		reg_enable(reg_no3):=wr_en;
		
		enable<=reg_enable;
		registers_in<=(7=>d_R7, others=>d3);
    end process;
end behave;