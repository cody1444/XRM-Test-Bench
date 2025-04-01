module spi_rx #(
parameter WIDTH = 8
)(
	input wire sclk,
	input wire cs,
	input wire mosi,
	output reg [WIDTH-1:0] command_byte,
	output reg byte_ready
);

	reg [WIDTH-1:0] shift_reg;
	reg [2:0] bit_count;

	always @(negedge sclk) begin
		shift_reg <= {shift_reg[WIDTH-2:0], mosi};
		bit_count <= bit_count + 1;

		if (bit_count == (WIDTH - 1)) begin
			command_byte <= shift_reg;
			byte_ready <= 1;
			$display("spi_rx: Received byte: %h", shift_reg);
		end else begin
			byte_ready <= 0;
		end
	end

	always @(posedge cs) begin
		shift_reg <= 0;
		bit_count <= 0;
		byte_ready <= 0;
	end

endmodule
