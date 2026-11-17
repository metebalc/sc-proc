library ieee;
use ieee.std_logic_1164.all;

package MathUtils is
    function ceil_log2(n : positive) return natural;
end package MathUtils;

package body MathUtils is

    function ceil_log2(n : positive) return natural is
        variable v : natural := n - 1;
        variable result : natural := 0;
    begin
        while v > 0 loop
            v := v / 2;
            result := result + 1;
        end loop;

        return result;
    end function;

end package body MathUtils;