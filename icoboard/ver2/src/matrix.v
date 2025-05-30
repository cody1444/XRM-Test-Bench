module matrix(
	input RPI_IO1,
	input RPI_IO2,
	input RPI_IO3,
	input RPI_IO6,
	input RPI_IO7,
	input RPI_IO8,
	input RPI_IO9,
	input RPI_IO1,
	output [0:63] output_pin
);
	assign output_pin = 64'hFFFFFFFFFFFFFFFF;
endmodule
