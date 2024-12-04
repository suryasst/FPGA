library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Ball_Logic is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        racket_y  : in  INTEGER;
        ball_x    : out INTEGER range 0 to 639;
        ball_y    : out INTEGER range 0 to 479;
        score     : out INTEGER
    );
end Ball_Logic;

architecture Behavioral of Ball_Logic is
    signal ball_pos_x : INTEGER range 0 to 639 := 320;
    signal ball_pos_y : INTEGER range 0 to 479 := 240;
    signal ball_dx    : INTEGER := -5; -- Horizontal speed
    signal ball_dy    : INTEGER := 5;  -- Vertical speed
    signal player_score : INTEGER := 0;

    constant RACKET_WIDTH : integer := 10;
    constant RACKET_HEIGHT: integer := 60;

begin
    process(clk, reset)
    begin
        if reset = '1' then
            ball_pos_x <= 320;
            ball_pos_y <= 240;
            ball_dx <= -5;
            ball_dy <= 5;
            player_score <= 0;
        elsif rising_edge(clk) then
            -- Ball movement
            ball_pos_x <= ball_pos_x + ball_dx;
            ball_pos_y <= ball_pos_y + ball_dy;

            -- Collision with top and bottom walls
            if ball_pos_y <= 0 or ball_pos_y >= 479 then
                ball_dy <= -ball_dy;
            end if;

            -- Collision with player's racket
            if ball_pos_x <= RACKET_WIDTH and
               ball_pos_y >= racket_y and ball_pos_y <= racket_y + RACKET_HEIGHT then
                ball_dx <= -ball_dx;
                player_score <= player_score + 1;
            end if;

            -- Reset ball if missed
            if ball_pos_x <= 0 then
                ball_pos_x <= 320;
                ball_pos_y <= 240;
            end if;
        end if;
    end process;

    ball_x <= ball_pos_x;
    ball_y <= ball_pos_y;
    score <= player_score;
end Behavioral;
