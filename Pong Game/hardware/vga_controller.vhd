-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
    port (
        clk      : in  std_logic;    -- 25 MHz for 640x480@60Hz (use clock divider if needed)
        hsync    : out std_logic;
        vsync    : out std_logic;
        vid_on   : out std_logic;
        px       : out unsigned(9 downto 0); -- 10 bits for 0..639
        py       : out unsigned(9 downto 0)  -- 10 bits for 0..479
    );
end entity;

architecture behavioral of vga_controller is
    -- VGA timing params for 640x480@60Hz
    constant h_disp    : integer := 640;
    constant h_fp      : integer := 16;
    constant h_sync    : integer := 96;
    constant h_bp      : integer := 48;
    constant h_total   : integer := h_disp + h_fp + h_sync + h_bp;

    constant v_disp    : integer := 480;
    constant v_fp      : integer := 10;
    constant v_sync    : integer := 2;
    constant v_bp      : integer := 33;
    constant v_total   : integer := v_disp + v_fp + v_sync + v_bp;

    signal h_cnt : integer range 0 to h_total-1 := 0;
    signal v_cnt : integer range 0 to v_total-1 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if h_cnt = h_total-1 then
                h_cnt <= 0;
                if v_cnt = v_total-1 then
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
                end if;
            else
                h_cnt <= h_cnt + 1;
            end if;
        end if;
    end process;

    hsync <= '0' when (h_cnt >= h_disp + h_fp and h_cnt < h_disp + h_fp + h_sync) else '1';
    vsync <= '0' when (v_cnt >= v_disp + v_fp and v_cnt < v_disp + v_fp + v_sync) else '1';
    vid_on <= '1' when (h_cnt < h_disp and v_cnt < v_disp) else '0';
    px <= to_unsigned(h_cnt, 10);
    py <= to_unsigned(v_cnt, 10);

end architecture;
