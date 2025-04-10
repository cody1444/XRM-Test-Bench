module spi_rx #(
parameter WIDTH = 8
)(
	input wire sclk,
	input wire cs,
	input wire mosi,
	output reg [WIDTH-1:0] command_byte,
	output reg byte_ready
);

	reg [2:0] bit_count;

	always @(negedge sclk) begin
		command_byte <= {command_byte[WIDTH-2:0], mosi};
		bit_count <= bit_count + 1;

		if (bit_count == (WIDTH - 1)) begin
			byte_ready <= 1;
		end else begin
			byte_ready <= 0;
		end
	end

	always @(negedge cs) begin
		if (!cs) begin
			bit_count <= 0;
		end
	end

endmodule

