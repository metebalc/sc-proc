library ieee;
use ieee.std_logic_1164.all;

entity ImmediateGenerator is
    generic(
        N : positive := 64
    );
    port(
        Instruction : in std_logic_vector(31 downto 0);

        SextI : out std_logic_vector(N-1 downto 0);
        SextS : out std_logic_vector(N-1 downto 0);
        SextB : out std_logic_vector(N-1 downto 0);
        SextU : out std_logic_vector(N-1 downto 0);
        SextJ : out std_logic_vector(N-1 downto 0)
    );
end ImmediateGenerator;

architecture Behavioral of ImmediateGenerator is
begin
    -- I-type
    
    -- S-type
    -- B-type
    -- U-type
    -- J-type

end architecture Behavioral;