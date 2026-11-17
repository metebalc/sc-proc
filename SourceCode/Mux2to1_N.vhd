library ieee;
use ieee.std_logic_1164.all;

entity Mux2to1_N is
    generic(
        N : positive := 64
    );
    port(
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        S : in std_logic;
        Y : out std_logic_vector(N-1 downto 0)
    );
end entity Mux2to1_N;

architecture RTL of Mux2to1_N is
begin
    Y <= A when S = '0' else B;

end architecture RTL;