-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pong_level1 is
    port (
        clk25      : in  std_logic;      -- 25MHz for VGA
        rst        : in  std_logic;      -- Optional reset
        up         : in  std_logic;
        down       : in  std_logic;
        px         : in  unsigned(9 downto 0); -- VGA X pixel
        py         : in  unsigned(9 downto 0); -- VGA Y pixel
        vid_on     : in  std_logic;
        score      : out unsigned(3 downto 0); -- 4-bit score (display as hex)
        rgb        : out std_logic_vector(2 downto 0) -- Output RGB (3-bit)
    );
end entity;

architecture Behavioral of pong_level1 is
    -- Game area
    constant WALL_THICKNESS : integer := 8;
    constant PADDLE_W       : integer := 10;
    constant PADDLE_H       : integer := 60;
    constant BALL_SIZE      : integer := 12;

    -- Paddle position (vertical only)
    signal paddle_y : integer range 0 to 480-PADDLE_H := 210;

    -- Ball position and velocity
    signal ball_x   : integer range 0 to 640-BALL_SIZE := 320;
    signal ball_y   : integer range 0 to 480-BALL_SIZE := 240;
    signal ball_dx  : integer := 2;
    signal ball_dy  : integer := 2;

    -- Score
    signal user_score : unsigned(3 downto 0) := (others => '0');

    -- Frame tick
    signal frame_cnt : integer range 0 to 2047 := 0;
    signal tick      : std_logic := '0';

begin

    -- Simple frame tick generator to slow the game loop
    process(clk25)
    begin
        if rising_edge(clk25) then
            if frame_cnt = 2047 then
                frame_cnt <= 0;
                tick <= '1';
            else
                frame_cnt <= frame_cnt + 1;
                tick <= '0';
            end if;
        end if;
    end process;

    -- Paddle movement
    process(clk25)
    begin
        if rising_edge(clk25) then
            if tick = '1' then
                if up = '1' and paddle_y > 0 then
                    paddle_y <= paddle_y - 4;
                elsif down = '1' and paddle_y < 480-PADDLE_H then
                    paddle_y <= paddle_y + 4;
                end if;
            end if;
        end if;
    end process;

    -- Ball movement and collisions
    process(clk25)
    begin
        if rising_edge(clk25) then
            if tick = '1' then
                -- Ball movement
                ball_x <= ball_x + ball_dx;
                ball_y <= ball_y + ball_dy;

                -- Top and bottom wall collision
                if ball_y <= 0 or ball_y >= 480-BALL_SIZE then
                    ball_dy <= -ball_dy;
                end if;

                -- Right wall collision
                if ball_x >= 640-WALL_THICKNESS-BALL_SIZE then
                    ball_dx <= -ball_dx;
                end if;

                -- Paddle collision
                if ball_x <= PADDLE_W and
                   ball_y + BALL_SIZE > paddle_y and
                   ball_y < paddle_y + PADDLE_H then
                    ball_dx <= -ball_dx;
                    user_score <= user_score + 1;
                end if;

                -- Missed (ball exits left)
                if ball_x < 0 then
                    -- Reset ball and paddle position
                    ball_x <= 320; ball_y <= 240;
                    paddle_y <= 210;
                    user_score <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    -- VGA drawing (RGB: {R,G,B})
    process(px, py, vid_on, ball_x, ball_y, paddle_y)
    begin
        if vid_on = '0' then
            rgb <= "000"; -- Black
        elsif (px < WALL_THICKNESS) or
              (px >= 640-WALL_THICKNESS) or
              (py < WALL_THICKNESS) or
              (py >= 480-WALL_THICKNESS) then
            rgb <= "101"; -- Magenta (walls)
        elsif (px < PADDLE_W and py >= paddle_y and py < paddle_y + PADDLE_H) then
            rgb <= "110"; -- Blue-ish (user paddle)
        elsif (px >= ball_x and px < ball_x + BALL_SIZE and py >= ball_y and py < ball_y + BALL_SIZE) then
            rgb <= "010"; -- Green (ball)
        else
            rgb <= "000"; -- Black
        end if;
    end process;

    -- Score output
    score <= user_score;

end architecture;
