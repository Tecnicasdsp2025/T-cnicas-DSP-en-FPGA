library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Led_tb is
end Led_tb;

architecture Behavioral of Led_tb is
    signal sw0 : STD_LOGIC := '0';
    signal sw1 : STD_LOGIC := '0';
    signal led1 : STD_LOGIC;
    signal led2 : STD_LOGIC;
    signal led3 : STD_LOGIC;
    signal led4 : STD_LOGIC;
    
    -- Declaración del componente para la Unidad Bajo Prueba (UUT)
    component Led
        Port ( sw0 : in STD_LOGIC;
               sw1 : in STD_LOGIC;
               led1 : out STD_LOGIC;
               led2 : out STD_LOGIC;
               led3 : out STD_LOGIC;
               led4 : out STD_LOGIC);
    end component;

begin
    -- Instanciar la Unidad Bajo Prueba (UUT)
    uut: Led PORT MAP (
          sw0 => sw0,
          sw1 => sw1,
          led1 => led1,
          led2 => led2,
          led3 => led3,
          led4 => led4
        );

    -- Proceso de estímulo
    stim_proc: process
    begin		
        -- Mantener el estado de reinicio durante 100 ns
        wait for 100 ns;
        
        -- Caso de prueba 1: sw0 = 0, sw1 = 0
        sw0 <= '0';
        sw1 <= '0';
        wait for 100 ns;
        
        -- Caso de prueba 2: sw0 = 1, sw1 = 0
        sw0 <= '1';
        sw1 <= '0';
        wait for 100 ns;
        
        -- Caso de prueba 3: sw0 = 0, sw1 = 1
        sw0 <= '0';
        sw1 <= '1';
        wait for 100 ns;
        
        -- Caso de prueba 4: sw0 = 1, sw1 = 1
        sw0 <= '1';
        sw1 <= '1';
        wait for 100 ns;
        
        -- Finalizar la simulación
        wait;
    end process;

end Behavioral;
