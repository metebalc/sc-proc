library ieee;
use ieee.std_logic_1164.all;

entity NextAddressLogic is
    generic(
        N : positive := 64
    );

    port(
        ExUOut: in std_logic_vector(N-1 downto 0);
        ExUStatus: in std_logic_vector(2 downto 0);
        SextB: in std_logic_vector(N-1 downto 0);
        SextJ: in std_logic_vector(N-1 downto 0);
        PC: in std_logic_vector(N-1 downto 0);

        --Comes from CU
        BrType: in std_logic_vector(2 downto 0);
        PCSrc: in std_logic_vector(1 downto 0);

        IncrPC: out std_logic_vector(N-1 downto 0);
        NextPC: out std_logic_vector(N-1 downto 0)
    );
end NextAddressLogic;

architecture Structural of NextAddressLogic is
    signal BrTrue: std_logic;
    signal NotBranch : std_logic;
    signal T0_SextMUX: std_logic_vector(N-1 downto 0);
    signal T1_BTAJTA: std_logic_vector(N-1 downto 0);
    signal T2_BTA: std_logic_vector(N-1 downto 0);

    signal NBitFour: std_logic_vector(N-1 downto 0);

begin
    NotBranch <= not BrTrue;

    --branch condition check
    BCC: entity work.BranchConditionCheck
        port map(
            BrType => BrType,
            ExUStatus => ExUStatus,
            BrTrue => BrTrue
        ); 
    
    --choosing correct sext
    SextMux: entity work.Mux2to1_N generic map(N => N)
        port map(
            A => SextB,
            B => SextJ,
            S => NotBranch,
            Y => T0_SextMUX
        );

    --calculating correct target address using kogge-stone adder(supported is up to  64 bit for now)
    TargetAddressAdder: entity work.KoggeStoneAdder generic map(N => N)
        port map(
            A => T0_SextMUX,
            B => PC,
            Cin => '0',
            Sum => T1_BTAJTA,
            Cout => open
        );
    
    --PC+4
    NBitFour <= (2 => '1', others => '0');
    PC4: entity work.KoggeStoneAdder generic map(N => N)
        port map(
            A => PC,
            B => NBitFour,
            Cin => '0',
            Sum => IncrPC,
            Cout => open
        );

    --choosing correct BTA
    BTAMux: entity work.Mux2to1_N generic map(N => N)
        port map(
            A => IncrPC,
            B => T1_BTAJTA,
            S => BrTrue,
            Y => T2_BTA
        );
    
    --choosing correct NextPC
    NextPCMux: entity work.Mux4to1_N generic map(N => N)
        port map(
            A => IncrPC,
            B => T2_BTA,
            C => T1_BTAJTA,
            D => ExUOut(N-1 downto 1) & '0',
            S => PCSrc,
            Y => NextPC
        );

end architecture Structural;