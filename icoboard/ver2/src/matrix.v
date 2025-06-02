module matrix(
	input clk_100mhz,
	input [0:7] RPI_IO,
	input write_strobe,
	output [0:63] output_pin,
	output pmod1_1
);
	always @(posedge clk_100mhz) begin
		if (write_strobe) begin
			output_pin[7:0] <= RPI_IO;
			output_pin[15:8] <= RPI_IO;
			output_pin[23:16] <= RPI_IO;
			output_pin[31:24] <= RPI_IO;
			output_pin[39:32] <= RPI_IO;
			output_pin[47:40] <= RPI_IO;
			output_pin[55:48] <= RPI_IO;
			output_pin[63:56] <= RPI_IO;
		end
	end
	assign pmod1_1 = write_strobe;
endmodule
