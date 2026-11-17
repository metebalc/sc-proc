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

architecture Structural of BarrelShiftRight_N is
    signal T0, T1 : std_logic_vector(N-1 downto 0);

begin
    Stage1: entity work.Mux4to1_N
        generic map(N => N)
        port map(
            A => A,
            B => (0 downto 0 => '0') & A(N-1 downto 1),
            C => (1 downto 0 => '0') & A(N-1 downto 2),
            D => (2 downto 0 => '0') & A(N-1 downto 3),
            S => Shift(1 downto 0),
            Y => T0
        );

    Stage2: entity work.Mux4to1_N
        generic map(N => N)
        port map(
            A => T0,
            B => (3 downto 0 => '0') & T0(N-1 downto 4),
            C => (7 downto 0 => '0') & T0(N-1 downto 8),
            D => (11 downto 0 => '0') & T0(N-1 downto 12),
            S => Shift(3 downto 2),
            Y => T1
        );

    Stage3: entity work.Mux4to1_N
        generic map(N => N)
        port map(
            A => T1,
            B => (15 downto 0 => '0') & T1(N-1 downto 16),
            C => (31 downto 0 => '0') & T1(N-1 downto 32),
            D => (47 downto 0 => '0') & T1(N-1 downto 48),
            S => Shift(5 downto 4),
            Y => Y
        );

end architecture Structural;