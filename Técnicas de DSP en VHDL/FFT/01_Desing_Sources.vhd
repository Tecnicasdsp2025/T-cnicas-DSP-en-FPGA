library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FFT_5KHz is
    Port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        tvalid_in    : in  std_logic;
        tdata_in     : in  std_logic_vector(15 downto 0); -- Entrada de 16 bits
        tlast_in     : in  std_logic;
        tvalid_out   : out std_logic;
        tdata_out    : out std_logic_vector(31 downto 0); -- Salida de 32 bits
        tlast_out    : out std_logic
    );
end FFT_5KHz;

architecture Behavioral of FFT_5KHz is

    component xfft_0
        Port (
            aclk                          : in  std_logic;
            s_axis_config_tdata           : in  std_logic_vector(15 downto 0); -- Configuración (16 bits)
            s_axis_config_tvalid          : in  std_logic;
            s_axis_data_tvalid            : in  std_logic;
            s_axis_data_tdata             : in  std_logic_vector(31 downto 0);
            s_axis_data_tlast             : in  std_logic;
            m_axis_data_tvalid            : out std_logic;
            m_axis_data_tdata             : out std_logic_vector(31 downto 0);
            m_axis_data_tlast             : out std_logic;
            event_frame_started           : out std_logic;
            event_tlast_unexpected        : out std_logic;
            event_tlast_missing           : out std_logic;
            event_data_in_channel_halt    : out std_logic
        );
    end component;

    -- Señal interna para convertir tdata_in (16 bits) a 32 bits
    signal tdata_in_32       : std_logic_vector(31 downto 0);
    signal config_tdata      : std_logic_vector(15 downto 0) := (others => '0'); -- Ajustado a 16 bits
    signal config_tvalid     : std_logic := '0';

    -- Señales para eventos
    signal event_frame_started        : std_logic;
    signal event_tlast_unexpected     : std_logic;
    signal event_tlast_missing        : std_logic;
    signal event_data_in_channel_halt : std_logic;

begin

    -- Extensión de tdata_in a 32 bits
    tdata_in_32 <= std_logic_vector(resize(signed(tdata_in), 32)); -- Extiende con signo

    -- Generar señal de configuración
    process(clk, rst)
    begin
        if rst = '1' then
            config_tvalid <= '0';
        elsif rising_edge(clk) then
            if config_tvalid = '0' then
                config_tvalid <= '1'; -- Enviar configuración al inicio
            else
                config_tvalid <= '0';
            end if;
        end if;
    end process;

    -- Instancia del Bloque FFT
    fft_inst : xfft_0
        port map (
            aclk                          => clk,
            s_axis_config_tdata           => config_tdata, -- Ahora tiene 16 bits
            s_axis_config_tvalid          => config_tvalid,
            s_axis_data_tvalid            => tvalid_in,
            s_axis_data_tdata             => tdata_in_32,
            s_axis_data_tlast             => tlast_in,
            m_axis_data_tvalid            => tvalid_out,
            m_axis_data_tdata             => tdata_out,
            m_axis_data_tlast             => tlast_out,
            event_frame_started           => event_frame_started,
            event_tlast_unexpected        => event_tlast_unexpected,
            event_tlast_missing           => event_tlast_missing,
            event_data_in_channel_halt    => event_data_in_channel_halt
        );

end Behavioral;
