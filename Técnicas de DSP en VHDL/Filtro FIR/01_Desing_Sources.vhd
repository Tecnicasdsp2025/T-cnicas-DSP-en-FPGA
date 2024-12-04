library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filtro_fir is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        data_in  : in  std_logic_vector(15 downto 0); -- Entrada digital
        data_out : out std_logic_vector(31 downto 0)  -- Salida hacia analizador
    );
end filtro_fir;

architecture Behavioral of filtro_fir is

    constant N : integer := 16;  -- Número de taps
    signal coef_index : unsigned(16 downto 0) := (others => '0');
    signal coef_data  : signed(15 downto 0);
    signal x_mem      : signed(15 downto 0);
    signal acc        : signed(31 downto 0) := (others => '0');
    signal y          : signed(31 downto 0) := (others => '0');

    -- Declaración del componente de la BRAM
    component blk_mem_gen_0
        port (
            clka    : in std_logic;
            ena     : in std_logic;
            wea     : in std_logic_vector(0 downto 0);
            addra   : in unsigned(16 downto 0);
            dina    : in std_logic_vector(15 downto 0);
            douta   : out signed(15 downto 0)
            );
        end component;

begin

    -- Instancia de la memoria BRAM para los coeficientes
    coef_mem_inst : blk_mem_gen_0
        port map (
            clka    => clk,
            ena     => '1',
            wea     => (others => '0'),  -- std_logic_vector(0 downto 0)
            addra   => coef_index,
            dina    => (others => '0'),  -- std_logic_vector(15 downto 0)
            douta   => coef_data
        );
    
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                coef_index <= (others => '0');
                y <= (others => '0');
                acc <= (others => '0');
            else
                -- Desplazamiento del registro de retardo
                x_mem <= signed(data_in);

                -- Multiplicación y acumulación
                acc <= acc + resize(coef_data * x_mem, acc'length);

                -- Incrementar el índice de los coeficientes
                if coef_index < N-1 then
                    coef_index <= coef_index + 1;
                else
                    coef_index <= (others => '0');
                    y <= acc;  -- Asigna el valor acumulado a la salida
                    acc <= (others => '0');  -- Reiniciar acumulador
                end if;
            end if;
        end if;
    end process;

    -- Asignación de la salida
    data_out <= std_logic_vector(y);

end Behavioral;
