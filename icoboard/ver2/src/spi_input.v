module spi_input (
	input pi_clk,
	input ico_clk,
	input SEL,
	input MOSI,
	//output reg [63:0] output_pin,
	//output wire pmod_sync,
	output LED,
	output wire pmod_MISO,
	output wire pmod_sel,
	output wire pmod_MOSI,
	output wire pmod_piclk
);

	// ---- synchronize clocks----
	reg [2:0] sync_clk = 3'd0; 
	always @(posedge ico_clk) sync_clk <= {sync_clk[1:0], pi_clk};

	wire sync_clk_rising = (sync_clk[2:1] == 2'b01);
	wire sync_clk_falling = (sync_clk[2:1] == 2'b10);

	// ---- sample ACTIVE LOW chip select (CS) ----
	reg [1:0] SELr = 2'b11;
	always @(posedge ico_clk) SELr <= {SELr[0], SEL};

	wire SEL_active = ~SELr[1];
	wire cs_start = (SELr[1:0]==2'b10);
	wire cs_end = (SELr[1:0]==2'b01);

	// ---- sample MOSI ----
	reg [1:0] MOSIr = 2'd0;
	always @(posedge ico_clk) MOSIr <= {MOSIr[0], MOSI};

	wire MOSI_sample = MOSIr[1];

	// ---- MOSI line processing ---- 
	reg [4:0]  bit_count = 5'd0;
	reg [15:0] SHIFTr = 16'd0;
	reg [7:0]  MISOr = 8'd0;
	reg [7:0]  mem [0:63];
	reg led = 1'd0;

	wire bit_received = SEL_active && sync_clk_rising; 
	wire word_done = bit_received && (bit_count == 5'd15);
	wire [15:0] full_word = {SHIFTr[14:0], MOSI_sample};

	always @(posedge ico_clk) begin 
		if (cs_start) begin
			led <= 1'd0;
			bit_count <= 5'd0;
			SHIFTr <= 16'd0;
			MISOr <= 8'd0;
		end else if (bit_received) begin 
			bit_count <= bit_count + 5'd1; 
			SHIFTr <= {SHIFTr[14:0], MOSI_sample};
			
			if (word_done && full_word[9:8] == 2'b00) begin
				mem[full_word[15:10]] <= full_word[7:0];
			end else if (word_done && full_word[9:8] == 2'b01) begin
				//led <= 1'd1;
				MISOr <= mem[full_word[15:10]];
			end
		end

		if (SEL_active && sync_clk_falling && bit_count > 5'd8) MISOr <= {MISOr[6:0], 1'b0};
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
	assign pmod_MISO = MISOr[7]; 
	assign pmod_sel = SEL;
	assign pmod_MOSI = MOSI;
	assign pmod_piclk = pi_clk;
	assign LED = led;
	//assign LED2 = led2;

endmodule
