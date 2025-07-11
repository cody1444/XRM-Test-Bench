module spi_input (
	input pi_clk,
	input ico_clk,
	input SEL,
	input MOSI,
	output MISO,
	output wire pmod_sel,
	output wire pmod_MOSI,
	output wire pmod_MISO,
	output wire pmod_piclk,
	output wire rpi_io7,
	output wire rpi_io8,
	output wire rpi_io9,
	output wire rpi_io10
);

	reg [2:0] sync_clk = 3'b000; always @(posedge ico_clk) sync_clk <= {sync_clk[1:0], pi_clk};
	wire sync_clk_rising = (sync_clk[2:1] == 2'b01); wire sync_clk_falling = (sync_clk[2:1] == 2'b10);

	reg [2:0] SELr = 3'b111; always @(posedge ico_clk) SELr <= {SELr[1:0], SEL};
	wire SEL_active = ~SELr[1];

	reg [1:0] MOSIr = 2'b0; always @(posedge ico_clk) MOSIr = {MOSIr[0], MOSI};
	wire MOSI_data = MOSIr[1];

	reg [3:0] bit_count = 4'b0; reg [7:0] byte_data_received = 8'b0;	
	always @(posedge ico_clk) begin
		if (~SEL_active) bit_count <= 4'b0;
		else begin
			if (sync_clk_rising) begin
				bit_count <= bit_count + 1;
				byte_data_received <= {byte_data_received[6:0], MOSI_data};
			end
		end
	end

	reg [7:0] byte_data_send = 8'b0; reg [7:0] message = 8'b0; reg [3:0] mem [0:3];
	wire ready_to_send = (bit_count == 4'b1000);
	always @(posedge ico_clk) begin
		if (~SEL_active) byte_data_send <= 8'b0;
		else begin
			if (ready_to_send) begin
				byte_data_send <= byte_data_received;
				message <= byte_data_received;
				if (byte_data_received[5:4] == 2'b00) mem[byte_data_received[7:6]] <= byte_data_received[3:0];
				if (byte_data_received[5:4] == 2'b01) byte_data_send <= mem[byte_data_received[7:6]];
			end
			if (sync_clk_falling && bit_count >= 4'b1000) byte_data_send <= {byte_data_send[6:0], 1'b0};
		end
	end

	assign MISO = byte_data_send[7];
	assign pmod_sel = SEL;
	assign pmod_MOSI = MOSI;
	assign pmod_MISO = MISO;
	assign pmod_piclk = pi_clk;
	assign rpi_io7 = mem[0][0];
	assign rpi_io8 = mem[0][1];
	assign rpi_io9 = mem[0][2];
	assign rpi_io10 = mem[0][3];

endmodule
