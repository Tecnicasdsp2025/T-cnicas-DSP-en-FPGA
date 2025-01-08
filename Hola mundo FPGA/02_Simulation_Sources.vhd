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
    
    -- Component Declaration for the Unit Under Test (UUT)
    component Led
        Port ( sw0 : in STD_LOGIC;
               sw1 : in STD_LOGIC;
               led1 : out STD_LOGIC;
               led2 : out STD_LOGIC;
               led3 : out STD_LOGIC;
               led4 : out STD_LOGIC);
    end component;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: Led PORT MAP (
          sw0 => sw0,
          sw1 => sw1,
          led1 => led1,
          led2 => led2,
          led3 => led3,
          led4 => led4
        );

    -- Stimulus process
    stim_proc: process
    begin		
        -- Hold reset state for 100 ns
        wait for 100 ns;
        
        -- Test case 1: sw0 = 0, sw1 = 0
        sw0 <= '0';
        sw1 <= '0';
        wait for 100 ns;
        
        -- Test case 2: sw0 = 1, sw1 = 0
        sw0 <= '1';
        sw1 <= '0';
        wait for 100 ns;
        
        -- Test case 3: sw0 = 0, sw1 = 1
        sw0 <= '0';
        sw1 <= '1';
        wait for 100 ns;
        
        -- Test case 4: sw0 = 1, sw1 = 1
        sw0 <= '1';
        sw1 <= '1';
        wait for 100 ns;
        
        -- End simulation
        wait;
    end process;

end Behavioral;
