module spi_slave (
    input  wire sclk,  // SPI clock
    input  wire cs,    // Chip select (active low)
    input  wire mosi,  // Master Out, Slave In
    output wire miso   // Master In, Slave Out
);

// When CS is active, pass MOSI directly to MISO; otherwise drive low.
assign miso = (!cs) ? mosi : 1'b0;

endmodule

