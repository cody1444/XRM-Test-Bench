module spi_passthrough (
	input pi_clk,
	input SEL,
	input MOSI,
	output wire pmod_sel,
	output wire pmod_MOSI,
	output wire pmod_piclk
);

	assign pmod_sel = SEL;
	assign pmod_MOSI = MOSI;
	assign pmod_piclk = pi_clk;

endmodule
