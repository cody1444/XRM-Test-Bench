import RPi.GPIO as GPIO
import time

# Set pin numbering convention: BCM = GPIO number, BOARD = physical pin number
# Enter "pinout" in bash to see diagram of connector
GPIO.setmode(GPIO.BCM)
#GPIO.setmode(GPIO.BOARD)

# Set up GPIO pins, ONLY WORKS IN BCM MODE
chan_list = [18,22,23,7,19,16,20,21,24]

for i in chan_list:
    GPIO.setup(i, GPIO.OUT)

def write_byte(value):
    print(f"Sending: 0x{value:02X} -> {value:08b}")
    for i,pin in enumerate(chan_list[:-1]):
        print(f"Shift {i}: {value>>i:08b} -> {value>>i&1}")
        GPIO.output(pin, value>>i&1)
        print(f"Sending bit {i}...")
        if pin == chan_list[-2]:
            print("Write bit sent...\n")
            GPIO.output(chan_list[-1], 1)
            GPIO.output(chan_list[-1], 0)

try:
    while(True):
        input_str = input("Enter hex (q to quit): ")
        if (input_str == 'q'):
            break
        integer = int(input_str, 16) 
        write_byte(integer)
        time.sleep(2)
        
finally:
    GPIO.cleanup()
