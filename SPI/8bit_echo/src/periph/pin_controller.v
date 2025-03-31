module pin_controller (
	input wire clk,
	input wire [63:0] toggle_mask,
	input wire toggle_enable,
	output reg [63:0] output_pins
);

	initial output_pins = 64'b0;

	always @(posedge clk) begin
		if (toggle_enable) begin
			output_pins <= output_pins ^ toggle_mask;
		end
	end

endmodule
