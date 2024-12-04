library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Racket_Control is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        btn_up    : in  STD_LOGIC;
        btn_down  : in  STD_LOGIC;
        racket_y  : out INTEGER range 0 to 479
    );
end Racket_Control;

architecture Behavioral of Racket_Control is
    constant RACKET_HEIGHT : integer := 60;
    signal racket_pos : INTEGER range 0 to 479 := 240; -- Initial position
begin
    process(clk, reset)
    begin
        if reset = '1' then
            racket_pos <= 240;
        elsif rising_edge(clk) then
            if btn_up = '1' and racket_pos > 0 then
                racket_pos <= racket_pos - 5;
            elsif btn_down = '1' and racket_pos < 479 - RACKET_HEIGHT then
                racket_pos <= racket_pos + 5;
            end if;
        end if;
    end process;

    racket_y <= racket_pos;
end Behavioral;
