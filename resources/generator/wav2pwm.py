import wave
import numpy as np

src_file = 'ending_loop_u8.wav' # 预处理: ffmpeg -i 输入文件.wav -ar 6400 -ac 1 -acodec pcm_u8 输出文件.wav

# PWM period = 255 sys_clk cycles
pwm_period = 255

src = wave.open(src_file, 'rb')

print(src.getparams())
channels, _, framerate, nframes, _, _ = src.getparams()
print(nframes)

# Read all frames and convert to numpy array
pcm = np.frombuffer(src.readframes(nframes), np.uint8).astype(np.float64)

# Extract left channel if it is a stereo file
pcm = pcm.reshape(nframes, channels)[:, 0]
print(pcm)

min_val = np.min(pcm)
max_val = np.max(pcm)
percentage = (pcm - min_val) / (max_val - min_val)

# Convert to PWM
pwm = np.round(percentage * pwm_period).astype(np.uint8)

# output to file as binary, 4 values per line
with open(src_file[0: src_file.rfind('.')] + '.coe', 'w') as f:
    print('memory_initialization_radix=16;', file = f)
    print('memory_initialization_vector=', file = f)
    pwm_hex = np.array(pwm, dtype = np.uint8).tobytes().hex()
    f.write(',\n'.join([pwm_hex[i: i+2] for i in range(0, len(pwm_hex) - 1, 2)]))
    print(';', file = f)
