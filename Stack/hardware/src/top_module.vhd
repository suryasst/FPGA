library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_module is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rd_btn : in STD_LOGIC;
           wr_btn : in STD_LOGIC;
           sw : in  std_logic_vector(3 downto 0);
           led: out  std_logic_vector(3 downto 0);
           led_r: out  std_logic;
           led_g: out  std_logic;
           led_b: out  std_logic
           
           );
end top_module;

architecture Behavioral of top_module is

component stack is
   generic(
      ADDR_WIDTH : integer := 4;
      DATA_WIDTH : integer := 4
   );
   port(
      clk, reset : in  std_logic;
      rd, wr     : in  std_logic;
      w_data     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
      empty      : out std_logic;
      full       : out std_logic;
      almost_empty: out std_logic;
      almost_full: out std_logic;
      w_count    : out std_logic_vector(ADDR_WIDTH downto 0);
      r_data     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
   );
end component;

component debounce is
    generic (
        clk_freq    : integer := 50_000_000; --system clock frequency in Hz
        stable_time : integer := 10);        --time button must remain stable in ms
    port (
        clk     : in std_logic;   --input clock
        rst : in std_logic;   --asynchronous active low reset
        button  : in std_logic;   --input signal to be debounced
        pulse  : out std_logic;
        value : out std_logic
        ); --debounced signal
    end component;

constant ADDR_WIDTH : integer := 4;
constant DATA_WIDTH : integer := 4;

signal rd, wr     : std_logic;
signal w_data     : std_logic_vector(DATA_WIDTH - 1 downto 0);
signal empty      : std_logic;
signal full       : std_logic;
signal almost_empty: std_logic;
signal almost_full: std_logic;
signal w_count    : std_logic_vector(ADDR_WIDTH downto 0);
signal r_data     : std_logic_vector(DATA_WIDTH - 1 downto 0);

signal rd_btn_pulse: std_logic;
signal wr_btn_pulse: std_logic;
signal rd_btn_value: std_logic;
signal wr_btn_value: std_logic;

signal led_reg: std_logic_vector(3 downto 0);

begin

stack_i: stack generic map(ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
               port map(clk => clk, 
                      reset => rst, 
                      rd => rd,
                      wr => wr,
                      w_data => w_data, 
                      empty => empty, 
                      full => full, 
                      almost_empty => almost_empty, 
                      almost_full => almost_full,
                      w_count => w_count,
                      r_data => r_data);
                      
DB0: debounce port map(clk => clk, rst => rst, button => rd_btn , pulse => rd_btn_pulse, value => rd_btn_value);
DB1: debounce port map(clk => clk, rst => rst, button => wr_btn , pulse => wr_btn_pulse, value => wr_btn_value);

process(clk, rst)
begin
    if rst = '1' then
        wr <= '0';
        rd <= '0';
        w_data <= (others => '0');
        
    elsif rising_edge(clk) then
        wr <= wr_btn_pulse;
        rd <= rd_btn_pulse;
        if wr_btn_pulse = '1' then
            w_data <= sw;
        end if;
     end if;
end process;

led <= r_data when rd_btn_value = '1' else
       sw when wr_btn_value = '1' else
       (others => '0');

led_r <= full;
led_g <= almost_empty;
led_b <= almost_full;

end Behavioral;
