library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use UNISIM.VComponents.all;

entity stack_tb is
--  Port ( );
end stack_tb;

architecture Behavioral of stack_tb is

component  stack is
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

constant DATA_WIDTH : integer := 8;
constant ADDR_WIDTH : integer := 4;
signal clk_tb: std_logic;
signal reset_tb: std_logic;
signal rd_tb, wr_tb     :   std_logic;
signal w_data_tb     :   std_logic_vector(DATA_WIDTH - 1 downto 0);
signal empty_tb      : std_logic;
signal full_tb       : std_logic;
signal almost_full_tb       : std_logic;
signal almost_empty_tb       : std_logic;
signal w_count_tb    : std_logic_vector(ADDR_WIDTH downto 0);
signal r_data_tb     : std_logic_vector(DATA_WIDTH - 1 downto 0);


constant CP: time := 10ns;

begin

uut: stack generic map (ADDR_WIDTH => 4, DATA_WIDTH=> 8)
     port map(clk => clk_tb, reset => reset_tb, rd => rd_tb, wr => wr_tb, 
              w_data => w_data_tb, empty => empty_tb, full => full_tb,
              w_count => w_count_tb, r_data => r_data_tb, 
              almost_empty => almost_empty_tb, 
              almost_full => almost_full_tb);

process
begin
	clk_tb <= '1';
	wait for CP/2;
	clk_tb <= '0';
	wait for CP/2;
end process;


reset_tb <= '0', '1' after 20 ns, '0' after 40 ns;

process
begin
	wr_tb <= '0';
	rd_tb <= '0';
	wait for 50 ns;
	wr_tb <= '1';
	wait for 10 ns;
	w_data_tb <= x"01";
	wait for 10 ns;
	w_data_tb <= x"02";
	wait for 10 ns;
	w_data_tb <= x"03";
	wait for 10 ns;
	w_data_tb <= x"04";
	wait for 10 ns;
	w_data_tb <= x"05";
	wait for 10 ns;
	w_data_tb <= x"06";
	wait for 10 ns;
	w_data_tb <= x"07";
	wait for 10 ns;
	w_data_tb <= x"08";
	wait for 10 ns;
	w_data_tb <= x"09";
	wait for 10 ns;
	w_data_tb <= x"0A";
	wait for 10 ns;
	w_data_tb <= x"0B";
	wait for 10 ns;
	w_data_tb <= x"0C";
	wait for 10 ns;
	w_data_tb <= x"0D";
	wait for 10 ns;
	w_data_tb <= x"0E";
	wait for 10 ns;
	w_data_tb <= x"0F";
	wait for 10 ns;
	w_data_tb <= x"10";
	wait for 10 ns;
	w_data_tb <= x"11";
	wait for 10 ns;
	wr_tb <= '0';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '1';
	wait for 10 ns;
	rd_tb <= '0';
	wait;
end process;

end Behavioral;
