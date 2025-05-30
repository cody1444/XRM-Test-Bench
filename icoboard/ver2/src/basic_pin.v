module basic_pin (
	input RPI_IO1,
	input RPI_IO2,
	input RPI_IO3,
	input RPI_IO6,
	input RPI_IO7,
	input RPI_IO8,
	input RPI_IO9,
	input RPI_IO10,
	output matrix_00,
	output matrix_01,
	output matrix_02,
	output matrix_03,
	output matrix_04,
	output matrix_05,
	output matrix_06,
	output matrix_07,
	output matrix_08,
	output matrix_09
);

assign matrix_00 = RPI_IO1;
assign matrix_01 = RPI_IO2;
assign matrix_02 = RPI_IO3;
assign matrix_03 = RPI_IO4;
assign matrix_04 = RPI_IO5;
assign matrix_05 = RPI_IO6;
assign matrix_06 = RPI_IO7;
assign matrix_07 = RPI_IO8;
assign matrix_08 = RPI_IO9;
assign matrix_09 = RPI_IO10;

endmodule
