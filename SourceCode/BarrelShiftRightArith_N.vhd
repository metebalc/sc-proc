library ieee;
use ieee.std_logic_1164.all;

library work;
use work.MathUtils.all;

entity BarrelShiftRightArith_N is
    generic(
        N : positive := 64
    );
    port(
        A     : in std_logic_vector(N-1 downto 0);
        Shift : in std_logic_vector(ceil_log2(N)-1 downto 0);
        Y     : out std_logic_vector(N-1 downto 0)
    );
end BarrelShiftRightArith_N;

architecture Structural of BarrelShiftRightArith_N is

    signal T0, T1 : std_logic_vector(N-1 downto 0);

begin
    Stage1: entity work.Mux4to1_N
        generic map(N => N)
        port map(
            A => A,
            B => (N-1 downto N-1 => A(N-1)) & A(N-1 downto 1),
            C => (N-1 downto N-2 => A(N-1)) & A(N-1 downto 2),
            D => (N-1 downto N-3 => A(N-1)) & A(N-1 downto 3),
            S => Shift(1 downto 0),
            Y => T0
        );

    Stage2: entity work.Mux4to1_N
        generic map(N => N)
        port map(
            A => T0,
            B => (N-1 downto N-4 => T0(N-1)) & T0(N-1 downto 4),
            C => (N-1 downto N-8 => T0(N-1)) & T0(N-1 downto 8),
            D => (N-1 downto N-12 => T0(N-1)) & T0(N-1 downto 12),
            S => Shift(3 downto 2),
            Y => T1
        );

    Stage3: entity work.Mux4to1_N
        generic map(N => N)
        port map(
            A => T1,
            B => (N-1 downto N-16 => T1(N-1)) & T1(N-1 downto 16),
            C => (N-1 downto N-32 => T1(N-1)) & T1(N-1 downto 32),
            D => (N-1 downto N-48 => T1(N-1)) & T1(N-1 downto 48),
            S => Shift(5 downto 4),
            Y => Y
        );

end architecture Structural;