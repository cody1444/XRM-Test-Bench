# Tools
YOSYS = yosys
NEXTPNR = nextpnr-ice40
ICEPACK = icepack
ICETIME = icetime
ICEPROG = iceprog

# Device settings
DEVICE = hx1k
PACKAGE = tq144
PCF_FILE = constraints/constraints.pcf
TOP_MODULE = spi_test

# Directories
SRC_DIR = src
BUILD_DIR = build

# Verilog source files
SRC = $(SRC_DIR)/spi_test.v

# Output files
JSON = $(BUILD_DIR)/$(TOP_MODULE).json
ASC = $(BUILD_DIR)/$(TOP_MODULE).asc
BIN = $(BUILD_DIR)/$(TOP_MODULE).bin

# Default target: complete FPGA flow
all: bitstream

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Synthesize Verilog using Yosys
$(JSON): $(SRC) | $(BUILD_DIR)
	$(YOSYS) -p "read_verilog $(SRC); synth_ice40 -top $(TOP_MODULE) -json $(JSON)"

# Place & route with NextPNR
$(ASC): $(JSON) $(PCF_FILE) $(SDC_FILE)
	$(NEXTPNR) --package $(PACKAGE) --$(DEVICE) --json $(JSON) --pcf $(PCF_FILE) --asc $(ASC)

# Convert to bitstream
$(BIN): $(ASC)
	$(ICEPACK) $(ASC) $(BIN)

# Run full synthesis & bitstream generation
bitstream: $(BIN)

# Timing analysis
timing: $(ASC)
	$(ICETIME) -d $(DEVICE) -t $(ASC)

# Upload bitstream to FPGA
upload: $(BIN)
	$(ICEPROG) $(BIN)

# Clean build files
clean:
	rm -rf $(BUILD_DIR)
