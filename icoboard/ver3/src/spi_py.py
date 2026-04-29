import spidev

spi = spidev.SpiDev()
spi.open(0,1)
spi.mode = 0            # CPOL=0, CPHA=0
spi.max_speed_hz = 50_000
tx = spi.xfer2([0x00, 0x80]) # write 10001000 to output pin 0
print("TX:", [hex(b) for b in tx])
rx = spi.xfer2([0x01, 0x00, 0x00]) # read from mem[0] (output pin 0)
print("RX:", [hex(b) for b in rx])
spi.close()

