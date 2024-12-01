import numpy as np
import matplotlib.pyplot as plt

# Parámetros
num_subcarriers = 64      # Número de subportadoras
num_symbols = 10          # Número de símbolos OFDM
cp_len = 16               # Longitud del prefijo cíclico
mod_order = 4             # Orden de modulación (QAM-4)

# Generar datos aleatorios
data = np.random.randint(0, mod_order, size=(num_subcarriers, num_symbols))

# Modulación QAM
qam_symbols = (2*(data % 2) - 1) + 1j * (2*(data // 2) - 1)

# Aplicar IFFT
ifft_data = np.fft.ifft(qam_symbols, axis=0)

# Añadir prefijo cíclico
cyclic_prefix = ifft_data[-cp_len:, :]
ofdm_signal = np.vstack([cyclic_prefix, ifft_data])

# Canal simulado (canal AWGN)
snr_db = 20  # Relación señal a ruido en dB
snr_linear = 10**(snr_db / 10)
noise_power = 1 / (2 * snr_linear)
noise = np.sqrt(noise_power) * (np.random.randn(*ofdm_signal.shape) + 1j*np.random.randn(*ofdm_signal.shape))

received_signal = ofdm_signal + noise

# Eliminar prefijo cíclico
received_signal = received_signal[cp_len:, :]

# Aplicar FFT
received_symbols = np.fft.fft(received_signal, axis=0)

# Demodulación QAM
demod_data = np.zeros_like(data, dtype=np.complex_)
demod_data[np.real(received_symbols) > 0] = 1
demod_data[np.imag(received_symbols) > 0] += 1j

# Visualizar los datos transmitidos, recibidos y demodulados
plt.figure(figsize=(15, 5))

# Gráfica de Datos Transmitidos
plt.subplot(1, 3, 1)
plt.title("Datos Transmitidos")
plt.plot(np.real(qam_symbols.flatten()), np.imag(qam_symbols.flatten()), 'o')
plt.xlabel('Parte Real')
plt.ylabel('Parte Imaginaria')

# Gráfica de Datos Recibidos
plt.subplot(1, 3, 2)
plt.title("Datos Recibidos")
plt.plot(np.real(received_symbols.flatten()), np.imag(received_symbols.flatten()), 'o')
plt.xlabel('Parte Real')
plt.ylabel('Parte Imaginaria')

# Gráfica de Datos Demodulados
plt.subplot(1, 3, 3)
plt.title("Datos Demodulados")
plt.plot(np.real(demod_data.flatten()), np.imag(demod_data.flatten()), 'o')
plt.xlabel('Parte Real')
plt.ylabel('Parte Imaginaria')

plt.tight_layout()
plt.show()