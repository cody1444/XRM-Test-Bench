ifeq ($(shell bash -c 'type -p icoprog'),)
SSH_RASPI ?= ssh pi@raspi
else
SSH_RASPI ?= sh -c
endif

help:
	@echo
	@echo "make spi_ctlr.json      run synthesis, generate JSON netlist"
	@echo "make spi_ctlr.asc       run place and route, generate IceStorm ASCII file"
	@echo "make spi_ctlr.bin       run timing analysis, generate iCE40 BIN file"
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

spi_ctlr.json: spi_ctlr.v
	yosys -p 'synth_ice40 -top spi_ctlr -json spi_ctlr.json' spi_ctlr.v

spi_ctlr.asc: spi_ctlr.json ctlr.pcf
	nextpnr-ice40 --hx8k --package ct256 --json spi_ctlr.json --pcf ctlr.pcf --asc spi_ctlr.asc

spi_ctlr.bin: spi_ctlr.asc
	icetime -d hx8k -c 25 spi_ctlr.asc
	icepack spi_ctlr.asc spi_ctlr.bin

prog_sram: spi_ctlr.bin
	$(SSH_RASPI) 'icoprog -p' < spi_ctlr.bin

prog_flash: spi_ctlr.bin
	$(SSH_RASPI) 'icoprog -f' < spi_ctlr.bin

prog_erase:
	$(SSH_RASPI) 'icoprog -e'

reset_halt:
	$(SSH_RASPI) 'icoprog -R'

reset_boot:
	$(SSH_RASPI) 'icoprog -b'

clean:
	rm spi_ctlr.json spi_ctlr.asc spi_ctlr.bin

.PHONY: prog_sram prog_flash reset_halt reset_boot clean
