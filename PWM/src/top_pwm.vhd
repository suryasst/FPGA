library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_pwm is
   port(
       clk : in std_logic ;
       rst : in std_logic ;
       rgb : out std_logic_vector (2 downto 0);
       sw : in std_logic_vector (3 downto 0)
   );
end top_pwm ;
architecture Behavioral of top_pwm is

component pwm_enhanced is
	Generic (
		R : integer := 8
	);
	port ( clk : in std_logic;
			reset : in std_logic;
			dvsr : in std_logic_vector (31 downto 0);
			duty : in std_logic_vector (R downto 0);
			pwm_out : out std_logic);
end component;
constant resolution : integer := 8;
constant dvsr : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(4882,32)); --125000000/((2**8)*100) -- sys_clk/2^R * PWM_Freq
signal pwm_reg1 : std_logic;
signal pwm_reg2 : std_logic;
signal pwm_reg3 : std_logic;
begin

pwm1: pwm_enhanced generic map (R => resolution)
					port map (clk => clk,
								reset => rst,
								dvsr => dvsr,
								duty => std_logic_vector(to_unsigned(13,resolution)),
								pwm_out => pwm_reg1);
pwm2: pwm_enhanced generic map (R => resolution)
					port map (clk => clk,
								reset => rst,
								dvsr => dvsr,
								duty => std_logic_vector(to_unsigned(64,resolution)),
								pwm_out => pwm_reg2);
pwm3: pwm_enhanced generic map (R => resolution)
					port map (clk => clk,
								reset => rst,
								dvsr => dvsr,
								duty => std_logic_vector(to_unsigned(128,resolution)),
								pwm_out => pwm_reg3);
								
rgb(0) <= pwm_reg1 when sw = "0000" else
		  pwm_reg2 when sw = "0001" else
		  pwm_reg3 when sw = "0010";
end Behavioral ;