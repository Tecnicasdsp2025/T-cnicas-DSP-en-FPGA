library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FFT_5KHz_tb is
end FFT_5KHz_tb;

architecture Behavioral of FFT_5KHz_tb is

    -- Señales para conectar al DUT
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';
    signal tvalid_in    : std_logic := '0';
    signal tdata_in     : std_logic_vector(15 downto 0) := (others => '0');
    signal tlast_in     : std_logic := '0';
    signal tvalid_out   : std_logic;
    signal tdata_out    : std_logic_vector(31 downto 0);
    signal tlast_out    : std_logic;

    -- Parámetros
    constant clk_period : time := 10 ns; -- 100 MHz clock
    constant Fs         : integer := 1000000; -- Frecuencia de muestreo: 1 MHz
    constant Fsig       : integer := 5000;    -- Frecuencia de la señal cuadrada: 5 kHz
    constant N          : integer := 1024;    -- Tamaño de la FFT

    -- Otras variables
    constant period_samples : integer := Fs / Fsig; -- Número de muestras por periodo
    constant amplitude      : integer := 1000;      -- Amplitud de la señal cuadrada

begin

    -- Generador de reloj
    clk_process : process
    begin
        clk <= not clk;
        wait for clk_period / 2;
    end process;

    -- Generar estímulo: señal cuadrada de 5 kHz
    stimulus_process : process
        variable i : integer := 0;
    begin
        -- Reset inicial
        rst <= '1';
        wait for 2 * clk_period;
        rst <= '0';
        wait for clk_period;

        -- Enviar señal cuadrada de 5 kHz
        tvalid_in <= '1';
        for i in 0 to N-1 loop
            if (i mod period_samples) < (period_samples / 2) then
                tdata_in <= std_logic_vector(to_signed(amplitude, 16)); -- Valor alto
            else
                tdata_in <= std_logic_vector(to_signed(-amplitude, 16)); -- Valor bajo
            end if;

            if i = N-1 then
                tlast_in <= '1'; -- Indicar el final del bloque
            else
                tlast_in <= '0';
            end if;

            wait for clk_period;
        end loop;

        -- Finalizar estímulo
        tvalid_in <= '0';
        wait;
    end process;

    -- Instancia del módulo FFT
    DUT : entity work.FFT_5KHz
        port map (
            clk        => clk,
            rst        => rst,
            tvalid_in  => tvalid_in,
            tdata_in   => tdata_in,
            tlast_in   => tlast_in,
            tvalid_out => tvalid_out,
            tdata_out  => tdata_out,
            tlast_out  => tlast_out
        );

end Behavioral;
