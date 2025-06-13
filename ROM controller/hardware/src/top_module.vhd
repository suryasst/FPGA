library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
entity top_module is
    generic (ADDR_WIDTH : integer:= 7;
            DATA_WIDTH : integer := 8
           );
    port(
        clk: in STD_LOGIC;
        rst: in STD_LOGIC;
        an : out std_logic;
        seg : out STD_LOGIC_VECTOR (6 downto 0);
        sw : in STD_LOGIC;
        btn: in std_logic_vector(3 downto 1);
        led: out std_logic_vector(3 downto 0)
    );
end top_module;
architecture Behavioral of top_module is
    component debounce is
        PORT(
            CLK:IN STD_LOGIC;
            button:IN STD_LOGIC;
            result: OUT STD_LOGIC);
    end component;

    component DisplayController is
        port(
            DispVal: in STD_LOGIC_VECTOR (3 downto 0) ;
            segOut : out STD_LOGIC_VECTOR (6 downto 0));
    end component;

    component rom is
        Generic(
            ADDR_WIDTH : Integer := 7;
            DATA_WIDTH : Integer := 8
        );
        port(clk : in STD_LOGIC;
             addr_r: in STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
             data : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0));
    end component;

    component frq_1hz is
        port(
            clk : in std_logic;
            speed1 : out std_logic);
    end component;

    component frq_2hz is
        port(
            clk: in std_logic;
            speed2 : out std_logic);
    end component;

    component frq_4hz is
        port(
            clk : in std_logic;
            speed4 : out std_logic);
    end component;

    component frq_8hz is
        port(
            clk: in std_logic;
            speed8 : out std_logic);
    end component;

    signal addr_r : STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
    signal data : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

    signal counterD1: integer ;
    signal count_up_down: std_logic;

    signal sp: std_logic_vector (1 downto 0);

    signal speed1: std_logic;
    signal speed2: std_logic;
    signal speed4: std_logic;
    signal speed8: std_logic;
    signal start_c : std_logic;
    signal stop_c: std_logic;
    signal speed_c: std_logic;
    signal start_r: std_logic;
    signal stop_r: std_logic;

    signal sp_cnt: integer;

    signal seg0 : std_logic_vector (6 downto 0);
    signal seg1: std_Logic_vector (6 downto 0);
    signal decode0 : std_logic_vector(3 downto 0);
    signal decode1: std_logic_vector(3 downto 0);
    signal disp_sel: std_logic;

    --std_logic_1164
    constant clk_cnt_width: integer := 20;
    signal clk_cnt: unsigned(clk_cnt_width-1 downto 0);
