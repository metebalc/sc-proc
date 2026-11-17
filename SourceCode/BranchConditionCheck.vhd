library ieee;
use ieee.std_logic_1164.all;

entity BranchConditionCheck is
    port(
        BrType: in std_logic_vector(2 downto 0);
        ExUStatus: in std_logic_vector(2 downto 0);

        BrTrue: out std_logic
    );
end BranchConditionCheck;

architecture Structure of BranchConditionCheck is
    signal IntermediateBEQ, IntermediateBNE, IntermediateBLT, IntermediateBGE, IntermediateBLTU, IntermediateBGEU : std_logic; 
    signal Zero, AltB, AltBu : std_logic;
begin
    Zero <= ExUStatus(2); 
    AltB <= ExUStatus(1); 
    AltBu <= ExUStatus(0); 

    IntermediateBEQ <= '1' when (BrType = "000" and Zero = '1') else '0';
    IntermediateBNE <= '1' when (BrType = "001" and Zero = '0') else '0';
    IntermediateBLT <= '1' when (BrType = "100" and AltB = '1') else '0';
    IntermediateBGE <= '1' when (BrType = "101" and AltB = '0') else '0';
    IntermediateBLTU <= '1' when (BrType = "110" and AltBu = '1') else '0';
    IntermediateBGEU <= '1' when (BrType = "111" and AltBu = '0') else '0';

    BrTrue <= IntermediateBEQ or IntermediateBNE or IntermediateBLT or IntermediateBGE or IntermediateBLTU or IntermediateBGEU;
end architecture Structure;