library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pong_level3 is
    port (
        clk25     : in  std_logic;
        rst       : in  std_logic;
        up        : in  std_logic;
        down      : in  std_logic;
        pause_btn : in  std_logic;
        px        : in  unsigned(9 downto 0);
        py        : in  unsigned(9 downto 0);
        vid_on    : in  std_logic;
        user_score: out unsigned(3 downto 0);
        cpu_score : out unsigned(3 downto 0);
        rgb       : out std_logic_vector(2 downto 0)
    );
end entity;

architecture Behavioral of pong_level3 is
    constant WALL_THICKNESS : integer := 8;
    constant PADDLE_W       : integer := 10;
    constant PADDLE_H       : integer := 60;
    constant BALL_SIZE      : integer := 12;
    constant GHOST_SIZE     : integer := 13; -- Bitmap is 13x13

    -- User and CPU paddle positions
    signal paddle_y : integer range 0 to 480-PADDLE_H := 210;
    signal cpu_y    : integer range 0 to 480-PADDLE_H := 210;

    -- Ball
    signal ball_x   : integer range 0 to 640-BALL_SIZE := 320;
    signal ball_y   : integer range 0 to 480-BALL_SIZE := 240;
    signal ball_dx  : integer := 2;
    signal ball_dy  : integer := 2;
    signal ball_speed : integer := 2;
    signal rally_cnt  : integer range 0 to 15 := 0;

    -- Scores
    signal uscore   : unsigned(3 downto 0) := (others=>'0');
    signal cscore   : unsigned(3 downto 0) := (others=>'0');

    -- Pause
    signal paused     : std_logic := '0';
    signal pause_last : std_logic := '0';

    -- Frame tick
    signal frame_cnt  : integer range 0 to 2047 := 0;
    signal tick       : std_logic := '0';

    -- Ghosts: 2 ghosts for example
    type ghost_t is record
        x   : integer range 0 to 640-GHOST_SIZE;
        y   : integer range 0 to 480-GHOST_SIZE;
        dx  : integer range -3 to 3;
        dy  : integer range -3 to 3;
        on  : std_logic;
    end record;

    signal ghost0 : ghost_t := (100, 100, 2, 1, '1');
    signal ghost1 : ghost_t := (300, 250, -2, 2, '1');

    -- Ghost bitmap (see below)
    type ghost_bitmap_t is array(0 to 12) of std_logic_vector(12 downto 0);
    constant ghost_bitmap : ghost_bitmap_t := (
        "0110000000110",
        "1010000000101",
        "1111000001111",
        "0011011101100",
        "0000111110000",
        "0001001001000",
        "0001011101000",
        "0001110111000",
        "0000111110000",
        "0010101010100",
        "1111000001111",
        "1010000000101",
        "0110000000110"
    );

    -- Internal
    signal cpu_center : integer;

