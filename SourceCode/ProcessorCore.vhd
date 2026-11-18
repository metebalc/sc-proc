library ieee;
use ieee.std_logic_1164.all;

entity ProcessorCore is
    generic(
        N : positive := 64
    );
    port(
        Clk   : in std_logic;
        Reset : in std_logic;

        -- Instruction memory interface
        Instruction : in std_logic_vector(31 downto 0);
        PCAddress   : out std_logic_vector(N-1 downto 0);

        -- Data memory interface
        MemAddress   : out std_logic_vector(N-1 downto 0);
        MemWriteData : out std_logic_vector(N-1 downto 0);
        MemReadData  : in std_logic_vector(N-1 downto 0);

        MemRd   : out std_logic;
        MemWr   : out std_logic;
        MemSize : out std_logic_vector(2 downto 0)
    );
end ProcessorCore;


architecture Structural of ProcessorCore is
    --PC inputs
    signal NextPC: std_logic_vector(N-1 downto 0);
    --PC outputs
    signal PC: std_logic_vector(N-1 downto 0);


    --Control Unit inputs
    signal Opcode: std_logic_vector(6 downto 0);
    signal Funct3: std_logic_vector(2 downto 0);
    signal Funct7: std_logic_vector(6 downto 0);
    --Control Unit outputs
    signal RegWr: std_logic;
    signal InstAddr: std_logic;
    signal RegInSrc: std_logic;
    signal ExUSrcA: std_logic;
    signal ExUSrcB: std_logic_vector(1 downto 0);
    signal ExUFunc: std_logic_vector(7 downto 0);
    signal PCSrc: std_logic_vector(1 downto 0);
    signal BrType: std_logic_vector(2 downto 0);


    --UpI signals
    signal SextI: std_logic_vector(N-1 downto 0);
    signal SextS: std_logic_vector(N-1 downto 0);
    signal SextB: std_logic_vector(N-1 downto 0);
    signal SextU: std_logic_vector(N-1 downto 0);
    signal SextJ: std_logic_vector(N-1 downto 0);


    --Register File inputs
    signal RS1: std_logic_vector(4 downto 0);
    signal RS2: std_logic_vector(4 downto 0);
    signal RSD: std_logic_vector(4 downto 0);
    --Register File outputs
    signal RS1_OUT: std_logic_vector(N-1 downto 0); 
    signal RS2_OUT: std_logic_vector(N-1 downto 0);


    --MUX outputs
    signal A: std_logic_vector(N-1 downto 0);
    signal B: std_logic_vector(N-1 downto 0);


    -- Execution Unit outputs
    signal ExUOut    : std_logic_vector(N-1 downto 0);
    signal ExUStatus : std_logic_vector(2 downto 0);


    --NAL outputs
    signal IncrPC: std_logic_vector(N-1 downto 0);


    --Writeback MUXES 
    signal WriteBackIntermediate : std_logic_vector(N-1 downto 0);
    signal RegIn : std_logic_vector(N-1 downto 0);

begin
    --Instruction decoding
    Opcode <= Instruction(6 downto 0);
    Funct3 <= Instruction(14 downto 12);
    Funct7 <= Instruction(31 downto 25);

    --Register addresses
    RS1 <= Instruction(19 downto 15);
    RS2 <= Instruction(24 downto 20);
    RSD <= Instruction(11 downto 7);

    MemAddress <= ExUOut;
    MemWriteData <= RS2_OUT;
    PCAddress <= PC;


    --Program Counter
    ProgramCounterInst: entity work.ProgramCounter
        generic map (
        N => N
        )
        port map (
        Clk    => Clk,
        Reset  => Reset,
        NextPC => NextPC,
        PC     => PC
        );

    --Control Unit
    ControlUnitInst: entity work.ControlUnit
        port map(
            --in
            Opcode => Opcode,
            Funct3 => Funct3,
            Funct7 => Funct7,
            --out
            RegWr => RegWr,
            InstAddr => InstAddr,
            RegInSrc => RegInSrc,
            ExUSrcA => ExUSrcA,
            ExUSrcB => ExUSrcB,
            ExUFunc => ExUFunc,
            MemRd => MemRd,
            MemWr => MemWr,
            MemSize => MemSize,
            PCSrc => PCSrc,
            BrType => BrType
        );


    --UpI-X and UpI-F
    UpI_Inst: entity work.ImmediateGenerator generic map(N => N)
        port map(
            Instruction => Instruction,
            SextI => SextI,
            SextS => SextS,
            SextB => SextB,
            SextU => SextU,
            SextJ => SextJ
        ); 


    --Register File
    RegisterFileInst: entity work.RegisterFile generic map(N => N)
        port map(
            Clk => Clk,
            RegWr => RegWr,
            RS1 => RS1,
            RS2 => RS2,
            RSD => RSD,
            RD_in => RegIn,
            RS1_OUT => RS1_OUT,
            RS2_OUT => RS2_OUT
        );

    --A and B outputs from MUXES
    MuxA: entity work.Mux2to1_N generic map(N => N)
    port map(
        A => RS1_OUT,
        B => PC,
        S => ExUSrcA,
        Y => A
    );

    MuxB: entity work.Mux4to1_N generic map(N => N)
    port map(
        A => SextI,
        B => SextS,
        C => SextU,
        D => RS2_OUT,
        S => ExUSrcB,
        Y => B
    );

    --Execution Unit
    ExecutionUnitInst: entity work.ExecutionUnit
        generic map ( 
            N => N
        )
        port map (
            A         => A,
            B         => B,
            ExUFunc   => ExUFunc,
            ExUOut    => ExUOut,
            ExUStatus => ExUStatus
        );


    --Next Address Logic
    NALInst: entity work.NextAddressLogic generic map(N => N)
        port map(
            ExUOut => ExUOut,
            ExUStatus => ExUStatus,
            SextB => SextB,
            SextJ => SextJ,
            PC => PC,
            BrType => BrType,
            PCSrc => PCSrc,

            IncrPC => IncrPC,
            NextPC => NextPC
        );        

    -- Select ExU result or PC+4
    InstAddrMux: entity work.Mux2to1_N
        generic map(N => N)
        port map(
            A => ExUOut,
            B => IncrPC,
            S => InstAddr,
            Y => WriteBackIntermediate
        );

    -- Select ALU/PC+4 result or data memory
    RegInMux: entity work.Mux2to1_N
        generic map(N => N)
        port map(
            A => WriteBackIntermediate,
            B => MemReadData,
            S => RegInSrc,
            Y => RegIn
        );

end architecture Structural;