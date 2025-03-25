#!/usr/bin/env python3
import spidev

def main():
    # Create and open the SPI connection.
    spi = spidev.SpiDev()
    bus = 0       # SPI bus 0 on the Raspberry Pi
    device = 1    # Using device 1 (typically corresponds to CE1)
    spi.open(bus, device)
    
    # Configure SPI parameters.
    spi.mode = 0             # SPI mode (CPOL=0, CPHA=0)
    spi.max_speed_hz = 10000000  # 10 MHz clock speed (adjust as needed)
    
    # Test values
    test_values = [0x00, 0xFF, 0xA5, 0x5A, 0xC3, 0x3C]

    print("=== Sending 10 Sequential Transactions ===")
    
    # Loop to send 10 pieces of data sequentially.
    for value in test_values:
        rx_data = spi.xfer2([value])[0]
        #print(rx_data)
        print(f"Sent: 0x{value:02X} | Received: 0x{rx_data:02X}")
    
    # Close the SPI connection.
    spi.close()
    print("=== SPI test completed ===")

if __name__ == "__main__":
    main()

