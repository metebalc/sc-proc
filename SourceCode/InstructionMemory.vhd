library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InstructionMemory is
    port(
        Address: in std_logic_vector(63 downto 0);
        Instruction: out std_logic_vector(31 downto 0)
    );
end InstructionMemory;

architecture RTL of InstructionMemory is
begin

end architecture RTL;