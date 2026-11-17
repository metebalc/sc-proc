library ieee;
use ieee.std_logic_1164.all;

entity ControlUnit is
    port(
        Opcode: in std_logic_vector(6 downto 0);
        Funct3: in std_logic_vector(2 downto 0);
        Funct7: in std_logic_vector(6 downto 0);

        RegWr: out std_logic;
        InstAddr: out std_logic;
        RegInSrc: out std_logic;
        ExUSrcA: out std_logic;
        ExUSrcB: out std_logic_vector(1 downto 0);
        ExUFunc: out std_logic_vector(7 downto 0);
        MemRd: out std_logic;
        MemWr: out std_logic;
        MemSize: out std_logic_vector(2 downto 0);
        PCSrc: out std_logic_vector(1 downto 0);
        BrType: out std_logic_vector(2 downto 0)
    );
end entity ControlUnit;

architecture Behavioral of ControlUnit is
    -- Intermediate Signals
    signal RfDb, RfWd, IfDb, IfWd : std_logic;
    signal LoadInst, StoreInst, BranchInst : std_logic;
    signal JumpInst, JalrInst, LuiInst, AuipcInst : std_logic;

    signal F3_000, F3_001, F3_010, F3_011 : std_logic;
    signal F3_100, F3_101, F3_110, F3_111 : std_logic;

    signal F7_00, F7_20 : std_logic;

    signal funcClass : std_logic_vector(1 downto 0);
    signal logicFn   : std_logic_vector(1 downto 0);
    signal shiftFn   : std_logic_vector(1 downto 0);

    signal addNSub, extWord : std_logic;

    -- R-Format
    signal isADD, isSUB, isSLL, isSLT, isSLTU : std_logic;
    signal isXOR, isSRL, isSRA, isOR, isAND : std_logic;
    signal isADDW, isSUBW, isSLLW, isSRLW, isSRAW : std_logic;

    -- I-Format
    signal isADDI, isSLTI, isSLTIU : std_logic;
    signal isXORI, isORI, isANDI : std_logic;
    signal isADDIW, isSLLIW, isSRLIW, isSRAIW : std_logic;

    -- Shift Immediate
    signal isSLLI, isSRLI, isSRAI : std_logic;

    -- U-Format
    signal isLUI, isAUIPC : std_logic;

    -- Load Instructions
    signal isLB, isLH, isLW, isLD : std_logic;
    signal isLBU, isLHU, isLWU : std_logic;

    -- Store Instructions
    signal isSB, isSH, isSW, isSD : std_logic;

    -- Branch Instructions
    signal isBEQ, isBNE, isBLT, isBGE : std_logic;
    signal isBLTU, isBGEU : std_logic;

    -- Jump Instructions
    signal isJAL, isJALR : std_logic;

