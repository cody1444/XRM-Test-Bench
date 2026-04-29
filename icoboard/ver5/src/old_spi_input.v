function integer clog2;
	input integer value;
	integer i;
	begin
		clog2 =0;
		for (i = value - 1; i > 0; i = i >> 1)
			clog2 = clog2 + 1;
	end
endfunction

module spi_input #(
    parameter TOTAL_BYTES_IN_TX = 2
)(
	input pi_clk,
	input clk_100Mhz,
	input SEL,
	input MOSI,
	input RESET,
	output reg [63:0] output_pin,
	output MISO,
	//output pmod_sync,
	//output pmod_MISO,
	//output pmod_sel,
	//output pmod_MOSI,
	//output pmod_piclk,
	//output pmod_clk,
	//output pmod_out
);
	// --- generate fast clock using PLL
	wire pll_locked;
	wire clk_100Mhz_global;

	SB_PLL40_2_PAD #(
		.FEEDBACK_PATH("SIMPLE"),
		.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
		.DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
		.FDA_FEEDBACK(4'b1111),
		.FDA_RELATIVE(4'b1111),
		.DIVR(4'b0000),
		.DIVF(7'b0001001),
		.DIVQ(3'b010),
		.FILTER_RANGE(3'b101),
		.ENABLE_ICEGATE_PORTA(1'b0),
		.ENABLE_ICEGATE_PORTB(1'b0)
	) pll (
		.PACKAGEPIN    (clk_100Mhz),
		.PLLOUTGLOBALA (clk_100Mhz_global),
		.PLLOUTGLOBALB (ico_clk),
		.LOCK          (pll_locked),
		.BYPASS        (1'b0      ),
		.RESETB        (1'b1      )
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
	localparam TOTAL_BITS_IN_TX = TOTAL_BYTES_IN_TX * 8;
	localparam DATA_BITS_IN_TX = TOTAL_BITS_IN_TX - 8; 
	localparam BIT_COUNT_WIDTH = clog2(2*TOTAL_BITS_IN_TX);
			
	reg [BIT_COUNT_WIDTH - 1:0] bit_count = 0;
	reg [TOTAL_BITS_IN_TX - 1:0] SHIFTr = 0;
	reg [DATA_BITS_IN_TX - 1:0] MISOr = 0;
	reg [DATA_BITS_IN_TX - 1:0] mem [0:63];

	wire bit_received = SEL_active && sync_clk_rising; 
	wire pi_finished_tx = bit_received && (bit_count == TOTAL_BITS_IN_TX - 1);
	wire [TOTAL_BITS_IN_TX - 1:0] full_word = {SHIFTr[TOTAL_BITS_IN_TX - 2:0], MOSI_sample};
	wire [5:0] addr   = full_word[TOTAL_BITS_IN_TX-1 : TOTAL_BITS_IN_TX-6];
   	wire [1:0] opcode = full_word[TOTAL_BITS_IN_TX-7 : TOTAL_BITS_IN_TX-8];
   	wire [DATA_BITS_IN_TX-1:0] data = full_word[TOTAL_BITS_IN_TX-9 : 0];

	always @(posedge clk_100Mhz_global) begin 
		if (cs_start || cs_end || RESET) begin
			bit_count <= 0;
			SHIFTr <= 0;
			MISOr <= 0;
		end else if (bit_received) begin 
			bit_count <= bit_count + 1'b1; 
			SHIFTr <= {SHIFTr[TOTAL_BITS_IN_TX - 2:0], MOSI_sample};
			
			if (pi_finished_tx) begin
				if (opcode == 2'b00) mem[addr] <= data;
				else if (opcode == 2'b01) MISOr <= mem[addr];
			end
		end

		if (SEL_active && sync_clk_falling && bit_count > TOTAL_BITS_IN_TX) MISOr <= {MISOr[DATA_BITS_IN_TX - 2:0], 1'b0};
	end

	// ---- output pin control ----
	localparam J_WIDTH = clog2(DATA_BITS_IN_TX);

	reg sync = 0;
	reg [J_WIDTH -1:0] j = 0;

	always @(posedge ico_clk) begin
		sync <= 0;
		if (j < DATA_BITS_IN_TX - 1)
			j <= j + 1'b1;
		else begin
			j <= 0;	
			sync <= 1;
		end
	end

	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : pin_out
			always @(posedge ico_clk) begin
				output_pin[i] <= mem[i][j];
			end
		end
	endgenerate

	//assign pmod_sync = sync;
	//assign MISO = MISOr[DATA_BITS_IN_TX - 1]; 
	//assign pmod_MISO = MISO; 
	//assign pmod_sel = SEL;
	//assign pmod_MOSI = MOSI;
	//assign pmod_piclk = pi_clk;
	//assign pmod_clk = ico_clk;
	//assign pmod_out = output_pin[0];

endmodule
