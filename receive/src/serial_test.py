import serial
import time

# Change this to match your FPGA's serial port
SERIAL_PORT = "/dev/ttyUSB1"  # Adjust for Windows (e.g., 'COM3')
BAUD_RATE = 9600              # Match FPGA baud rate

def send_led_command(ser, led, state):
    """Sends a formatted LED command to the FPGA."""
    command = f"LED{led} {state}\n"
    ser.write(command.encode('utf-8'))  # ✅ Use ser.write(), not serial.write()
    print(f"Sent: {command.strip()}")  # Debug print

def toggle_leds():
    """Alternates LED1 ON and OFF every second."""
    try:
        with serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1) as ser:  # ✅ Define ser here
            print(f"Connected to {SERIAL_PORT} at {BAUD_RATE} baud.")

            while True:
                send_led_command(ser, 1, "ON")   # ✅ Pass ser as argument
                time.sleep(1)
                send_led_command(ser, 1, "OFF")  # ✅ Pass ser as argument
                time.sleep(1)

    except serial.SerialException as e:
        print(f"Serial Error: {e}")

if __name__ == "__main__":
    toggle_leds()
