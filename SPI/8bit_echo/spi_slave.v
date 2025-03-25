module spi_slave (
    input  wire sclk,  // SPI clock
    input  wire cs,    // Chip select (active low)
    input  wire mosi,  // Master Out, Slave In
    output reg miso    // Master In, Slave Out
);
	reg [7:0] shift_reg = 8'hAA;
	reg [7:0] received_data;

	always @(negedge sclk) begin
		if (!cs) begin
			shift_reg <= {shift_reg[6:0], mosi};
		end
	end

	always @(posedge sclk) begin
		if (!cs) begin
			miso <= received_data[7];
			received_data <= {received_data[6:0], 1'b0};
		end
	end

	always @(posedge cs) begin
		received_data <= shift_reg;
		shift_reg <= 8'h00;
	end
endmodule

