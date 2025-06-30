-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        CLK100MHZ : in std_logic; -- From Zybo
        BTN       : in std_logic_vector(3 downto 0);
        SW        : in std_logic_vector(3 downto 0);
        VGA_HS    : out std_logic;
        VGA_VS    : out std_logic;
        VGA_R     : out std_logic_vector(3 downto 0);
        VGA_G     : out std_logic_vector(3 downto 0);
        VGA_B     : out std_logic_vector(3 downto 0);
        SEG7      : out std_logic_vector(6 downto 0) -- One digit; expand as needed
    );
end entity;

architecture Behavioral of top is

    -- Clock divider: Generate 25 MHz for VGA
    signal clk25 : std_logic := '0';
    signal clkdiv : integer range 0 to 1 := 0;

    -- Wires for submodules
    signal px, py : unsigned(9 downto 0);
    signal vid_on : std_logic;
    signal rgb : std_logic_vector(2 downto 0);
    signal score : unsigned(3 downto 0);

begin
    -- Clock divider for 25MHz VGA clock
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

    vga_inst : entity work.vga_controller
        port map (
            clk    => clk25,
            hsync  => VGA_HS,
            vsync  => VGA_VS,
            vid_on => vid_on,
            px     => px,
            py     => py
        );

    pong1 : entity work.pong_level1
        port map (
            clk25   => clk25,
            rst     => '0',
            up      => BTN(0),
            down    => BTN(1),
            px      => px,
            py      => py,
            vid_on  => vid_on,
            score   => score,
            rgb     => rgb
        );

    -- Connect 3-bit output to VGA 4-bit buses (for simple color)
    VGA_R <= rgb(2) & rgb(2) & rgb(2) & '0';
    VGA_G <= rgb(1) & rgb(1) & rgb(1) & '0';
    VGA_B <= rgb(0) & rgb(0) & rgb(0) & '0';

    -- Simple 7-segment decoder (for one digit, expand as needed)
    process(score)
    begin
        case score is
            when "0000" => SEG7 <= "1000000"; -- 0
            when "0001" => SEG7 <= "1111001"; -- 1
            when "0010" => SEG7 <= "0100100"; -- 2
            when "0011" => SEG7 <= "0110000"; -- 3
            when "0100" => SEG7 <= "0011001"; -- 4
            when "0101" => SEG7 <= "0010010"; -- 5
            when "0110" => SEG7 <= "0000010"; -- 6
            when "0111" => SEG7 <= "1111000"; -- 7
            when "1000" => SEG7 <= "0000000"; -- 8
            when "1001" => SEG7 <= "0010000"; -- 9
            when others => SEG7 <= "1111111";
        end case;
    end process;

end architecture;
