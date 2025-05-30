module matrix(
	input [0:7] RPI_IO,
	output [0:63] output_pin
);
	assign output_pin[7:0] = RPI_IO;
	assign output_pin[15:8] = RPI_IO;
	assign output_pin[23:16] = RPI_IO;
	assign output_pin[31:24] = RPI_IO;
	assign output_pin[39:32] = RPI_IO;
	assign output_pin[47:40] = RPI_IO;
	assign output_pin[55:48] = RPI_IO;
	assign output_pin[63:56] = RPI_IO;
endmodule
