Test bench

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity OFDM_Simulation_TB is
end OFDM_Simulation_TB;

architecture Behavioral of OFDM_Simulation_TB is
    -- Declaración de señales
    signal clk_tb        : STD_LOGIC := '0';
    signal reset_tb      : STD_LOGIC := '1';
    signal data_in_tb    : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal data_out_tb   : STD_LOGIC_VECTOR(1 downto 0);
    signal valid_in_tb   : STD_LOGIC := '0';
    signal valid_out_tb  : STD_LOGIC;

    -- Constantes
    constant CLK_PERIOD : time := 10 ns;

    -- Instancia del DUT (Device Under Test)
    component OFDM_Simulation
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            data_in     : in  STD_LOGIC_VECTOR(1 downto 0);
            data_out    : out STD_LOGIC_VECTOR(1 downto 0);
            valid_in    : in  STD_LOGIC;
            valid_out   : out STD_LOGIC
        );
    end component;

begin
    -- Instancia del módulo OFDM_Simulation
    DUT : OFDM_Simulation
        port map (
            clk       => clk_tb,
            reset     => reset_tb,
            data_in   => data_in_tb,
            data_out  => data_out_tb,
            valid_in  => valid_in_tb,
            valid_out => valid_out_tb
        );

    -- Generación del reloj
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Proceso de estímulos
    stim_proc: process
    begin
        -- Reset inicial
        reset_tb <= '1';
        wait for 2 * CLK_PERIOD;
        reset_tb <= '0';

        -- Enviar datos de entrada (4 símbolos QAM4: 00, 01, 10, 11)
        valid_in_tb <= '1';

        -- Símbolo 00
        data_in_tb <= "00";
        wait for CLK_PERIOD;

        -- Símbolo 01
        data_in_tb <= "01";
        wait for CLK_PERIOD;

        -- Símbolo 10
        data_in_tb <= "10";
        wait for CLK_PERIOD;

        -- Símbolo 11
        data_in_tb <= "11";
        wait for CLK_PERIOD;

        -- Finalizar entrada de datos
        valid_in_tb <= '0';
        data_in_tb <= "00";
        wait for 10 * CLK_PERIOD;

       
    end process;

end Behavioral;
