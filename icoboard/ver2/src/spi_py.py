import spidev

spi = spidev.SpiDev()
spi.open(0,1)
spi.mode = 0            # CPOL=0, CPHA=0
spi.max_speed_hz = 50_000
spi.xfer2([0x00, 0xcc, 0x00])
spi.close()

