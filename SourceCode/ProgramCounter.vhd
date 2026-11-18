library ieee;
use ieee.std_logic_1164.all;

entity ProgramCounter is
    generic(
        N : positive := 64
    );
    port(
        Clk: in std_logic;
        Reset: in std_logic;
        NextPC: in std_logic_vector(N-1 downto 0);
        PC: out std_logic_vector(N-1 downto 0)
    );
end ProgramCounter;

architecture RTL of ProgramCounter is
    signal PC_reg: std_logic_vector(N-1 downto 0);
begin
    process(Clk, Reset)
    begin
        if rising_edge(Clk) then --synchronous reset and nextpc clock
            if Reset = '1' then
                PC_reg <= (N-1 downto 0 => '0');
            else
                PC_reg <= NextPC;
            end if;
        end if;
    end process;

    PC <= PC_reg;

end architecture RTL;