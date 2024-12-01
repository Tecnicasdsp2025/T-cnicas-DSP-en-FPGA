import numpy as np
from scipy.signal import firwin, freqz
import matplotlib.pyplot as plt

# Especificaciones del filtro Pasa baja
fs = 10000  # Frecuencia de muestreo en Hz (10 kHz)
wc = np.pi / 4  # Frecuencia de corte en radianes/muestra
beta = 3.4  # Parámetro beta para la ventana Kaiser
num_taps = 32  # Número de coeficientes del filtro

# Diseño del filtro FIR usando la ventana Kaiser
taps = firwin(numtaps=num_taps, cutoff=wc / np.pi, window=('kaiser', beta), pass_zero='lowpass')

# Normalización de los coeficientes
max_abs_tap = np.max(np.abs(taps))
normalized_taps = taps / max_abs_tap

# Imprime los coeficientes normalizados en consola
print("Coeficientes normalizados del filtro FIR (16 taps):")
print(normalized_taps)

# Respuesta en frecuencia del filtro
w, h = freqz(taps, worN=8000, fs=fs)

# Encuentra la frecuencia donde la atenuación es -40 dB
h_dB = 20 * np.log10(np.abs(h))
attenuation_40db_idx = np.where(h_dB <= -40)[0]
attenuation_40db_freq = w[attenuation_40db_idx[0]] if len(attenuation_40db_idx) > 0 else None

# Cálculo del ancho de banda
cutoff_freq_khz = wc * fs / (2 * np.pi * 1000)  # en kHz
attenuation_40db_freq_khz = attenuation_40db_freq / 1000 if attenuation_40db_freq else None  # en kHz
bandwidth_khz = cutoff_freq_khz - attenuation_40db_freq_khz if attenuation_40db_freq else None

# Ganancia
gain = np.max(20 * np.log10(np.abs(h)))

# Visualización de la respuesta en frecuencia
plt.figure()
plt.plot(w / 1000, h_dB, label="Respuesta del filtro")  # Convertimos w a kHz
plt.axvline(x=cutoff_freq_khz, color='r', linestyle='--', label='Frecuencia de corte ({} kHz)'.format(cutoff_freq_khz))
if attenuation_40db_freq_khz:
    plt.axvline(x=attenuation_40db_freq_khz, color='b', linestyle='--', label='Inicio de atenuación (-40 dB) en {} kHz'.format(attenuation_40db_freq_khz))
plt.axhline(y=-3, color='g', linestyle='--', label='-3 dB')
plt.xlabel('Frecuencia (kHz)')
plt.ylabel('Amplitud (dB)')
plt.title('Respuesta en frecuencia del filtro FIR ')
plt.legend()
plt.grid()
plt.show()

# Guarda los coeficientes en un archivo de texto
output_path = r"C:\Users\ASUS\OneDrive\Escritorio\Kevin Jaramillo\9no Semestre\Tesis\01 FIR pasa baja\coeficientes_16_taps.txt"
with open(output_path, 'w') as f:
    for coef in normalized_taps:
        f.write(f"{coef}\n")

print(f"Coeficientes guardados en: {output_path}")
