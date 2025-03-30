module spi_rx #(
	parameter WIDTH = 8;
)(
	input wire sclk,
	input wire cs,
	input wire mosi,
	output wire [WIDTH-1:0] command_byte,
	output reg byte_ready
);

endmodule
