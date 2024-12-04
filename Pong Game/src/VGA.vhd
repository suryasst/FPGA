library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Controller is
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        hsync      : out STD_LOGIC;
        vsync      : out STD_LOGIC;
        pixel_x    : out INTEGER range 0 to 639; -- Horizontal resolution
        pixel_y    : out INTEGER range 0 to 479; -- Vertical resolution
        video_on   : out STD_LOGIC
    );
end VGA_Controller;

architecture Behavioral of VGA_Controller is
    -- VGA timing parameters
    constant H_SYNC_PULSE : integer := 96;
    constant H_BACK_PORCH : integer := 48;
    constant H_ACTIVE     : integer := 640;
    constant H_FRONT_PORCH: integer := 16;
    constant H_TOTAL      : integer := 800;

    constant V_SYNC_PULSE : integer := 2;
    constant V_BACK_PORCH : integer := 33;
    constant V_ACTIVE     : integer := 480;
    constant V_FRONT_PORCH: integer := 10;
    constant V_TOTAL      : integer := 525;

    signal h_count : integer range 0 to H_TOTAL - 1 := 0;
    signal v_count : integer range 0 to V_TOTAL - 1 := 0;

begin
    -- Horizontal and Vertical Counters
    process(clk, reset)
    begin
        if reset = '1' then
            h_count <= 0;
            v_count <= 0;
        elsif rising_edge(clk) then
            if h_count = H_TOTAL - 1 then
                h_count <= 0;
                if v_count = V_TOTAL - 1 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    -- Generate HSync and VSync signals
    hsync <= '0' when (h_count < H_SYNC_PULSE) else '1';
    vsync <= '0' when (v_count < V_SYNC_PULSE) else '1';

    -- Active Video Signal
    video_on <= '1' when (h_count >= H_SYNC_PULSE + H_BACK_PORCH and h_count < H_SYNC_PULSE + H_BACK_PORCH + H_ACTIVE
                         and v_count >= V_SYNC_PULSE + V_BACK_PORCH and v_count < V_SYNC_PULSE + V_BACK_PORCH + V_ACTIVE) else '0';

    -- Pixel Coordinates
    pixel_x <= h_count - (H_SYNC_PULSE + H_BACK_PORCH);
    pixel_y <= v_count - (V_SYNC_PULSE + V_BACK_PORCH);
end Behavioral;
