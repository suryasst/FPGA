library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        CLK100MHZ : in std_logic;
        BTN       : in std_logic_vector(3 downto 0);
        SW        : in std_logic_vector(3 downto 0);
        VGA_HS    : out std_logic;
        VGA_VS    : out std_logic;
        VGA_R     : out std_logic_vector(3 downto 0);
        VGA_G     : out std_logic_vector(3 downto 0);
        VGA_B     : out std_logic_vector(3 downto 0);
        -- Two 7-segment displays: left (user), right (computer)
        SEG7_L    : out std_logic_vector(6 downto 0); -- User
        SEG7_R    : out std_logic_vector(6 downto 0)  -- CPU
    );
end entity;

architecture Behavioral of top is

    -- Clock divider: Generate 25 MHz for VGA
    signal clk25 : std_logic := '0';
    signal clkdiv : integer range 0 to 1 := 0;

    -- VGA controller signals
    signal px, py : unsigned(9 downto 0);
    signal vid_on : std_logic;
    signal rgb1, rgb2, rgb3 : std_logic_vector(2 downto 0);
    signal rgb_muxed : std_logic_vector(2 downto 0);

    -- Scores for each level
    signal score1_user : unsigned(3 downto 0);
    signal score2_user, score2_cpu : unsigned(3 downto 0);
    signal score3_user, score3_cpu : unsigned(3 downto 0);

    -- Selected score
    signal user_score_disp, cpu_score_disp : unsigned(3 downto 0);

    -- 7-segment decoder signals
    function seg7_decode(x : unsigned(3 downto 0)) return std_logic_vector is
        variable seg : std_logic_vector(6 downto 0);
    begin
        case x is
            when "0000" => seg := "1000000"; -- 0
            when "0001" => seg := "1111001"; -- 1
            when "0010" => seg := "0100100"; -- 2
            when "0011" => seg := "0110000"; -- 3
            when "0100" => seg := "0011001"; -- 4
            when "0101" => seg := "0010010"; -- 5
            when "0110" => seg := "0000010"; -- 6
            when "0111" => seg := "1111000"; -- 7
            when "1000" => seg := "0000000"; -- 8
            when "1001" => seg := "0010000"; -- 9
            when "1010" => seg := "0001000"; -- A
            when "1011" => seg := "0000011"; -- b
            when "1100" => seg := "1000110"; -- C
            when "1101" => seg := "0100001"; -- d
            when "1110" => seg := "0000110"; -- E
            when "1111" => seg := "0001110"; -- F
            when others => seg := "1111111";
        end case;
        return seg;
    end function;

begin
    -- Clock divider for 25MHz VGA clock (from 100MHz Zybo clock)
    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if clkdiv = 1 then
                clk25 <= not clk25;
                clkdiv <= 0;
            else
                clkdiv <= clkdiv + 1;
            end if;
        end if;
    end process;

    -- VGA timing generator
    vga_inst : entity work.vga_controller
        port map (
            clk    => clk25,
            hsync  => VGA_HS,
            vsync  => VGA_VS,
            vid_on => vid_on,
            px     => px,
            py     => py
        );

    -- Level 1 Pong (single player)
    pong1 : entity work.pong_level1
        port map (
            clk25   => clk25,
            rst     => '0',
            up      => BTN(0),
            down    => BTN(1),
            px      => px,
            py      => py,
            vid_on  => vid_on,
            score   => score1_user,
            rgb     => rgb1
        );

    -- Level 2 Pong (vs CPU)
    pong2 : entity work.pong_level2
        port map (
            clk25     => clk25,
            rst       => '0',
            up        => BTN(0),
            down      => BTN(1),
            pause_btn => BTN(3),
            px        => px,
            py        => py,
            vid_on    => vid_on,
            user_score=> score2_user,
            cpu_score => score2_cpu,
            rgb       => rgb2
        );

    -- Level 3 Pong (ghosts)
    pong3 : entity work.pong_level3
        port map (
            clk25     => clk25,
            rst       => '0',
            up        => BTN(0),
            down      => BTN(1),
            pause_btn => BTN(3),
            px        => px,
            py        => py,
            vid_on    => vid_on,
            user_score=> score3_user,
            cpu_score => score3_cpu,
            rgb       => rgb3
        );

    -- Select active level
    process(SW, rgb1, rgb2, rgb3, score1_user, score2_user, score2_cpu, score3_user, score3_cpu)
    begin
        case SW(3 downto 0) is
            when "0000" => -- Level 1
                rgb_muxed <= rgb1;
                user_score_disp <= score1_user;
                cpu_score_disp <= (others => '0'); -- not used
            when "0001" => -- Level 2
                rgb_muxed <= rgb2;
                user_score_disp <= score2_user;
                cpu_score_disp <= score2_cpu;
            when "0010" => -- Level 3
                rgb_muxed <= rgb3;
                user_score_disp <= score3_user;
                cpu_score_disp <= score3_cpu;
            when others =>
                rgb_muxed <= "000";
                user_score_disp <= (others => '0');
                cpu_score_disp  <= (others => '0');
        end case;
    end process;

    -- Connect 3-bit output to VGA 4-bit buses (duplicate MSB for simple color)
    VGA_R <= rgb_muxed(2) & rgb_muxed(2) & rgb_muxed(2) & '0';
    VGA_G <= rgb_muxed(1) & rgb_muxed(1) & rgb_muxed(1) & '0';
    VGA_B <= rgb_muxed(0) & rgb_muxed(0) & rgb_muxed(0) & '0';

    -- 7-segment display decoding
    SEG7_L <= seg7_decode(user_score_disp);
    SEG7_R <= seg7_decode(cpu_score_disp);

end architecture;
