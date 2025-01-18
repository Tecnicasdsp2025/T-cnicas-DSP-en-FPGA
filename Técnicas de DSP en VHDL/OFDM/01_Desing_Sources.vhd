--Modulación QAM

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mapper_QAM4 is
    Port (
        data_in    : in  STD_LOGIC_VECTOR(1 downto 0);  -- Entrada de datos (2 bits)
        symbol_out : out STD_LOGIC_VECTOR(31 downto 0) -- Salida ajustada a 32 bits (8 bits real + 8 bits imag)
    );
end Mapper_QAM4;

architecture Behavioral of Mapper_QAM4 is
    -- Tipo para representar números complejos
    type COMPLEX is record
        real : signed(15 downto 0);  -- Parte real (16 bits)
        imag : signed(15 downto 0);  -- Parte imaginaria (16 bits)
    end record;

    -- Señal interna para almacenar el símbolo complejo
    signal symbol : COMPLEX;

begin
    process(data_in)
    begin
        case data_in is
            when "00" =>
                symbol.real <= to_signed(1, 16);  -- Parte real: 1
                symbol.imag <= to_signed(1, 16);  -- Parte imaginaria: 1
            when "01" =>
                symbol.real <= to_signed(-1, 16); -- Parte real: -1
                symbol.imag <= to_signed(1, 16);  -- Parte imaginaria: 1
            when "10" =>
                symbol.real <= to_signed(1, 16);  -- Parte real: 1
                symbol.imag <= to_signed(-1, 16); -- Parte imaginaria: -1
            when "11" =>
                symbol.real <= to_signed(-1, 16); -- Parte real: -1
                symbol.imag <= to_signed(-1, 16); -- Parte imaginaria: -1
            when others =>
                symbol.real <= to_signed(0, 16);  -- Parte real: 0
                symbol.imag <= to_signed(0, 16);  -- Parte imaginaria: 0
        end case;

        -- Concatenación de la parte real e imaginaria para formar la salida de 32 bits
        symbol_out <= std_logic_vector(symbol.real) & std_logic_vector(symbol.imag);
    end process;
end Behavioral;
----‐-------------------------------------------------------------------------------
--IFFT

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity IFFT_Manual is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        valid_in  : in  STD_LOGIC;
        data_in   : in  STD_LOGIC_VECTOR(31 downto 0);
        valid_out : out STD_LOGIC;
        data_out  : out STD_LOGIC_VECTOR(31 downto 0) -- Salida secuencial de 32 bits
    );
end IFFT_Manual;

architecture Behavioral of IFFT_Manual is
    type data_array is array (0 to 63) of signed(31 downto 0); -- Almacenamiento temporal
    signal input_buffer  : data_array := (others => (others => '0'));
    signal output_buffer : data_array := (others => (others => '0'));
    signal idx           : integer range 0 to 63 := 0;
    signal done          : STD_LOGIC := '0';
    signal output_idx    : integer range 0 to 63 := 0;

    -- Tabla completa de cosenos y senos (64 elementos)
    type real_array is array (0 to 63) of real;
    constant COS_TABLE : real_array := (
        1.0,  0.9952,  0.9808,  0.9569,  0.9239,  0.8819,  0.8315,  0.7730,
        0.7071,  0.6344,  0.5556,  0.4714,  0.3827,  0.2903,  0.1951,  0.0980,
        0.0, -0.0980, -0.1951, -0.2903, -0.3827, -0.4714, -0.5556, -0.6344,
       -0.7071, -0.7730, -0.8315, -0.8819, -0.9239, -0.9569, -0.9808, -0.9952,
       -1.0, -0.9952, -0.9808, -0.9569, -0.9239, -0.8819, -0.8315, -0.7730,
       -0.7071, -0.6344, -0.5556, -0.4714, -0.3827, -0.2903, -0.1951, -0.0980,
        0.0,  0.0980,  0.1951,  0.2903,  0.3827,  0.4714,  0.5556,  0.6344,
        0.7071,  0.7730,  0.8315,  0.8819,  0.9239,  0.9569,  0.9808,  0.9952
    );

    constant N : integer := 64; -- Número de puntos
