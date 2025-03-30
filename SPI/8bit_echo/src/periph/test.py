import spidev
import time

spi = spidev.SpiDev(0, 1) # create spi object connecting to /dev/spidev0.1
spi.max_speed_hz = 100000 # set speed to 100 Khz
spi.mode = 1
message = [0x00, 0xA5, 0x3C, 0x7F]

try:
    for data in message:
        response = spi.xfer2([data])[0]
        #print(response)
        print(f"Sent: 0x{data:02X} | Received: 0x{response:02X}")  # Print received byte
        #time.sleep(1)
finally:
    spi.close() # always close the port before exit
