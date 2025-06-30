-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity input_handler is
    port (
        clk      : in std_logic;
        btn      : in std_logic_vector(3 downto 0);
        sw       : in std_logic_vector(3 downto 0);
        level    : out std_logic_vector(3 downto 0);
        up       : out std_logic;
        down     : out std_logic;
        pause    : out std_logic
    );
end entity;

architecture Behavioral of input_handler is
begin
    level <= sw;
    up    <= btn(0);
    down  <= btn(1);
    pause <= btn(3);
end architecture;