begin
    -- Proceso para almacenar las entradas
    process(clk, reset)
    begin
        if reset = '1' then
            idx <= 0;
            done <= '0';
            valid_out <= '0';
        elsif rising_edge(clk) then
            if valid_in = '1' and idx < N then
                input_buffer(idx) <= signed(data_in);
                idx <= idx + 1;
            elsif idx = N then
                done <= '1';
            end if;
        end if;
    end process;

    -- Proceso para calcular la IFFT usando tabla de cosenos y senos
    process(done)
        variable temp_real : real := 0.0;
        variable temp_imag : real := 0.0;
        variable result    : data_array;
    begin
        if done = '1' then
            for k in 0 to N-1 loop
                temp_real := 0.0;
                temp_imag := 0.0;
                for n in 0 to N-1 loop
                    temp_real := temp_real + real(to_integer(input_buffer(n))) * COS_TABLE((n*k) mod N);
                    temp_imag := temp_imag - real(to_integer(input_buffer(n))) * COS_TABLE((n*k + N/4) mod N);
                end loop;
                result(k) := to_signed(integer(temp_real / real(N)), 32); -- Normalización
            end loop;
            output_buffer <= result; -- Guarda el resultado calculado
        end if;
    end process;

    -- Proceso para la salida secuencial
    process(clk, reset)
    begin
        if reset = '1' then
            output_idx <= 0;
            valid_out <= '0';
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            if done = '1' and output_idx < N then
                data_out <= std_logic_vector(output_buffer(output_idx)); -- Envía muestra por muestra
                valid_out <= '1';
                output_idx <= output_idx + 1;
            else
                valid_out <= '0';
            end if;
        end if;
    end process;

end Behavioral;
----‐-------------------------------------------------------------------------------
--Prefijo Cíclico

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CyclicPrefixAdder is
    Generic (
        N  : integer := 64;  -- Número de muestras IFFT
        CP : integer := 16   -- Longitud del prefijo cíclico
    );
    Port (
        input_signal  : in  STD_LOGIC_VECTOR((2 * N * 16) - 1 downto 0);      -- Entrada: 2048 bits
        output_signal : out STD_LOGIC_VECTOR((2 * (N + CP) * 16) - 1 downto 0) -- Salida: 2560 bits
    );
end CyclicPrefixAdder;

architecture Behavioral of CyclicPrefixAdder is
begin
    process(input_signal)
    begin
        output_signal <= input_signal((2 * N * 16) - 1 downto (2 * (N - CP) * 16)) & input_signal;
    end process;
end Behavioral;
----‐-------------------------------------------------------------------------------
--Eliminación Prefijo Cíclico

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CyclicPrefixRemover is
    Generic (
        N  : integer := 64;  -- Número de muestras FFT
        CP : integer := 16   -- Longitud del prefijo cíclico
    );
    Port (
        input_signal  : in  STD_LOGIC_VECTOR((2 * (N + CP) * 16) - 1 downto 0); -- Entrada: 2560 bits
        output_signal : out STD_LOGIC_VECTOR((2 * N * 16) - 1 downto 0)         -- Salida: 2048 bits
    );
end CyclicPrefixRemover;

architecture Behavioral of CyclicPrefixRemover is
begin
    process(input_signal)
    begin
        output_signal <= input_signal((2 * N * 16) - 1 downto 0);
    end process;
end Behavioral;
----‐-------------------------------------------------------------------------------
--FFT

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity FFT_Manual is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        valid_in  : in  STD_LOGIC;
        data_in   : in  STD_LOGIC_VECTOR(31 downto 0);
        valid_out : out STD_LOGIC;
        data_out  : out STD_LOGIC_VECTOR(31 downto 0) -- Salida secuencial de 32 bits
    );
end FFT_Manual;

