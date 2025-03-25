ifeq ($(shell bash -c 'type -p icoprog'),)
SSH_RASPI ?= ssh pi@raspi
else
SSH_RASPI ?= sh -c
endif

help:
	@echo
	@echo "make spi_slave.json      run synthesis, generate JSON netlist"
	@echo "make spi_slave.asc       run place and route, generate IceStorm ASCII file"
	@echo "make spi_slave.bin       run timing analysis, generate iCE40 BIN file"
	@echo
	@echo "make prog_sram         FPGA SRAM programming, (re)starts FPGA from SRAM"
	@echo "make prog_flash        serial flash programming, does not touch FPGA"
	@echo "make prog_erase        erase first flash block"
	@echo
	@echo "make reset_halt        stop FPGA and keep in reset"
	@echo "make reset_boot        (re)start FPGA from serial flash"
	@echo
	@echo "make clean             remove output files"
	@echo

spi_slave.json: spi_slave.v
	yosys -p 'synth_ice40 -top spi_slave -json spi_slave.json' spi_slave.v

spi_slave.asc: spi_slave.json icoboard.pcf
	nextpnr-ice40 --hx8k --package ct256 --json spi_slave.json --pcf icoboard.pcf --asc spi_slave.asc

spi_slave.bin: spi_slave.asc
	icetime -d hx8k -c 25 spi_slave.asc
	icepack spi_slave.asc spi_slave.bin

prog_sram: spi_slave.bin
	$(SSH_RASPI) 'icoprog -p' < spi_slave.bin

prog_flash: spi_slave.bin
	$(SSH_RASPI) 'icoprog -f' < spi_slave.bin

prog_erase:
	$(SSH_RASPI) 'icoprog -e'

reset_halt:
	$(SSH_RASPI) 'icoprog -R'

reset_boot:
	$(SSH_RASPI) 'icoprog -b'

clean:
	rm spi_slave.json spi_slave.asc spi_slave.bin

.PHONY: prog_sram prog_flash reset_halt reset_boot clean
