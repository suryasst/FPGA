library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
entity frq_4hz is
port (
   clk: in std_logic;
   speed4: out std_logic
  );
end frq_4hz;
architecture Behavioral of frq_4hz is
signal counter: std_logic_vector(27 downto 0):=(others =>'0');
begin
 process(clk)
 begin
  if(rising_edge(clk)) then
   counter <= counter + x"0000001";
   if(counter>=x"1DCD650") then 
    counter <= x"0000000";
   end if;
  end if;
 end process;
 speed4 <= '0' when counter < x"EE6B28" else '1';
end Behavioral;