architecture Behavioral of FFT_Manual is
    type data_array is array (0 to 63) of signed(31 downto 0);
    signal input_buffer  : data_array := (others => (others => '0'));
    signal output_buffer : data_array := (others => (others => '0'));
    signal idx           : integer range 0 to 63 := 0;
    signal done          : STD_LOGIC := '0';
    signal output_idx    : integer range 0 to 63 := 0;

    -- Tabla de valores de coseno y seno
    type real_array is array (0 to 63) of real;
    constant COS_TABLE : real_array := (
        1.0,  0.9952,  0.9808,  0.9569,  0.9239,  0.8819,  0.8315,  0.7730,
        0.7071,  0.6344,  0.5556,  0.4714,  0.3827,  0.2903,  0.1951,  0.0980,
        0.0, -0.0980, -0.1951, -0.2903, -0.3827, -0.4714, -0.5556, -0.6344,
       -0.7071, -0.7730, -0.8315, -0.8819, -0.9239, -0.9569, -0.9808, -0.9952,
       -1.0, -0.9952, -0.9808, -0.9569, -0.9239, -0.8819, -0.8315, -0.7730,
       -0.7071, -0.6344, -0.5556, -0.4714, -0.3827, -0.2903, -0.1951, -0.0980,
        0.0,  0.0980,  0.1951,  0.2903,  0.3827,  0.4714,  0.5556,  0.6344,
        0.7071,  0.7730,  0.8315,  0.8819,  0.9239,  0.9569,  0.9808,  0.9952
    );

    constant N : integer := 64; -- Número de puntos
begin
    -- Almacena las entradas
    process(clk, reset)
    begin
        if reset = '1' then
            idx <= 0;
            done <= '0';
            valid_out <= '0';
        elsif rising_edge(clk) then
            if valid_in = '1' and idx < N then
                input_buffer(idx) <= signed(data_in);
                idx <= idx + 1;
            elsif idx = N then
                done <= '1';
            end if;
        end if;
    end process;

    -- Calcula la FFT utilizando la tabla de cosenos y senos
    process(done)
        variable temp_real, temp_imag : real;
        variable result               : data_array;
    begin
        if done = '1' then
            for k in 0 to N-1 loop
                temp_real := 0.0;
                temp_imag := 0.0;
                for n in 0 to N-1 loop
                    temp_real := temp_real + real(to_integer(input_buffer(n))) * COS_TABLE((n*k) mod N);
                    temp_imag := temp_imag + real(to_integer(input_buffer(n))) * COS_TABLE((n*k + N/4) mod N); -- 90° desfase para el seno
                end loop;
                result(k) := to_signed(integer(sqrt(temp_real*2 + temp_imag*2)), 32); -- Magnitud
            end loop;
            output_buffer <= result;
        end if;
    end process;

    -- Salida secuencial
    process(clk, reset)
    begin
        if reset = '1' then
            output_idx <= 0;
            valid_out <= '0';
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            if done = '1' and output_idx < N then
                data_out <= std_logic_vector(output_buffer(output_idx));
                valid_out <= '1';
                output_idx <= output_idx + 1;
            else
                valid_out <= '0';
            end if;
        end if;
    end process;

end Behavioral;
----‐-------------------------------------------------------------------------------
--Demodulación QAM

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Demapper_QAM4 is
    Port (
        symbol_in : in  STD_LOGIC_VECTOR(31 downto 0); -- Entrada de 32 bits: 16 bits real + 16 bits imag
        data_out  : out STD_LOGIC_VECTOR(1 downto 0)   -- Salida de bits (2 bits)
    );
end Demapper_QAM4;

architecture Behavioral of Demapper_QAM4 is
    -- Señales internas para las partes real e imaginaria
    signal real_part, imag_part : signed(15 downto 0); -- 16 bits cada uno (signed)
begin
    -- Extracción de las partes real e imaginaria
    real_part <= signed(symbol_in(31 downto 16)); -- Parte real (bits 31 a 16)
    imag_part <= signed(symbol_in(15 downto 0));  -- Parte imaginaria (bits 15 a 0)

    -- Proceso para determinar la salida de bits
    process(real_part, imag_part)
    begin
        if real_part >= 0 and imag_part >= 0 then
            data_out <= "00"; -- Primer cuadrante
        elsif real_part < 0 and imag_part >= 0 then
            data_out <= "01"; -- Segundo cuadrante
        elsif real_part >= 0 and imag_part < 0 then
            data_out <= "10"; -- Cuarto cuadrante
        else
            data_out <= "11"; -- Tercer cuadrante
        end if;
    end process;
