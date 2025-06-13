library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
entity frq_8hz is
port (
   clk: in std_logic;
   speed8: out std_logic
  );
end frq_8hz;
architecture Behavioral of frq_8hz is
signal counter: std_logic_vector(27 downto 0):=(others =>'0');
begin
 process(clk)
 begin
  if(rising_edge(clk)) then
   counter <= counter + x"0000001";
   if(counter>=x"EE6B28") then 
    counter <= x"0000000";
   end if;
  end if;
 end process;
 speed8 <= '0' when counter < x"773594" else '1';
end Behavioral;