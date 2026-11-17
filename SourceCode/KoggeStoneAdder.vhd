library ieee;
use ieee.std_logic_1164.all;

entity KoggeStoneAdder is
    generic(
        N : positive := 64
    );
    port(
        A, B: in std_logic_vector(N-1 downto 0);
        Cin: in std_logic;
        
        Sum: out std_logic_vector(N-1 downto 0);
        Cout: out std_logic
    );

end KoggeStoneAdder;

architecture Behavioral of KoggeStoneAdder is
    type PrefixArray is array (0 to 6) of std_logic_vector(N-1 downto 0);

    signal P: std_logic_vector(N-1 downto 0);
    signal G: std_logic_vector(N-1 downto 0);
    
    signal P_stage : PrefixArray;
    signal G_stage : PrefixArray;

    signal C_intermediate: std_logic_vector(N-1 downto 0);
begin 
    --Pre processing (group generate and propagate)
    PG: for i in 0 to N-1 generate
        P(i) <= A(i) xor B(i);
        G(i) <= A(i) and B(i);
    end generate;

    --CLA Network
    P_stage(0) <= P;
    G_stage(0) <= G;

    KSA: for s in 0 to 5 generate
        Prefix: for i in 0 to N-1 generate
            Combine: if i >= 2**s generate
                P_stage(s+1)(i) <= P_stage(s)(i) and P_stage(s)(i - 2**s);

                G_stage(s+1)(i) <= G_stage(s)(i) or (P_stage(s)(i) and G_stage(s)(i - 2**s));
            end generate;

            PassThrough: if i < 2**s generate
                P_stage(s+1)(i) <= P_stage(s)(i);
                G_stage(s+1)(i) <= G_stage(s)(i);
            end generate;

        end generate;
    end generate;

    --Post processing (getting sums and carries) Limited to 6 stages or 64 bits. Needs generalization for proper N bits
    C_intermediate(0) <= Cin;

    Carry: for i in 1 to N-1 generate
        C_intermediate(i) <= G_stage(6)(i-1) or (P_stage(6)(i-1) and Cin);
    end generate;

    S: for i in 0 to N-1 generate
        Sum(i) <= P(i) xor C_intermediate(i);
    end generate;

    Cout <= G_stage(6)(N-1) or (P_stage(6)(N-1) and Cin);

end architecture Behavioral;