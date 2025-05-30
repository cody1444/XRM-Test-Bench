import RPi.GPIO as GPIO
import time

# Set pin numbering convention: BCM = GPIO number, BOARD = physical pin number
GPIO.setmode(GPIO.BCM)
#GPIO.setmode(GPIO.BOARD)

chan_list = [18,22,23,7,19,16,20,21]

GPIO.setup(chan_list, GPIO.OUT)

def write_byte(value):
    for i,pin in enumerate(chan_list):
        GPIO.output(pin, (value >> pin) & 1)

try:
    write_byte(0x00)
    time.sleep(2)

    write_byte(0xFF)
    time.sleep(2)

    write_byte(0x55)
    time.sleep(2)

    write_byte(0xAA)
    time.sleep(2)

finally:
    GPIO.cleanup()
