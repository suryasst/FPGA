library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;


signal addr: unsigned(resolution-1  downto 0);

subtype addr_range is integer range 0 to 2**resolution - 1;

type rom_type is array (addr_range) of unsigned(resolution - 1 downto 0);

function init_rom return rom_type is
 variable rom_v : rom_type;
 variable angle : real;
 variable sin_scaled : real;
begin

 for i in addr_range loop
   angle := real(i) * ((2.0 * MATH_PI) / 2.0**resolution);
   sin_scaled := (1.0 + sin(angle)) * (2.0**resolution - 1.0) / 2.0;
   rom_v(i) := to_unsigned(integer(round(sin_scaled)), resolution);
 end loop;
 return rom_v;
end init_rom;

constant rom : rom_type := init_rom;
signal sin_data: unsigned(resolution-1 downto 0);
