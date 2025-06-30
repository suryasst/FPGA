library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pong_level2 is
    port (
        clk25     : in  std_logic;      -- 25MHz for VGA
        rst       : in  std_logic;
        up        : in  std_logic;
        down      : in  std_logic;
        pause_btn : in  std_logic;
        px        : in  unsigned(9 downto 0); -- VGA X pixel
        py        : in  unsigned(9 downto 0); -- VGA Y pixel
        vid_on    : in  std_logic;
        user_score: out unsigned(3 downto 0); -- 4-bit score (hex)
        cpu_score : out unsigned(3 downto 0);
        rgb       : out std_logic_vector(2 downto 0)
    );
end entity;

architecture Behavioral of pong_level2 is
    constant WALL_THICKNESS : integer := 8;
    constant PADDLE_W       : integer := 10;
    constant PADDLE_H       : integer := 60;
    constant BALL_SIZE      : integer := 12;

    -- Paddle positions
    signal paddle_y   : integer range 0 to 480-PADDLE_H := 210; -- User
    signal cpu_y      : integer range 0 to 480-PADDLE_H := 210; -- Computer

    -- Ball position and velocity
    signal ball_x     : integer range 0 to 640-BALL_SIZE := 320;
    signal ball_y     : integer range 0 to 480-BALL_SIZE := 240;
    signal ball_dx    : integer := 2;
    signal ball_dy    : integer := 2;
    signal ball_speed : integer := 2;   -- Ball speed magnitude (always positive)
    signal rally_cnt  : integer range 0 to 15 := 0;

    -- Scoring
    signal uscore     : unsigned(3 downto 0) := (others=>'0');
    signal cscore     : unsigned(3 downto 0) := (others=>'0');

    -- Pause
    signal paused     : std_logic := '0';
    signal pause_last : std_logic := '0';

    -- Frame tick
    signal frame_cnt  : integer range 0 to 2047 := 0;
    signal tick       : std_logic := '0';

    -- Internal for AI
    signal cpu_center : integer;

begin

    -- Frame tick generator (same as Level 1)
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

    -- Pause logic: toggle on BTN3 edge
    process(clk25)
    begin
        if rising_edge(clk25) then
            if pause_btn = '1' and pause_last = '0' then
                paused <= not paused;
            end if;
            pause_last <= pause_btn;
        end if;
    end process;

    -- Paddle movement (user)
    process(clk25)
    begin
        if rising_edge(clk25) then
            if tick = '1' and paused = '0' then
                if up = '1' and paddle_y > 0 then
                    paddle_y <= paddle_y - 4;
                elsif down = '1' and paddle_y < 480-PADDLE_H then
                    paddle_y <= paddle_y + 4;
                end if;
            end if;
        end if;
    end process;

    -- CPU Paddle "AI": move towards ball y
    process(clk25)
    begin
        if rising_edge(clk25) then
            if tick = '1' and paused = '0' then
                cpu_center <= cpu_y + (PADDLE_H/2);
                if cpu_center < ball_y then
                    if cpu_y < 480-PADDLE_H then
                        cpu_y <= cpu_y + 3;
                    end if;
                elsif cpu_center > ball_y + BALL_SIZE then
                    if cpu_y > 0 then
                        cpu_y <= cpu_y - 3;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Ball movement & game logic
    process(clk25)
    begin
        if rising_edge(clk25) then
            if tick = '1' and paused = '0' then
                -- Ball movement
                ball_x <= ball_x + ball_dx;
                ball_y <= ball_y + ball_dy;

                -- Top and bottom wall collision
                if ball_y <= 0 or ball_y >= 480-BALL_SIZE then
                    ball_dy <= -ball_dy;
                end if;

                -- User paddle collision
                if ball_dx < 0 and
                   ball_x <= PADDLE_W and
                   ball_y + BALL_SIZE > paddle_y and
                   ball_y < paddle_y + PADDLE_H then
                    ball_dx <= integer(abs(ball_speed));
                    rally_cnt <= rally_cnt + 1;
                -- CPU paddle collision
                elsif ball_dx > 0 and
                   ball_x + BALL_SIZE >= 640-PADDLE_W and
                   ball_y + BALL_SIZE > cpu_y and
                   ball_y < cpu_y + PADDLE_H then
                    ball_dx <= -integer(abs(ball_speed));
                    rally_cnt <= rally_cnt + 1;
                end if;

                -- Rally count: after 8, increase speed
                if rally_cnt = 8 then
                    ball_speed <= integer(ball_speed * 11 / 10); -- +10%
                    rally_cnt <= 0;
                    -- Keep ball_dx sign
                    if ball_dx < 0 then
                        ball_dx <= -abs(ball_speed);
                    else
                        ball_dx <= abs(ball_speed);
                    end if;
                end if;

                -- Ball out of left
                if ball_x < 0 then
                    cscore <= cscore + 1;
                    -- Reset
                    ball_x <= 320; ball_y <= 240;
                    ball_speed <= 2;
                    ball_dx <= 2;
                    ball_dy <= 2;
                    rally_cnt <= 0;
                end if;

                -- Ball out of right
                if ball_x > 640-BALL_SIZE then
                    uscore <= uscore + 1;
                    ball_x <= 320; ball_y <= 240;
                    ball_speed <= 2;
                    ball_dx <= -2;
                    ball_dy <= 2;
                    rally_cnt <= 0;
                end if;
            end if;
        end if;
    end process;

    -- VGA Drawing (RGB)
    process(px, py, vid_on, ball_x, ball_y, paddle_y, cpu_y)
    begin
        if vid_on = '0' then
            rgb <= "000";
        elsif (px < WALL_THICKNESS) or
              (py < WALL_THICKNESS) or
              (py >= 480-WALL_THICKNESS) then
            rgb <= "101"; -- Magenta (walls)
        elsif (px < PADDLE_W and py >= paddle_y and py < paddle_y + PADDLE_H) then
            rgb <= "110"; -- Blue-ish (user paddle)
        elsif (px >= 640-PADDLE_W and py >= cpu_y and py < cpu_y + PADDLE_H) then
            rgb <= "100"; -- Red (CPU paddle)
        elsif (px >= ball_x and px < ball_x + BALL_SIZE and py >= ball_y and py < ball_y + BALL_SIZE) then
            rgb <= "010"; -- Green (ball)
        else
            rgb <= "000";
        end if;
    end process;

    user_score <= uscore;
    cpu_score  <= cscore;

end architecture;