begin
    -- Frame tick generator (same as before)
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

    -- Pause logic
    process(clk25)
    begin
        if rising_edge(clk25) then
            if pause_btn = '1' and pause_last = '0' then
                paused <= not paused;
            end if;
            pause_last <= pause_btn;
        end if;
    end process;

    -- User paddle movement
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

    -- CPU paddle AI
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

    -- Ball and ghost logic
    process(clk25)
    begin
        if rising_edge(clk25) then
            if tick = '1' and paused = '0' then
                -- Ball movement
                ball_x <= ball_x + ball_dx;
                ball_y <= ball_y + ball_dy;

                -- Walls
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
                    ball_speed <= integer(ball_speed * 11 / 10);
                    rally_cnt <= 0;
                    if ball_dx < 0 then
                        ball_dx <= -abs(ball_speed);
                    else
                        ball_dx <= abs(ball_speed);
                    end if;
                end if;

                -- Ball out left
                if ball_x < 0 then
                    cscore <= cscore + 1;
                    ball_x <= 320; ball_y <= 240;
                    ball_speed <= 2;
                    ball_dx <= 2;
                    ball_dy <= 2;
                    rally_cnt <= 0;
                end if;
                -- Ball out right
                if ball_x > 640-BALL_SIZE then
                    uscore <= uscore + 1;
                    ball_x <= 320; ball_y <= 240;
                    ball_speed <= 2;
                    ball_dx <= -2;
                    ball_dy <= 2;
                    rally_cnt <= 0;
                end if;

                -- --- GHOST 0 ---
                if ghost0.on = '1' then
                    ghost0.x <= ghost0.x + ghost0.dx;
                    ghost0.y <= ghost0.y + ghost0.dy;
                    -- Bounce top/bottom
                    if ghost0.y <= 0 or ghost0.y >= 480-GHOST_SIZE then
                        ghost0.dy <= -ghost0.dy;
                    end if;
                    -- Remove at left/right
                    if ghost0.x < 0 or ghost0.x > 640-GHOST_SIZE then
                        ghost0.on <= '0';
                    end if;
                    -- Ball hits ghost (moving L->R)
                    if ball_dx > 0 and ghost0.on = '1' and
                       ball_x + BALL_SIZE > ghost0.x and
                       ball_x < ghost0.x + GHOST_SIZE and
                       ball_y + BALL_SIZE > ghost0.y and
                       ball_y < ghost0.y + GHOST_SIZE then
                        ghost0.on <= '0';
                        uscore <= uscore + 1;
                    end if;
                    -- Ghost reaches left/user paddle
                    if ghost0.x <= PADDLE_W and
                       ghost0.y + GHOST_SIZE > paddle_y and
                       ghost0.y < paddle_y + PADDLE_H then
                        ghost0.on <= '0';
                        uscore <= uscore - 1;
                    end if;
                end if;

                -- --- GHOST 1 ---
                if ghost1.on = '1' then
                    ghost1.x <= ghost1.x + ghost1.dx;
                    ghost1.y <= ghost1.y + ghost1.dy;
                    if ghost1.y <= 0 or ghost1.y >= 480-GHOST_SIZE then
                        ghost1.dy <= -ghost1.dy;
                    end if;
                    if ghost1.x < 0 or ghost1.x > 640-GHOST_SIZE then
                        ghost1.on <= '0';
                    end if;
                    if ball_dx > 0 and ghost1.on = '1' and
                       ball_x + BALL_SIZE > ghost1.x and
                       ball_x < ghost1.x + GHOST_SIZE and
                       ball_y + BALL_SIZE > ghost1.y and
                       ball_y < ghost1.y + GHOST_SIZE then
                        ghost1.on <= '0';
                        uscore <= uscore + 1;
                    end if;
                    if ghost1.x <= PADDLE_W and
                       ghost1.y + GHOST_SIZE > paddle_y and
                       ghost1.y < paddle_y + PADDLE_H then
                        ghost1.on <= '0';
                        uscore <= uscore - 1;
                    end if;
                end if;

                -- Ghost respawn (basic example: if both off, respawn after center)
                if ghost0.on = '0' and ghost1.on = '0' then
                    ghost0.x <= 100; ghost0.y <= 100; ghost0.dx <= 2; ghost0.dy <= 1; ghost0.on <= '1';
                    ghost1.x <= 300; ghost1.y <= 250; ghost1.dx <= -2; ghost1.dy <= 2; ghost1.on <= '1';
                end if;
            end if;
        end if;
    end process;

    -- VGA Drawing
    process(px, py, vid_on, ball_x, ball_y, paddle_y, cpu_y, ghost0, ghost1)
        function ghost_pixel(g : ghost_t) return std_logic is
            variable gx, gy : integer;
        begin
            gx := to_integer(px) - g.x;
            gy := to_integer(py) - g.y;
            if g.on = '1' and gx >= 0 and gx < 13 and gy >= 0 and gy < 13 then
                return ghost_bitmap(gy)(12-gx);
            else
                return '0';
            end if;
        end function;
    begin
        if vid_on = '0' then
            rgb <= "000";
        elsif (px < WALL_THICKNESS) or
              (py < WALL_THICKNESS) or
              (py >= 480-WALL_THICKNESS) then
            rgb <= "101"; -- Magenta (walls)
        elsif (px < PADDLE_W and py >= paddle_y and py < paddle_y + PADDLE_H) then
            rgb <= "110"; -- User paddle
        elsif (px >= 640-PADDLE_W and py >= cpu_y and py < cpu_y + PADDLE_H) then
            rgb <= "100"; -- CPU paddle
        elsif (px >= ball_x and px < ball_x + BALL_SIZE and py >= ball_y and py < ball_y + BALL_SIZE) then
            rgb <= "010"; -- Ball
        elsif ghost_pixel(ghost0) = '1' or ghost_pixel(ghost1) = '1' then
            rgb <= "111"; -- Ghosts (white)
        else
            rgb <= "000";
        end if;
    end process;

    user_score <= uscore;
    cpu_score  <= cscore;

end architecture;
