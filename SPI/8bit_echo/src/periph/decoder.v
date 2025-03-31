module decoder (
	input wire byte_ready,
	input wire [7:0] command_byte,
	output reg [63:0] toggle_mask
);

	always @(posedge byte_ready) begin
		toggle_mask <= 64'b1 << command_byte[5:0];
	end

endmodule
