module spi_input (
	input pi_clk,
	input ico_clk,
	input SEL,
	input MOSI,
	//output reg [63:0] output_pin,
	//output wire pmod_sync,
	output MISO,
	output wire pmod_sel,
	output wire pmod_MOSI,
	output wire pmod_piclk
);

	// ---- synchronize clocks----
	reg [2:0] sync_clk = 3'b000; 
	always @(posedge ico_clk) sync_clk <= {sync_clk[1:0], pi_clk};
	wire sync_clk_rising = (sync_clk[2:1] == 2'b01);
	wire sync_clk_falling = (sync_clk[2:1] == 2'b10);

	// ---- sample chip select (CS) ----
	reg [1:0] SELr = 2'b11;
	always @(posedge ico_clk) SELr <= {SELr[0], SEL};
	wire SEL_active = ~SELr[1];
	wire cs_start = (SELr[1:0]==2'b10);
	wire cs_end = (SELr[1:0]==2'b01);

	// ---- sample MOSI ----
	reg [1:0] MOSIr = 2'b0;
	always @(posedge ico_clk) MOSIr <= {MOSIr[0], MOSI};
	wire MOSI_data = MOSIr[1];

	// ---- MOSI line processing ---- 
	reg  [3:0] bit_count = 4'b0;
	reg [15:0] MESSAGEr = 16'b0;
	reg  [7:0] mem [0:63];

	wire bit_received = SEL_active && sync_clk_rising; 
	wire [15:0] message_now = {MESSAGEr[14:0], MOSI_data};

	always @(posedge ico_clk) begin 
		if (cs_start) begin
			bit_count <= 4'd0;
			MESSAGEr <= 16'd0;
		end else if (SEL_active) begin 
			if (bit_received) begin 
				MESSAGEr <= message_now;
				bit_count <= bit_count + 4'd1; 
			end 
		end
	end
	
	reg [7:0] MISOr = 8'd0;
	wire received_full_message_from_MOSI = bit_received && (bit_count == 4'd15);

	always @(posedge ico_clk) begin
		if (received_full_message_from_MOSI) begin
			if (message_now[9:8] == 2'b00) mem[message_now[15:10]] <= message_now[7:0];
			if (message_now[9:8] == 2'b01) MISOr <= mem[message_now[15:10]];
		end
		if (SEL_active && sync_clk_falling && bit_count >= 4'b1000) MISOr <= {MISOr[6:0], 1'b0};
	end

	// ---- output pin control ----
	//reg sync = 0;
	//reg [5:0] rd_addr = 6'd0;
	//always @(posedge ico_clk) begin
	//	sync <= 0;
	//	if (rd_addr < 6'd63) rd_addr <= rd_addr + 6'd1;
	//	else begin
	//		rd_addr <= 0;
	//		sync <= 1;
	//	end
	//	output_pin[rd_addr]  <= 1'b0;
	//end

	//assign pmod_sync = sync;
	assign MISO = MISOr[7]; 
	assign pmod_sel = SEL;
	assign pmod_MOSI = MOSI;
	assign pmod_piclk = pi_clk;

endmodule
