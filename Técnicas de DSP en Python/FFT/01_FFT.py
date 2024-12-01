import numpy as np
import matplotlib.pyplot as plt

# Parámetros de la señal
fs = 100000  # Frecuencia de muestreo (100 kHz)
f = 10000    # Frecuencia de la señal senoidal (10 kHz)
t = np.arange(0, 0.01, 1/fs)  # Vector de tiempo de 10 ms
amplitud= 1000

# Generar señal senoidal de 10 kHz
senoidal = np.sin(2 * np.pi * f * t)

# Calcular la FFT de la señal
N = 1024  # Número de puntos para la FFT
fft_result = np.fft.fft(senoidal, N)
frecuencias = np.fft.fftfreq(N, d=1/fs)

# Obtener magnitud de la FFT
magnitude = np.abs(fft_result)

# Graficar la señal y su espectro de magnitud
plt.figure(figsize=(12, 6))

# Gráfico de la señal senoidal
plt.subplot(2, 1, 1)
plt.plot(t, senoidal)
plt.title("Señal Senoidal de 10 kHz")
plt.xlabel("Tiempo [s]")
plt.ylabel("Amplitud")
plt.grid()

# Gráfico de la magnitud de la FFT
plt.subplot(2, 1, 2)
plt.plot(frecuencias[:N//2], magnitude[:N//2])
plt.title("Espectro de Magnitud de la Señal (FFT)")
plt.xlabel("Frecuencia [Hz]")
plt.ylabel("Magnitud")
plt.grid()
plt.tight_layout()
plt.show()
