import ipywidgets as widgets
from IPython.display import display
from ipywidgets import GridBox, Layout
import serial

# Change this to match your FPGA's serial port
SERIAL_PORT = "/dev/ttyUSB1"  # Adjust for Windows (e.g., 'COM3')
BAUD_RATE = 9600              # Match FPGA baud rate

# Open serial connection
try:
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
except serial.SerialException as e:
    print(f"Error opening serial port: {e}")
    ser = None  # Prevents crashes if the serial port is unavailable

def on_button_clicked(b):
    """Handles button clicks to toggle LED states via UART."""
    
    if ser:  # Only send commands if serial is available
        # Extract LED number from the button label
        led_number = b.description.split()[1]

        # Determine new state based on color
        if b.style.button_color == 'lightgray':
            if b.description == "LED 1":
                b.style.button_color = 'lightgreen'  # ON state
            else:
                b.style.button_color = 'lightcoral'  # ON state
            state = "ON"
        else:
            b.style.button_color = 'lightgray'  # OFF state
            state = "OFF"

        # Send the formatted UART command
        command = f"LED{led_number} {state}\n"
        ser.write(command.encode('utf-8'))
        print(f"Sent: {command.strip()}")  # Debugging print

# Create five buttons with labels and layout
buttons = { 
    'up': widgets.Button(description='LED 2', layout=Layout(width='60px', height='50px')),
    'left': widgets.Button(description='LED 5', layout=Layout(width='60px', height='50px')),
    'center': widgets.Button(description='LED 1', layout=Layout(width='60px', height='50px')),
    'right': widgets.Button(description='LED 3', layout=Layout(width='60px', height='50px')),
    'down': widgets.Button(description='LED 4', layout=Layout(width='60px', height='50px'))
}

# Initialize buttons and attach event handler
for button in buttons.values():
    button.style.button_color = 'lightgray'
    button.on_click(on_button_clicked)

# Define a grid layout for the buttons
grid = GridBox(
    children=[
        widgets.Label(), buttons['up'], widgets.Label(),            
        buttons['left'], buttons['center'], buttons['right'],        
        widgets.Label(), buttons['down'], widgets.Label()            
    ],
    layout=Layout(
        display='grid',
        grid_template_columns="auto auto auto",
        grid_template_rows="auto auto auto",
        justify_content="center",
        align_content="center",
        gap="0px"
    )
)

# Display the GUI
display(grid)

