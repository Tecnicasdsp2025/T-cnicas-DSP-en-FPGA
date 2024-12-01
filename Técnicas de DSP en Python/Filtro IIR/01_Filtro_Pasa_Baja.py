import numpy as np
from scipy.signal import buttord, butter, freqz
import matplotlib.pyplot as plt

# Especificaciones del filtro
fp = 6e3  # Frecuencia de paso en Hz
fs = 10e3  # Frecuencia de parada en Hz
delta_p = 0.1  # Atenuación máxima en la banda de paso
delta_s = 0.1  # Atenuación mínima en la banda de parada
# Frecuencia de muestreo (debe ser mayor que el doble de la frecuencia de parada)
fsamp = 50e3  # Por ejemplo, 50 kHz
# Convertir frecuencias de Hz a radianes por muestra
wp = fp / (fsamp / 2)  # Frecuencia de paso normalizada
ws = fs / (fsamp / 2)  # Frecuencia de parada normalizada
# Calcular el orden mínimo necesario y la frecuencia de corte natural
N, wn = buttord(wp, ws, -20*np.log10(1-delta_p), -20*np.log10(delta_s))
# Generar los coeficientes del filtro Butterworth
b, a = butter(N, wn, 'low')
# Calcular la respuesta en frecuencia
w, h = freqz(b, a, worN=8000)

# Escala de punto fijo (ajustamos para reducir la ganancia)
escala = 2**10  # Escala original
factor_escala = 4  # Factor de división para reducir la ganancia

# Convertimos los coeficientes a formato de punto fijo
b_fixed = np.round((b * escala) / factor_escala).astype(int)
a_fixed = np.round((a * escala) / factor_escala).astype(int)

print("Coeficientes b en punto fijo ajustados:", b_fixed)
print("Coeficientes a en punto fijo ajustados:", a_fixed)
# Graficar la respuesta en frecuencia en dB
plt.figure()
plt.plot(0.5 * fsamp * w / np.pi, 20 * np.log10(abs(h)), 'b')
plt.plot(fp, 20 * np.log10(1-delta_p), 'ko')
plt.plot(fs, 20 * np.log10(delta_s), 'ko')
plt.axvline(fp, color='k', linestyle='--')
plt.axvline(fs, color='k', linestyle='--')
plt.title("Respuesta en frecuencia del filtro Butterworth de paso bajo")
plt.xlabel('Frecuencia (Hz)')
plt.ylabel('Amplitud (dB)')
plt.grid()
plt.show()