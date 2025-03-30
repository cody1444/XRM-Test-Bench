module top (
    input wire  CLK,		// system clock (internal logic)
    input wire SCLK,		// SPI clock
    input wire  CS,		// Chip select (active low)
    input wire MOSI,		// Ctlr Out, Periph In
    output wire [63:0] pins,	// Icoboard output pins
);

    wire [7:0] COMMAND_BYTE;
    wire BYTE_READY;

    // SPI RECEIVER INSTANCE
    spi_rx spi_receiver (
	    .sclk(SCLK),
	    .cs(CS),
	    .mosi(MOSI),
	    .command_byte(COMMAND_BYTE),
	    .byte_ready(BYTE_READY)
    );

endmodule

