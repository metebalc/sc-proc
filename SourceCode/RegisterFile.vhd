library ieee;
use ieee.std_logic_1164.all;

entity RegisterFile is
    generic(
        N : positive := 64
    );
    port(
        Clk: in std_logic;
        RegWr: in std_logic;
        RS1: in std_logic_vector(4 downto 0);
        RS2: in std_logic_vector(4 downto 0);
        RSD: in std_logic_vector(4 downto 0);
        RD_in: in std_logic;
        
        RS1_OUT: out std_logic_vector(N-1 downto 0);
        RS2_OUT: out std_logic_vector(N-1 downto 0)
    );
end RegisterFile;