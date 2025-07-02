module spi_input (
	input pi_clk,
	input ico_clk,
	input SEL,
	input MOSI,
	output MISO,
	output reg LED,
	output wire pmod_sel,
	output wire pmod_MOSI,
	output wire pmod_MISO,
	output wire pmod_piclk
);
	initial begin
		LED = 0;
	end
	//RECEIVING
	// sync raspi clock with icoboard clock using 3-bit shift register
	reg [2:0] sync_clk = 3'b000; always @(posedge ico_clk) sync_clk <= {sync_clk[1:0], pi_clk};
	wire sync_clk_rising = (sync_clk[2:1] == 2'b01); wire sync_clk_falling = (sync_clk[2:1] == 2'b10);

	// sample select
	reg [2:0] SELr = 3'b111; always @(posedge ico_clk) SELr <= {SELr[1:0], SEL};
	wire SEL_active = ~SELr[1];
	wire message_start = (SELr[2:1] == 2'b10); wire message_end = (SELr[2:1] == 2'b01);

	// sample MOSI
	reg [1:0] MOSIr = 2'b0; always @(posedge ico_clk) MOSIr = {MOSIr[0], MOSI};
	wire MOSI_data = MOSIr[1];

	// receive data
	reg [2:0] bit_count = 3'b000; reg byte_received = 1'b0; reg [7:0] byte_data_received = 8'b0;
	always @(posedge ico_clk) begin
		if (~SEL_active)
			bit_count <= 3'b000;
		else begin
			if (sync_clk_rising) begin
				bit_count <= bit_count + 1;
				byte_data_received <= {byte_data_received[6:0], MOSI_data};
			end 
		end
	end
	always @(posedge ico_clk) begin
		byte_received <= sync_clk_rising && SEL_active && (bit_count == 3'b111);
	end

	// toggle led
	reg [24:0] led_counter = 0;
	reg [7:0] byte_data_send = 8'h0;
	always @(posedge ico_clk) begin
		if (byte_received) begin
			LED <= 1;
			led_counter = 25_000_000 -1;
		end else if (led_counter > 1) begin
			led_counter = led_counter - 1;
			if (led_counter == 1) LED <= 0;
		end
	end
	
	// send data
	always @(posedge ico_clk) begin
		if (message_start) begin
			byte_data_send <= byte_data_received;
		end
		if (sync_clk_falling) byte_data_send <= {byte_data_send[6:0], 1'b0};
	end

	// TRANSMITTING
	assign MISO = byte_data_send[7];
	assign pmod_sel = SEL;
	assign pmod_MOSI = MOSI;
	assign pmod_MISO = MISO;
	assign pmod_piclk = pi_clk;

endmodule
