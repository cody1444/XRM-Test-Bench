import spidev
import time

# Create an SPI instance
spi = spidev.SpiDev()
# Open SPI bus 0, device 0 (CE1) - change device number if needed
spi.open(0, 1)

# Configure SPI settings
spi.mode = 0            # SPI mode (clock polarity and phase)
spi.max_speed_hz = 100000  # Adjust speed as needed

# Brief pause to allow the slave to settle
time.sleep(0.1)

# Data to send (for example, 0xAA, which is 10101010 in binary)
tx_data = 0xAF
print(f"Transmitting: 0x{tx_data:02X}")

# Send data and receive response in one transaction
rx_data = spi.xfer2([tx_data])[0]
print(f"Received: 0x{rx_data:02X}")

# Close the SPI connection
spi.close()

