library ieee;
use ieee.std_logic_1164.all;

entity ExecutionUnit is
    generic(
        N : positive := 64
    );
    port(
        A, B: in std_logic_vector(N-1 downto 0);
        ExUOut: out std_logic_vector(N-1 downto 0)
    );
end ExecutionUnit;

architecture Structural of ExecutionUnit is
begin

end Structural;
