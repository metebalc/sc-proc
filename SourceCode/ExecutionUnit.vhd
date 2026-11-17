library ieee;
use ieee.std_logic_1164.all;

entity ExecutionUnit is
    generic(
        N : positive := 64
    );
    port(
        A, B: in std_logic_vector(N-1 downto 0);
        ExUFunc: in std_logic_vector(7 downto 0);
        ExUOut: out std_logic_vector(N-1 downto 0);
        ExUStatus: out std_logic_vector(2 downto 0)
    );
end ExecutionUnit;

architecture Structural of ExecutionUnit is
    signal FuncClass, LogicFn, ShiftFn: std_logic_vector(1 downto 0); 
    signal AddnSub, ExtWord: std_logic;

    signal B_intermediate: std_logic_vector(N-1 downto 0);

    signal Sum: std_logic_vector(N-1 downto 0);
    signal Carry: std_logic;

    signal A_intermediate: std_logic_vector(N-1 downto 0);

    signal ShiftCount: std_logic_vector(5 downto 0);

    signal A_shiftedSLL: std_logic_vector(N-1 downto 0);
    signal A_shiftedSRL: std_logic_vector(N-1 downto 0);
    signal A_shiftedSRA: std_logic_vector(N-1 downto 0);

    signal AdderSLLMux_intermediate: std_logic_vector(N-1 downto 0);
    signal MUX1_intermediate: std_logic_vector(N-1 downto 0);
    signal SRLSRAMux_intermediate: std_logic_vector(N-1 downto 0);
    signal MUX2_intermediate: std_logic_vector(N-1 downto 0);
    signal ArithmeticShiftResult: std_logic_vector(N-1 downto 0);

    signal logicOut: std_logic_vector(N-1 downto 0);

    signal Ovfl: std_logic;
    signal Zero, AltBu, AltB: std_logic;
begin
    FuncClass <= ExUFunc(7 downto 6);
    LogicFn <= ExUFunc(5 downto 4);
    ShiftFn <= ExUFunc(3 downto 2);
    AddnSub <= ExUFunc(1);
    ExtWord <= ExUFunc(0);

    ShiftCount <= (B(5) and not ExtWord) & B(4 downto 0);

    --Deciding addition or subs
    AddnSubMUX: entity work.Mux2to1_N generic map(N => N)
        port map(
            A => B,
            B => not B,
            S => AddnSub,
            Y => B_intermediate
        );
    
    --Full Adder
    FullAdder: entity work.KoggeStoneAdder generic map(N => N)
        port map(
            A => A,
            B => B_intermediate,
            Cin => AddnSub,
            Sum => Sum,
            Cout => Carry
        );

    Ovfl <= (not (A(N-1) xor B_intermediate(N-1))) and (A(N-1) xor Sum(N-1));
    Zero <= not (or Sum);
    AltB  <= Sum(N-1) xor Ovfl;
    AltBu <= not Carry;

    --Shifters
    ShiftMUX: entity work.Mux2to1_N generic map(N => N)
        port map(
            A => A,
            B => A(31 downto 0) & A(63 downto 32),
            S => ShiftFn(1) and ExtWord,
            Y => A_intermediate
        );
    SLL64: entity work.BarrelShiftLeft_N generic map(N => N)
        port map(
            A => A_intermediate,
            Shift => ShiftCount,
            Y => A_shiftedSLL
        );
    SRL64: entity work.BarrelShiftRight_N generic map(N => N)
        port map(
            A => A_intermediate,
            Shift => ShiftCount,
            Y => A_shiftedSRL
        );
    SRA64: entity work.BarrelShiftRightArith_N generic map(N => N)
        port map(
            A => A_intermediate,
            Shift => ShiftCount,
            Y => A_shiftedSRA
        );
    
    AdderSLL_Mux: entity work.Mux2to1_N generic map(N => N)
        port map(
            A => Sum,
            B => A_shiftedSLL,
            S => ShiftFn(0),
            Y => AdderSLLMux_intermediate
        );

    SignExtend_Mux1: entity work.Mux2to1_N generic map(N => N)
        port map(
            A => AdderSLLMux_intermediate,
            B => (N-1 downto 32 => AdderSLLMux_intermediate(31)) & AdderSLLMux_intermediate(31 downto 0),
            S => ExtWord,
            Y => MUX1_intermediate
        );

    SRLSRA_Mux: entity work.Mux2to1_N generic map(N => N)
        port map(
            A => A_shiftedSRL,
            B => A_shiftedSRA,
            S => ShiftFn(0),
            Y => SRLSRAMux_intermediate
        );

    SignExtend_Mux2: entity work.Mux2to1_N generic map(N => N)
        port map(
            A => SRLSRAMux_intermediate,
            B => (N-1 downto 32 => SRLSRAMux_intermediate(63)) & SRLSRAMux_intermediate(63 downto 32),
            S => ExtWord,
            Y => MUX2_intermediate
        );
    
    CombineShiftMux: entity work.Mux2to1_N generic map(N => N)
        port map(
            A => MUX1_intermediate,
            B => MUX2_intermediate,
            S => ShiftFn(1),
            Y => ArithmeticShiftResult
        );

    --Logic Unit
    LogicUnit: entity work.LogicUnit generic map(N => N)
        port map(
            A => A,
            B => B,
            LogicFn => LogicFn,
            Y => logicOut
        );

    --Determining ExUOut and other outs
    ExUStatus <= Zero & AltB & AltBu;

    FuncClassMux: entity work.Mux4to1_N generic map(N => N)
        port map(
            A => ArithmeticShiftResult,
            B => logicOut,
            C => (N-1 downto 1 => '0') & AltB,
            D => (N-1 downto 1 => '0') & AltBu,
            S => FuncClass,
            Y => ExUOut
        );
end Structural;
