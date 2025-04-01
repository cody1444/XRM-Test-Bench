module spi_ctlr (
	input CLK,
	input MOSI,
	input CS,
	output PIN_P1_B11,
	output PIN_P1_B9,
	output PIN_P1_D8
);

assign PIN_P1_B11 = CLK;
assign PIN_P1_B9 = MOSI;
assign PIN_P1_D8 = CS;

endmodule
