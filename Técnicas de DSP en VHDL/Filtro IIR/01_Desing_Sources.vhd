library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IIR_Butterworth is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        data_in  : in  std_logic_vector(15 downto 0); -- Entrada digital
        data_out : out std_logic_vector(15 downto 0)  -- Salida del filtro
    );
end IIR_Butterworth;

architecture Behavioral of IIR_Butterworth is

    -- Coeficientes del filtro Butterworth IIR en punto fijo (valores obtenidos de Python)
constant b0 : signed(15 downto 0) := to_signed(5, 16);
constant b1 : signed(15 downto 0) := to_signed(24, 16);
constant b2 : signed(15 downto 0) := to_signed(48, 16);
constant b3 : signed(15 downto 0) := to_signed(48, 16);
constant b4 : signed(15 downto 0) := to_signed(24, 16);
constant b5 : signed(15 downto 0) := to_signed(5, 16);

constant a0 : signed(15 downto 0) := to_signed(1024, 16);
constant a1 : signed(15 downto 0) := to_signed(-2296, 16);
constant a2 : signed(15 downto 0) := to_signed(2474, 16);
constant a3 : signed(15 downto 0) := to_signed(-1432, 16);
constant a4 : signed(15 downto 0) := to_signed(442, 16);
constant a5 : signed(15 downto 0) := to_signed(-57, 16);




    -- Señales internas para mantener los valores anteriores de entrada y salida
    type signed_array is array(0 to 5) of signed(15 downto 0);
    signal x : signed_array := (others => (others => '0'));  -- Entradas pasadas
    signal y : signed_array := (others => (others => '0'));  -- Salidas pasadas

    signal y_current : signed(15 downto 0);  -- Salida actual del filtro

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reiniciar los registros en caso de reset
                x <= (others => (others => '0'));
                y <= (others => (others => '0'));
                y_current <= (others => '0');
            else
                -- Implementación del filtro Butterworth IIR de orden 5
                
y_current <= resize(
    (b0 * signed(data_in) + 
     b1 * x(1) + 
     b2 * x(2) + 
     b3 * x(3) + 
     b4 * x(4) + 
     b5 * x(5) -
     (a1 * y(1) + 
      a2 * y(2) + 
      a3 * y(3) + 
      a4 * y(4) + 
      a5 * y(5))) srl 10, 16);



                -- Actualizar los valores anteriores para el siguiente ciclo
                x(5) <= x(4);
                x(4) <= x(3);
                x(3) <= x(2);
                x(2) <= x(1);
                x(1) <= x(0);
                x(0) <= signed(data_in);

                y(5) <= y(4);
                y(4) <= y(3);
                y(3) <= y(2);
                y(2) <= y(1);
                y(1) <= y(0);
                y(0) <= y_current;
            end if;
        end if;
    end process;

    -- Asignación de la salida, asegurando que esté dentro del rango de 16 bits
    data_out <= std_logic_vector(y_current);

end Behavioral;
