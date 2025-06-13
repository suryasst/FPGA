
--------------------------------------------------------------------------------
--
--   FileName:         debounce.vhd
--   Dependencies:     none
--   Design Software:  Quartus Prime Version 17.0.0 Build 595 SJ Lite Edition
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 2.0 6/28/2019 Scott Larson
--     Added asynchronous active-low reset
--     Made stable time higher resolution and simpler to specify
--   Version 1.0 3/26/2012 Scott Larson
--     Initial Public Release
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity debounce is
    generic (
        clk_freq    : integer := 50_000_000; --system clock frequency in Hz
        stable_time : integer := 500);        --time button must remain stable in ms
    port (
        clk     : in std_logic;   --input clock
        rst : in std_logic;   --asynchronous active low reset
        button  : in std_logic;   --input signal to be debounced
        pulse  : out std_logic;
        value : out std_logic
        ); --debounced signal
end debounce;

architecture logic of debounce is
    signal flipflops   : std_logic_vector(1 downto 0); --input flip flops
    signal counter_set : std_logic;                    --sync reset to zero
    signal result_reg0: std_logic;
    signal result_reg1: std_logic;
begin

    counter_set <= flipflops(0) xor flipflops(1); --determine when to start/reset counter

    process (clk, rst)
        variable count : integer range 0 to clk_freq * stable_time/1000; --counter for timing
    begin
        if (rst = '1') then                          --reset
            flipflops(1 downto 0) <= "00";                   --clear input flipflops
            result_reg0                <= '0';                    --clear result register
            result_reg1                <= '0';                    --clear result register
            value <= '0';
        elsif (clk'EVENT and clk = '1') then             --rising clock edge
            flipflops(0) <= button;                          --store button value in 1st flipflop
            flipflops(1) <= flipflops(0);                    --store 1st flipflop value in 2nd flipflop
            if (counter_set = '1') then                      --reset counter because input is changing
                count := 0;                                      --clear the counter
            elsif (count < clk_freq * stable_time/1000) then --stable input time is not yet met
                count := count + 1;                              --increment counter
            else                                             --stable input time is met
                value <= flipflops(1);
                result_reg0 <= flipflops(1);                 
                result_reg1 <= result_reg0;
            end if;
        end if;
    end process;

    pulse <= not result_reg1 and result_reg0;
end logic;
