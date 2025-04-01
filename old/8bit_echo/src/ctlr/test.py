import spidev
import time

spi = spidev.SpiDev(0, 1) # create spi object connecting to /dev/spidev0.1
spi.open(0,1)
spi.max_speed_hz = 5000 # set speed to 1 Khz
spi.mode = 0b01 
message = [0x55, 0xA5, 0x3C, 0x7F]


try:
    for data in message:
        print("MODE:", spi.mode)
        response = spi.xfer2([data])
        print(f"Sent: 0x{data:02X} | Received: 0x{response[0]:02X}")  # Print received byte
        time.sleep(1)
finally:
    spi.close() # always close the port before exit