end Behavioral;
----‐-------------------------------------------------------------------------------
--Unón de todos los bloques

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity OFDM_Simulation is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        data_in   : in  STD_LOGIC_VECTOR(1 downto 0);
        data_out  : out STD_LOGIC_VECTOR(1 downto 0);
        valid_in  : in  STD_LOGIC;
        valid_out : out STD_LOGIC
    );
end OFDM_Simulation;

architecture Behavioral of OFDM_Simulation is
    -- Componentes
    component IFFT_Manual
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            valid_in  : in  STD_LOGIC;
            data_in   : in  STD_LOGIC_VECTOR(31 downto 0);
            valid_out : out STD_LOGIC;
            data_out  : out STD_LOGIC_VECTOR(2047 downto 0)
        );
    end component;

    component FFT_Manual
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            valid_in  : in  STD_LOGIC;
            data_in   : in  STD_LOGIC_VECTOR(2047 downto 0);
            valid_out : out STD_LOGIC;
            data_out  : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component CyclicPrefixAdder is
        Generic (
            N  : integer := 64;
            CP : integer := 16
        );
        Port (
            input_signal  : in  STD_LOGIC_VECTOR(2047 downto 0);
            output_signal : out STD_LOGIC_VECTOR(2559 downto 0)
        );
    end component;

    component CyclicPrefixRemover is
        Generic (
            N  : integer := 64;
            CP : integer := 16
        );
        Port (
            input_signal  : in  STD_LOGIC_VECTOR(2559 downto 0);
            output_signal : out STD_LOGIC_VECTOR(2047 downto 0)
        );
    end component;

    component Mapper_QAM4
        Port (
            data_in    : in  STD_LOGIC_VECTOR(1 downto 0);
            symbol_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component Demapper_QAM4
        Port (
            symbol_in : in  STD_LOGIC_VECTOR(31 downto 0);
            data_out  : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    -- Señales internas
    signal mapped_data   : STD_LOGIC_VECTOR(31 downto 0);
    signal demapped_data : STD_LOGIC_VECTOR(1 downto 0);
    signal d_valid  : STD_LOGIC := '0';
    signal d_data   : STD_LOGIC_VECTOR(2047 downto 0);
    signal d_data_t   : STD_LOGIC_VECTOR(31 downto 0);
    signal remove   : STD_LOGIC_VECTOR(2559 downto 0);

begin
    -- Mapper (QAM4)
    Mapper_Inst: entity work.Mapper_QAM4
        port map (
            data_in    => data_in,
            symbol_out => mapped_data
        );

    -- *IFFT Manual*
    IFFT_Inst: entity work.IFFT_Manual
        port map (
            clk       => clk,
            reset     => reset,
            valid_in  => valid_in,
            data_in   => mapped_data,
            valid_out => d_valid,
            data_out  => d_data_t
        );

    -- *Cyclic Prefix Adder*
    CyclicPrefixAdder_Inst: entity work.CyclicPrefixAdder
        generic map (
            N  => 64,
            CP => 16
        )
        port map (
            input_signal  => d_data,
            output_signal => open
        );

    -- *Cyclic Prefix Remover*
    CyclicPrefixRemover_Inst: entity work.CyclicPrefixRemover
        generic map (
            N  => 64,
            CP => 16
        )
        port map (
            input_signal  => remove,
            output_signal => open
        );

    -- *FFT Manual*
    FFT_Inst: entity work.FFT_Manual
        port map (
            clk       => clk,
            reset     => reset,
            valid_in  => d_valid,
            data_in   => d_data_t,
            valid_out => d_valid,
            data_out  => open
        );

    -- Demapper (QAM4)
    Demapper_Inst: entity work.Demapper_QAM4
        port map (
            symbol_in => mapped_data,
            data_out  => data_out
        );

    -- La señal de salida de validez
    valid_out <= valid_in;

end Behavioral;
