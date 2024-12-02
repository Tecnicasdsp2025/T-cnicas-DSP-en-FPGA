library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Led is
    Port ( sw0 : in STD_LOGIC;
           sw1 : in STD_LOGIC;
           led1 : out STD_LOGIC;
           led2 : out STD_LOGIC;
           led3 : out STD_LOGIC;
           led4 : out STD_LOGIC);
end Led;

architecture Behavioral of Led is
begin
    led1 <= sw0 AND sw1;
    led2 <= sw0 XOR sw1;
    led3 <= sw0 AND sw1; -- Igual que led1
    led4 <= sw0 XOR sw1; -- Igual que led2
end Behavioral;
