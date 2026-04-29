module matrix #(
	parameter ADDR_DEPTH = 4,
	parameter MAX_ADDR = (2**ADDR_DEPTH) - 1
)(
	input clk_100mhz,
	input [7:0] RPI_IO,
	input write_strobe,
	output pmod1_1,
	output pmod1_7,
	output reg [63:0] output_pin
);
	reg sync = 0;
	reg r_write_strobe = 0;
	reg [7:0] mem [MAX_ADDR:0];
	reg [ADDR_DEPTH-1:0] wr_addr = 0;
	reg [ADDR_DEPTH-1:0] rd_addr = 0;

	always @(posedge clk_100mhz) begin
		sync <= 0;
		r_write_strobe <= write_strobe;
		if (write_strobe == 1'b1 && r_write_strobe == 1'b0) begin
			mem[wr_addr] <= RPI_IO;
			wr_addr <= wr_addr + 1'b1;
		end
		if (rd_addr<MAX_ADDR) begin
			rd_addr <= rd_addr + 1'b1;
		end else begin
			rd_addr <= 0;
			sync <= 1;
		end
		output_pin[7:0] = mem[rd_addr];
		output_pin[15:8] <= mem[rd_addr];
		output_pin[23:16] <= mem[rd_addr];
		output_pin[31:24] <= mem[rd_addr];
		output_pin[39:32] <= mem[rd_addr];
		output_pin[47:40] <= mem[rd_addr];
		output_pin[55:48] <= mem[rd_addr];
		output_pin[63:56] <= mem[rd_addr];
	end
	assign pmod1_1 = sync;
	assign pmod1_7 = mem[rd_addr][0];
	//assign output_pin[7:0] = mem[rd_addr];
	//assign output_pin[15:8] = mem[rd_addr];
	//assign output_pin[23:16] = mem[rd_addr];
	//assign output_pin[31:24] = mem[rd_addr];
	//assign output_pin[39:32] = mem[rd_addr];
	//assign output_pin[47:40] = mem[rd_addr];
	//assign output_pin[55:48] = mem[rd_addr];
	//assign output_pin[63:56] = mem[rd_addr];
endmodule
