import serial
import time

# Change this to match your FPGA's serial port
SERIAL_PORT = "/dev/ttyUSB1"  # Adjust for Windows (e.g., 'COM3')
BAUD_RATE = 9600              # Match FPGA baud rate

def send_led_command(ser, led, state):
    """Sends a formatted LED command to the FPGA."""
    command = f"LED{led} {state}\n"
    ser.write(command.encode('utf-8'))  # Send command
    print(f"Sent: {command.strip()}")   # Debug print

def test_all_leds():
    """Turns each LED ON and OFF sequentially."""
    try:
        with serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1) as ser:
            print(f"Connected to {SERIAL_PORT} at {BAUD_RATE} baud.")

            while True:
                for led in range(1, 6):  # LED1 to LED5
                    send_led_command(ser, led, "ON")   # Turn LED ON
                    time.sleep(1)  # Wait 1 sec
                    send_led_command(ser, led, "OFF")  # Turn LED OFF
                    time.sleep(1)  # Wait 1 sec

    except serial.SerialException as e:
        print(f"Serial Error: {e}")

if __name__ == "__main__":
    test_all_leds()
