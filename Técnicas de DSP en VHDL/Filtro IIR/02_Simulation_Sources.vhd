library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IIR_Butterworth_tb is
end IIR_Butterworth_tb;

architecture sim of IIR_Butterworth_tb is

    -- Señales para la simulación
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal data_in  : std_logic_vector(15 downto 0) := (others => '0');
    signal data_out : std_logic_vector(15 downto 0);

    -- Instancia del DUT (Device Under Test)
    component IIR_Butterworth
        Port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            data_in  : in  std_logic_vector(15 downto 0);
            data_out : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Valores pre-calculados de una señal senoidal
    type sine_array is array (0 to 19) of integer;
    constant sine_wave : sine_array := (0, 309, 587, 809, 951, 1000, 951, 809, 587, 309, 0, -309, -587, -809, -951, -1000, -951, -809, -587, -309);

begin

    -- Instancia del filtro
    uut: IIR_Butterworth
        Port map (
            clk      => clk,
            reset    => reset,
            data_in  => data_in,
            data_out => data_out
        );

    -- Generación de la señal de reloj (50 MHz)
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Proceso de simulación
    stimulus_process: process
    begin
        -- Reinicio del sistema
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- Aplicación de los valores senoidales de la tabla en la entrada
        for i in 0 to 19 loop
            data_in <= std_logic_vector(to_signed(sine_wave(i), 16));
            wait for 20 ns;
        end loop;

        -- Fin de la simulación
        wait;
    end process;

end sim;
