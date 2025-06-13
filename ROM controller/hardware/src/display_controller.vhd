library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
Use IEEE.STD_LOGIC_UNSIGNED.all;
entity DisplayController is
    port (
        --output from the Decoder
        DispVal : in STD_LOGIC_VECTOR(3 downto 0); --controls which digit to display
        segOut: out STD_LOGIC_VECTOR (6 downto 0));
end DisplayController;

architecture Behavioral of DisplayController is
begin
        --only display the leftmost digit 
    with DispVal select
    segOut <= "1111110" when "0000",
              "0110000" when "0001",
              "1101101" when "0010",
              "0110011" When "0011",
              "1011011" when "0101",
              "1011111" when "0110",
              "1110000" when "0111",
              "1111111" when "1000",
              "1111011" when "1001",
              "0000000" when others;
end Behavioral;