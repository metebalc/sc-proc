library ieee;
use ieee.std_logic_1164.all;

entity TopLevelProcessor is
    generic(
        N : positive := 64
    );
    port(
        Clk: in std_logic;
        Reset: in std_logic
    );
end TopLevelProcessor;

architecture Structural of TopLevelProcessor is
begin

    CPU: entity work.ProcessorCore;

    IMEM: entity work.InstructionMemory;

    DMEM: entity work.DataMemory;

end architecture Structural;