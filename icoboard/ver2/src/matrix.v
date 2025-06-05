module matrix(
	input clk_100mhz,
	input [0:7] RPI_IO,
	input write_strobe,
	output [0:63] output_pin,
	output reg [1:0] LED
);

	reg r_write_strobe = 1'b0;
	reg [7:0] mem [0:1];
	reg [1:0] counter = 2'b00;
	reg toggle = 0;

	always @(posedge clk_100mhz) begin
		r_write_strobe <= write_strobe;
		if (write_strobe == 1'b0 && r_write_strobe == 1'b1 && counter < 2'b10) begin
			mem[counter] <= RPI_IO;
			counter <= counter + 2'b01;
		end
		else if (counter == 2'b10) begin 
			counter <= 2'b00;
		end
		else begin 
		output_pin[7:0] <= mem[toggle];
		output_pin[15:8] <= mem[toggle];
		output_pin[23:16] <= mem[toggle];
		output_pin[31:24] <= mem[toggle];
		output_pin[39:32] <= mem[toggle];
		output_pin[47:40] <= mem[toggle];
		output_pin[55:48] <= mem[toggle];
		output_pin[63:56] <= mem[toggle];
		toggle <= ~toggle;
		end
	end
endmodule