begin

    --instantiation of freq dividers

    SPD1: frq_1hz port map(clk => clk, speed1 => speed1);
    SPD2: frq_2hz port map(clk => clk, speed2 => speed2);
    SPD3: frq_4hz port map(clk => clk, speed4 => speed4);
    SPD4: frq_8hz port map(clk => clk, speed8 => speed8);

    -- instantiation of DisplayController for each segment
    SDO: DisplayController port map (DispVal => Decode0, segOut => seg0);
    SD1: DisplayController port map (DispVal => Decode1, segOut => seg1);

    --instantiation of debouncer for bt (3 downto 1) (rst is not included)
    DBO: debounce port map ( clk => clk, button => btn(1), result => start_r);
    DB1: debounce port map ( clk => clk, button => btn(2), result => stop_r);
    DB2: debounce port map ( clk => clk, button => btn(3), result => speed_c);

    --instantiation of Rom for more practice
    RM: rom port map (clk => clk, addr_r => addr_r , data => data);

    --make the logic easier to work with, just considering 1 as up and 0 for down.
    count_up_down <= '1' when sw = '0' else
                     '0' when sw = '1';
    process (clk)
    begin
        if rising_edge (clk)then
            addr_r <= std_Logic_vector(to_unsigned(counterD1,7));
        end if;
    end process;

    process(rst,clk,start_r,stop_r)
    begin
        if rst = '1' then
            start_c <= '0';
            stop_c <= '0';
        elsif rising_edge (clk) then
            if start_r ='1' then
                start_c <= '1';
                stop_c  <= '0';
            elsif stop_r = '1' then
                start_c <='0';
                stop_c <= '1';
            end if;
        end if;
    end process;

    process (clk,start_c,stop_c,speed_c,speed1,speed2,speed4,speed8)
    begin
        case sp is
            when "00" =>      -- when speed 15 ahZ
                if rst = '1' then
                    counterD1 <= 0;

                elsif rising_edge (speed1) then
                    if count_up_down = '1' then
                        if start_c = '1' then
                            if counterD1 <= 98 then
                                counterD1 <= counterD1 +1;

                            else counterD1 <= 0;
                            end if;
                        elsif stop_c = '1' then
                            counterD1 <= counterD1;
                        end if;

                    elsif count_up_down = '0' then
                        if start_c = '1' then
                            if counterD1 >= 1 then
                                counterD1 <= counterD1 - 1;

                            else counterD1 <= 98;
                            end if;
                        elsif stop_c = '1' then
                            counterD1 <= counterD1;
                        end if;
                    end if;
                end if;

            when "01" =>      -- when speed 2hZ
                if rst = '1' then
                    counterD1 <= 0;

                elsif rising_edge (speed2) then
                    if count_up_down = '1' then
                        if start_c = '1' then
                            if counterD1 <= 98 then
                                counterD1 <= counterD1 +1;

                            else counterD1 <= 0;
                            end if;
                        elsif stop_c = '1' then
                            counterD1 <= counterD1;
                        end if;

                    elsif count_up_down = '0' then
                        if start_c = '1' then
                            if counterD1 >= 1 then
                                counterD1 <= counterD1 - 1;

                            else counterD1 <= 98;
                            end if;
                        elsif stop_c = '1' then
                            counterD1 <= counterD1;
                        end if;
                    end if;
                end if;


            when "10" =>      -- when speed 2hZ
                if rst = '1' then
                    counterD1 <= 0;

                elsif rising_edge (speed4) then
                    if count_up_down = '1' then
                        if start_c = '1' then
                            if counterD1 <= 98 then
                                counterD1 <= counterD1 +1;

                            else counterD1 <= 0;
                            end if;
                        elsif stop_c = '1' then
                            counterD1 <= counterD1;
                        end if;

                    elsif count_up_down = '0' then
                        if start_c = '1' then
                            if counterD1 >= 1 then
                                counterD1 <= counterD1 - 1;

                            else counterD1 <= 98;
                            end if;
                        elsif stop_c = '1' then
                            counterD1 <= counterD1;
                        end if;
                    end if;
                end if;

            when "11" =>      -- when speed 2hZ
                if rst = '1' then
                    counterD1 <= 0;

                elsif rising_edge (speed8) then
                    if count_up_down = '1' then
                        if start_c = '1' then
                            if counterD1 <= 98 then
                                counterD1 <= counterD1 +1;

                            else counterD1 <= 0;
                            end if;
                        elsif stop_c = '1' then
                            counterD1 <= counterD1;
                        end if;

                    elsif count_up_down = '0' then
                        if start_c = '1' then
                            if counterD1 >= 1 then
                                counterD1 <= counterD1 - 1;

                            else counterD1 <= 98;
                            end if;
                        elsif stop_c = '1' then
                            counterD1 <= counterD1;
                        end if;
                    end if;
                end if;

            when others => sp <= "00";
        end case;
    end process;

    process(rst,speed_c)
    begin
        if rst = '1' then
            sp <= "00";
            sp_cnt <= 0;
        elsif rising_edge (speed_c) then

            sp_cnt <= sp_cnt +1;
            sp <= std_logic_vector(to_unsigned(sp_cnt,2));
        end if;
        --std_logic_vector (to_unsigned(sp_ent,2)/
    end process;

    process(clk,speed_c)
    begin
        if rst = '1' then
            led <= "0001";
        elsif rising_edge (clk) then
            if sp = "00" then
                led <= "0001";
            elsif sp = "01" then
                led <= "0010";
            elsif sp = "10" then
                led <= "0100";
            elsif sp = "11" then
                led <= "1000";
            else
                led <= "0000";
            end if;              
        end if;
    end process;

    process (clk, rst)
    begin
        if rst = '1' then
            disp_sel <= '0';
            decode0 <= (others => '0');
            decode1 <= (others => '1');
        elsif rising_edge (clk) then

            if disp_sel = '0' then
                decode0 <= data (3 downto 0);
                disp_sel <= NOT disp_sel;
            else
                decode1 <= data (7 downto 4);
                disp_sel <= NOT disp_sel;
            end if;
        end if;
    end process;

    process (clk)
    begin
        if rst ='1' then
            clk_cnt <= (others => '0');
        elsif rising_edge (clk) then
            clk_cnt <= clk_cnt +1;
        end if;
    end process;
    an <= clk_cnt(clk_cnt'high);
    seg <= seg0 when clk_cnt(clk_cnt'high) = '0' else seg1;
end Behavioral;