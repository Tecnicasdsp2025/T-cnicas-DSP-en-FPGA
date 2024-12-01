import numpy as np
from scipy.signal import buttord, butter, freqz
import matplotlib.pyplot as plt

# Especificaciones del filtro pasabanda
fp1 = 4e3  # Frecuencia de paso baja en Hz
fp2 = 12e3  # Frecuencia de paso alta en Hz
fs1 = 3e3  # Frecuencia de parada baja en Hz
fs2 = 15e3  # Frecuencia de parada alta en Hz
delta_p = 0.1  # Atenuación máxima en la banda de paso
delta_s = 0.1  # Atenuación mínima en la banda de parada
fsamp = 50e3  # Frecuencia de muestreo (50 kHz)

# Convertir frecuencias de Hz a radianes por muestra
wp = [fp1 / (fsamp / 2), fp2 / (fsamp / 2)]
ws = [fs1 / (fsamp / 2), fs2 / (fsamp / 2)]

# Calcular el orden mínimo necesario y la frecuencia de corte natural
N, wn = buttord(wp, ws, -20*np.log10(1-delta_p), -20*np.log10(delta_s))
# Generar los coeficientes del filtro Butterworth pasabanda
b, a = butter(N, wn, btype='band')
# Calcular la respuesta en frecuencia
w, h = freqz(b, a, worN=8000)

# Escala de punto fijo
escala = 2**10
factor_escala = 4

# Convertimos los coeficientes a formato de punto fijo
b_fixed = np.round((b * escala) / factor_escala).astype(int)
a_fixed = np.round((a * escala) / factor_escala).astype(int)

print("Coeficientes b en punto fijo ajustados:", b_fixed)
print("Coeficientes a en punto fijo ajustados:", a_fixed)

# Graficar la respuesta en frecuencia en dB
plt.figure()
plt.plot(0.5 * fsamp * w / np.pi, 20 * np.log10(abs(h)), 'b')
plt.axvline(fp1, color='k', linestyle='--', label='Frecuencia de paso baja')
plt.axvline(fp2, color='k', linestyle='--', label='Frecuencia de paso alta')
plt.title("Respuesta en frecuencia del filtro Butterworth Pasabanda")
plt.xlabel('Frecuencia (Hz)')
plt.ylabel('Amplitud (dB)')
plt.grid()
plt.legend()
plt.show()