library ieee;
use ieee.std_logic_1164.all;

entity DataMemory is
    generic(
        N : positive := 64
    );
    port(
        Clk       : in std_logic;
        Address   : in std_logic_vector(N-1 downto 0);
        WriteData : in std_logic_vector(N-1 downto 0);
        MemRd     : in std_logic;
        MemWr     : in std_logic;
        MemSize   : in std_logic_vector(2 downto 0);
        ReadData  : out std_logic_vector(N-1 downto 0)
    );
end DataMemory;