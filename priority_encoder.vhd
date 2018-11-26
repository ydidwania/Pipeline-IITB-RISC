library std;
use std .standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity priority_encoder is
	port (
		ir: in std_logic_vector (0 to 7);
		clk, rst: in std_logic;
		Z: inout std_logic_vector(0 to 2);
		F1,F0: out std_logic
	);
end entity;
architecture behave of priority_encoder is

    signal y: std_logic_vector(0 to 7):="11111111";
    signal d,q: std_logic_vector(0 to 7);

begin
    flip_flop: process( clk )
    begin
        if rising_edge(clk) then
            q<=d;
        end if;
    end process ; -- flip flop

    encoder: process( q )
    begin
        if q(7) = '1' then
            Z<="000";
        elsif q(6)='1' then
            Z<="001";
        elsif q(5)='1' then
            Z<="010";
        elsif q(4)='1' then
            Z<="011";
        elsif q(3)='1' then
            Z<="100";
        elsif q(2)='1' then
            Z<="101";
        elsif q(1)='1' then
            Z<="110";
        elsif q(0)='1' then
            Z<="111";
        else
            Z<="000";         
        end if;

        case(q) is
            when "00000000" => F0<='1'; F1<='0';
            when "10000000"|"01000000"|"00100000"|"00010000"|"00001000"|"00000100"|"00000010"|"00000001" => F0<='0'; F1<='1';
            when others => F1<='0'; F0<='0';
        end case;
    end process ; -- encoder

    decoder: process(Z, rst, ir)
    begin
        if rst='1' then
            d<=ir;
        else
            case(Z) is
                when "000" => d<=ir(0 to 6)&"0";
                when "001" => d<=ir(0 to 5)&"00";
                when "010" => d<=ir(0 to 4)&"000";
                when "011" => d<=ir(0 to 3)&"0000";
                when "100" => d<=ir(0 to 2)&"00000";
                when "101" => d<=ir(0 to 1)&"000000";
                when "110" => d<=ir(0 to 0)&"0000000";
                when others => d<="00000000";
            end case;
        end if; 
    end process;
end behave;