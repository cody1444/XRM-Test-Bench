module matrix(
	input clk_100mhz,
	input [0:7] RPI_IO,
	input write_strobe,
	output [0:63] output_pin,
	output reg LED1,
	output reg LED2
);

	reg [7:0] mem [0:1];
	reg [1:0] counter = 2'b00;
	reg toggle = 0;

	always @(posedge clk_100mhz) begin
		if (write_strobe & counter < 2) begin
			LED1 <= 0;
			LED2 <= 0;
			mem[counter] <= RPI_IO;
			counter <= counter + 1;
		end
		if (counter == 2'b10) begin
			LED1 <= 1;
			LED2 <= 1;
			counter <= 2'b00;
		end
		toggle <= ~toggle;
		output_pin[7:0] <= mem[toggle];
		output_pin[15:8] <= mem[toggle];
		output_pin[23:16] <= mem[toggle];
		output_pin[31:24] <= mem[toggle];
		output_pin[39:32] <= mem[toggle];
		output_pin[47:40] <= mem[toggle];
		output_pin[55:48] <= mem[toggle];
		output_pin[63:56] <= mem[toggle];
	end
endmodule
