library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_filtro_fir_1khz is
end tb_filtro_fir_1khz;

architecture Behavioral of tb_filtro_fir_1khz is

    -- Señales para la simulación
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal data_in  : std_logic_vector(15 downto 0) := (others => '0');
    signal data_out : std_logic_vector(31 downto 0);

    -- Constantes
    constant clk_period : time := 10 ns;  -- 100 MHz reloj de la FPGA
    constant period_1khz : time := 1 ms;

    -- Instancia del filtro FIR
    component filtro_fir
        Port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            data_in  : in  std_logic_vector(15 downto 0);
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    -- Instancia del DUT
    dut: filtro_fir
        port map (
            clk      => clk,
            reset    => reset,
            data_in  => data_in,
            data_out => data_out
        );

    -- Generación del reloj
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Generación de la señal cuadrada de 1 kHz
    stim_process : process
    begin
        -- Pulso de reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        -- Generar señal cuadrada de 1 kHz
        while true loop
            data_in <= std_logic_vector(to_signed(1000, 16));
            wait for period_1khz / 2;
            data_in <= std_logic_vector(to_signed(-1000, 16));
            wait for period_1khz / 2;
        end loop;
    end process;

end Behavioral;