begin
    -- opcode decoder
    RfDb <= '1' when Opcode = "0110011" else '0';
    RfWd <= '1' when Opcode = "0111011" else '0';

    IfDb <= '1' when Opcode = "0010011" else '0';
    IfWd <= '1' when Opcode = "0011011" else '0';

    LoadInst <= '1' when Opcode = "0000011" else '0';
    StoreInst <= '1' when Opcode = "0100011" else '0';
    BranchInst <= '1' when Opcode = "1100011" else '0';
    JumpInst <= '1' when Opcode = "1101111" else '0';
    JalrInst <= '1' when Opcode = "1100111" else '0';
    LuiInst <= '1' when Opcode = "0110111" else '0';
    AuipcInst <= '1' when Opcode = "0010111" else '0';
    
    -- funct3 decoder
    F3_000 <= '1' when Funct3 = "000" else '0';
    F3_001 <= '1' when Funct3 = "001" else '0';
    F3_010 <= '1' when Funct3 = "010" else '0';
    F3_100 <= '1' when Funct3 = "100" else '0';
    F3_011 <= '1' when Funct3 = "011" else '0';
    F3_101 <= '1' when Funct3 = "101" else '0';
    F3_110 <= '1' when Funct3 = "110" else '0';
    F3_111 <= '1' when Funct3 = "111" else '0';

    -- funct7 decoder
    F7_00 <= '1' when Funct7 = "0000000" else '0';
    F7_20 <= '1' when Funct7 = "0100000" else '0';


    -- instruction recognition
    -- R-type
    isADD <= RfDb and F3_000 and F7_00;
    isSUB <= RfDb and F3_000 and F7_20;
    isSLL <= RfDb and F3_001 and F7_00;
    isSLT <= RfDb and F3_010 and F7_00;
    isSLTU <= RfDb and F3_011 and F7_00;
    isXOR <= RfDb and F3_100 and F7_00;
    isSRL <= RfDb and F3_101 and F7_00;
    isSRA <= RfDb and F3_101 and F7_20;
    isOR <= RfDb and F3_110 and F7_00;
    isAND <= RfDb and F3_111 and F7_00;
    isADDW <= RfWd and F3_000 and F7_00;
    isSUBW <= RfWd and F3_000 and F7_20;
    isSLLW <= RfWd and F3_001 and F7_00;
    isSRLW <= RfWd and F3_101 and F7_00;
    isSRAW <= RfWd and F3_101 and F7_20;

    -- I-Format 
    isADDI <= IfDb and F3_000;
    isSLTI <= IfDb and F3_010;
    isSLTIU <= IfDb and F3_011;
    isXORI <= IfDb and F3_100;
    isORI <= IfDb and F3_110;
    isANDI <= IfDb and F3_111;

    -- Shift-immediate 
    -- Bit 25 is part of the shift count
    isSLLI <= '1' when (IfDb = '1' and F3_001 = '1' and Funct7(6 downto 1) = "000000") else '0';
    isSRLI <= '1' when (IfDb = '1' and F3_101 = '1' and Funct7(6 downto 1) = "000000") else '0';
    isSRAI <= '1' when (IfDb = '1' and F3_101 = '1' and Funct7(6 downto 1) = "010000") else '0';

    -- I-Format
    isADDIW <= IfWd and F3_000;
    isSLLIW <= IfWd and F3_001 and F7_00;
    isSRLIW <= IfWd and F3_101 and F7_00;
    isSRAIW <= IfWd and F3_101 and F7_20;

    -- U-Format
    isLUI <= LuiInst;
    isAUIPC <= AuipcInst;

    -- Load Instructions
    isLB <= LoadInst and F3_000;
    isLH <= LoadInst and F3_001;
    isLW <= LoadInst and F3_010;
    isLD <= LoadInst and F3_011;
    isLBU <= LoadInst and F3_100;
    isLHU <= LoadInst and F3_101;
    isLWU <= LoadInst and F3_110;

    -- Store Instructions
    isSB <= StoreInst and F3_000;
    isSH <= StoreInst and F3_001;
    isSW <= StoreInst and F3_010;
    isSD <= StoreInst and F3_011;

    -- Branch Instructions
    isBEQ <= BranchInst and F3_000;
    isBNE <= BranchInst and F3_001;
    isBLT <= BranchInst and F3_100;
    isBGE <= BranchInst and F3_101;
    isBLTU <= BranchInst and F3_110;
    isBGEU <= BranchInst and F3_111;

    -- Jump Instructions
    isJAL <= JumpInst;
    isJALR <= JalrInst and F3_000;

    -- assignment
    RegWr <= RfDb or RfWd or IfDb or IfWd or LoadInst or LuiInst or AuipcInst or JumpInst or JalrInst;
    InstAddr <= '1' when (isJAL = '1' or isJALR = '1') else '0';
    RegInSrc <= '1' when LoadInst = '1' else '0';
    ExUSrcA <= isAUIPC;

    ExUSrcB <=  "00" when (IfDb = '1' or IfWd = '1' or LoadInst = '1' or JalrInst = '1') else
                "01" when StoreInst = '1' else
                "10" when (isLUI = '1' or isAUIPC = '1') else
                "11"; 

    --exufunc = funcclass & logicfn & shiftfn & addnsub & extword
    funcClass <=    "11" when (isSLTU = '1' or isSLTIU = '1') else
                    "10" when (isSLT = '1' or isSLTI = '1') else
                    "01" when (isLUI = '1' or isXOR = '1' or isOR = '1' or isAND = '1' or isXORI = '1' or isORI = '1' or isANDI = '1') else
                    "00";

    logicFn <=  "01" when (isXOR = '1' or isXORI = '1') else
                "10" when (isOR = '1' or isORI = '1') else
                "11" when (isAND = '1' or isANDI = '1') else
                "00";

    shiftFn <=  "11" when (isSRA = '1' or isSRAW = '1' or isSRAI = '1' or isSRAIW = '1') else
                "10" when (isSRL = '1' or isSRLW = '1' or isSRLI = '1' or isSRLIW = '1') else
                "01" when (isSLL = '1' or isSLLW = '1' or isSLLI = '1' or isSLLIW = '1') else
                "00";

    addNSub <= '1' when (isSUB = '1' or isSUBW = '1' or isSLT = '1' or isSLTU = '1' or isSLTI = '1' or isSLTIU = '1' or BranchInst = '1') else '0';

    extWord <= '1' when (isADDW = '1' or isSUBW = '1' or isSLLW = '1' or isSRLW = '1' or isSRAW = '1' or isADDIW = '1' or isSLLIW = '1' or isSRLIW = '1' or isSRAIW = '1') else '0';

    ExUFunc <= funcClass & logicFn & shiftFn & addNSub & extWord;

    MemRd <= LoadInst;
    MemWr <= StoreInst;
    MemSize <=  "001" when isLBU = '1' else
                "010" when isLHU = '1' else
                "011" when isLWU = '1' else
                "100" when (isLD = '1' or isSB = '1') else
                "101" when (isLB = '1' or isSH = '1') else
                "110" when (isLH = '1' or isSW = '1') else
                "111" when (isLW = '1' or isSD = '1') else
                "000";

    PCSrc <=    "01" when BranchInst = '1' else
                "10" when JumpInst = '1' else
                "11" when isJALR = '1' else
                "00";

    BrType <=   "000" when isBEQ = '1' else
                "001" when isBNE = '1' else
                "100" when isBLT = '1' else
                "101" when isBGE = '1' else
                "110" when isBLTU = '1' else
                "111" when isBGEU = '1' else
                "010";
    
end architecture Behavioral;