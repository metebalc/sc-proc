library ieee;
use ieee.std_logic_1164.all;

entity Mux4to1_N is
    generic(
        N : positive := 64
    );
    port(
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        C : in std_logic_vector(N-1 downto 0);
        D : in std_logic_vector(N-1 downto 0);
        S : in std_logic_vector(1 downto 0);
        Y : out std_logic_vector(N-1 downto 0)
    );
end entity Mux4to1_N;

architecture RTL of Mux4to1_N is
begin

    Y <= A when S = "00" else
         B when S = "01" else
         C when S = "10" else
         D;

end architecture RTL;