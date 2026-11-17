library ieee;
use ieee.std_logic_1164.all;

entity LogicUnit is
    generic(
        N : positive := 64
    );
    port(
        A, B: in std_logic_vector(N-1 downto 0);
        LogicFn: in std_logic_vector(1 downto 0);
        Y: out std_logic_vector(N-1 downto 0)
    );
end LogicUnit;

architecture Structural of LogicUnit is
    signal luiResult: std_logic_vector(N-1 downto 0);
    signal xorResult: std_logic_vector(N-1 downto 0);
    signal orResult: std_logic_vector(N-1 downto 0);
    signal andResult: std_logic_vector(N-1 downto 0);
begin
    luiResult(31 downto 0) <= A(31 downto 12) & (11 downto 0 => '0');

    SignExtend: for i in 32 to N-1 generate
        luiResult(i) <= A(31);
    end generate;
    
    xorResult <= A xor B;
    orResult <= A or B;
    andResult <= A and B;

    --MUX to choose which logical operation is going to be used
    LogicalMUX: entity work.Mux4to1_N generic map(N => N)
        port map(
            A => luiResult,
            B => xorResult,
            C => orResult,
            D => andResult,
            S => LogicFn,
            Y => Y
        );

end architecture Structural;