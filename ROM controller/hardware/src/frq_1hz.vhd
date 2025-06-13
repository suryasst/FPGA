library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
entity frq_1hz is
port (
   clk: in std_logic;
   speed1: out std_logic
  );
end frq_1hz;
architecture Behavioral of frq_1hz is
signal counter: std_logic_vector(27 downto 0):=(others =>'0');
begin
 process(clk)
 begin
  if(rising_edge(clk)) then
   counter <= counter + x"0000001";
   if(counter>=x"7735940") then 
    counter <= x"0000000";
   end if;
  end if;
 end process;
 speed1 <= '0' when counter < x"3b9ACA0" else '1';
end Behavioral;