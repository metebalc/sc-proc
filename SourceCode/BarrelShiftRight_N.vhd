library ieee;
use ieee.std_logic_1164.all;

library work;
use work.MathUtils.all;

entity BarrelShiftRight_N is
    generic(
        N : positive := 64
    );
    port(
        A: in std_logic_vector(N-1 downto 0);
        Shift : in std_logic_vector(ceil_log2(N)-1 downto 0);
        Y: out std_logic_vector(N-1 downto 0)
    );
end BarrelShiftRight_N;