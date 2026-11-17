library ieee;
use ieee.std_logic_1164.all;

library work;
use work.MathUtils.all;

entity BarrelShiftLeft_N is
    generic(
        N : positive := 64
    );
    port(
        A: in std_logic_vector(N-1 downto 0);
        Shift : in std_logic_vector(ceil_log2(N)-1 downto 0);
        Y: out std_logic_vector(N-1 downto 0)
    );
end BarrelShiftLeft_N;

architecture Structural of BarrelShiftLeft_N is
    signal T0, T1 : std_logic_vector(N-1 downto 0);

begin
    Stage1: entity work.Mux4to1_N
        generic map(N => N)
        port map(
            A => A,
            B => A(N-2 downto 0) & (0 downto 0 => '0'),
            C => A(N-3 downto 0) & (1 downto 0 => '0'),
            D => A(N-4 downto 0) & (2 downto 0 => '0'),
            S => Shift(1 downto 0),
            Y => T0
        );

    Stage2: entity work.Mux4to1_N
        generic map(N => N)
        port map(
            A => T0,
            B => T0(N-5 downto 0) & (3 downto 0 => '0'),
            C => T0(N-9 downto 0) & (7 downto 0 => '0'),
            D => T0(N-13 downto 0) & (11 downto 0 => '0'),
            S => Shift(3 downto 2),
            Y => T1
        );

    Stage3: entity work.Mux4to1_N
        generic map(N => N)
        port map(
            A => T1,
            B => T1(N-17 downto 0) & (15 downto 0 => '0'),
            C => T1(N-33 downto 0) & (31 downto 0 => '0'),
            D => T1(N-49 downto 0) & (47 downto 0 => '0'),
            S => Shift(5 downto 4),
            Y => Y
        );
end architecture Structural;