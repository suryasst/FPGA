library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Score_Display is
    Port (
        score : in  INTEGER range 0 to 15;
        seg   : out STD_LOGIC_VECTOR(6 downto 0)
    );
end Score_Display;

architecture Behavioral of Score_Display is
    type SEGMENT_ARRAY is array (0 to 15) of STD_LOGIC_VECTOR(6 downto 0);
    constant SEGMENTS : SEGMENT_ARRAY := (
        "0000001", -- 0
        "1001111", -- 1
        "0010010", -- 2
        "0000110", -- 3
        "1001100", -- 4
        "0100100", -- 5
        "0100000", -- 6
        "0001111", -- 7
        "0000000", -- 8
        "0000100", -- 9
        "0001000", -- A
        "1100000", -- B
        "0110001", -- C
        "1000010", -- D
        "0110000", -- E
        "0111000"  -- F
    );
begin
    seg <= SEGMENTS(score);
end Behavioral;
