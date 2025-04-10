module pin_controller (
	input wire clk,
	input wire [63:0] toggle_mask,
	input wire toggle_enable,
	output reg [63:0] output_pins
);

	initial output_pins = 64'b0;
	reg prev_toggle_enable;

	always @(posedge clk) begin
		if (~prev_toggle_enable && toggle_enable) begin
			output_pins <= output_pins ^ toggle_mask;
			$display("pin_controller: Toggling output_pins <= %b", output_pins ^ toggle_mask);
		end
		prev_toggle_enable <= toggle_enable;
	end

endmodule
