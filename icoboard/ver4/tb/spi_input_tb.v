`timescale 1ns/1ps

// Simple SPI master style testbench that exercises the spi_input block.
module spi_input_tb;
	reg pi_clk = 1'b0;
	reg ico_clk = 1'b0;
	reg SEL = 1'b1;
	reg MOSI = 1'b0;

	wire MISO;
	wire [63:0] output_pin;
	wire pmod_sync;
	wire pmod_sel;
	wire pmod_MOSI;
	wire pmod_MISO;
	wire pmod_piclk;
	wire rpi_io7;
	wire rpi_io8;
	wire rpi_io9;
	wire rpi_io10;

	integer error_count = 0;
	integer sync_events = 0;

	spi_input dut (
		.pi_clk(pi_clk),
		.ico_clk(ico_clk),
		.SEL(SEL),
		.MOSI(MOSI),
		.MISO(MISO),
		.output_pin(output_pin),
		.pmod_sync(pmod_sync),
		.pmod_sel(pmod_sel),
		.pmod_MOSI(pmod_MOSI),
		.pmod_MISO(pmod_MISO),
		.pmod_piclk(pmod_piclk),
		.rpi_io7(rpi_io7),
		.rpi_io8(rpi_io8),
		.rpi_io9(rpi_io9),
		.rpi_io10(rpi_io10)
	);

	// 100 MHz ICO clock.
	always #5 ico_clk = ~ico_clk;

	initial begin
		$dumpfile("spi_input_tb.vcd");
		$dumpvars(0, spi_input_tb);
		$display("Starting spi_input_tb");
	end

	// Drive a single SPI bit with plenty of setup/hold so the DUT synchronizers see each edge.
	task automatic shift_bit;
		input mosi_drive;
		input capture;
		output miso_sample;
		begin
			miso_sample = 1'b0;
			MOSI <= mosi_drive;
			repeat (2) @(posedge ico_clk);
			pi_clk <= 1'b1;
			repeat (2) @(posedge ico_clk);
			pi_clk <= 1'b0;
			@(posedge ico_clk);
			if (capture) miso_sample = MISO;
			@(posedge ico_clk);
		end
	endtask

	// Send a 12-bit command (MSB first) followed by optional dummy clocks to capture MISO bits.
	task automatic spi_transfer;
		input [11:0] payload;
		input integer read_bits;
		output [11:0] miso_word;
		integer idx;
		reg dummy_bit;
		reg capture_bit;
		begin
			miso_word = 12'b0;
			SEL <= 1'b0;
			repeat (4) @(posedge ico_clk);
			for (idx = 11; idx >= 0; idx = idx - 1) begin
				shift_bit(payload[idx], 1'b0, dummy_bit);
			end
			for (idx = read_bits - 1; idx >= 0; idx = idx - 1) begin
				shift_bit(1'b0, 1'b1, capture_bit);
				miso_word[idx] = capture_bit;
			end
			SEL <= 1'b1;
			repeat (6) @(posedge ico_clk);
		end
	endtask

	task automatic spi_write;
		input [5:0] addr;
		input [3:0] data;
		reg [11:0] cmd;
		reg [11:0] unused;
		begin
			cmd = {addr, 2'b00, data};
			spi_transfer(cmd, 0, unused);
		end
	endtask

	task automatic spi_read;
		input [5:0] addr;
		output [11:0] data;
		reg [11:0] cmd;
		begin
			cmd = {addr, 2'b01, 4'b0000};
			spi_transfer(cmd, 12, data);
		end
	endtask

	task automatic check_rpi_ios;
		input [3:0] expected;
		reg [3:0] observed;
		begin
			@(posedge ico_clk);
			observed = {rpi_io10, rpi_io9, rpi_io8, rpi_io7};
			if (observed !== expected) begin
				error_count = error_count + 1;
				$display("[ERROR] rpi_io10:7 expected %h got %h", expected, observed);
			end else begin
				$display("[INFO] rpi_io10:7 matched %h", expected);
			end
		end
	endtask

	task automatic sample_output_pin;
		input integer which;
		input [3:0] expected;
		reg [3:0] captured;
		integer idx;
		begin
			captured = 4'b0;
			for (idx = 0; idx < 4; idx = idx + 1) begin
				while (dut.rd_addr != idx) @(posedge ico_clk);
				@(negedge ico_clk);
				captured[idx] = output_pin[which];
			end
			if (captured !== expected) begin
				error_count = error_count + 1;
				$display("[ERROR] output_pin[%0d] expected nibble %h got %h", which, expected, captured);
			end else begin
				$display("[INFO] output_pin[%0d] matched nibble %h", which, expected);
			end
		end
	endtask

	// Simple connectivity checks for the direct output assigns.
	always @(posedge ico_clk) begin
		if (pmod_sel !== SEL) begin
			error_count = error_count + 1;
			$display("[ERROR] pmod_sel mismatch");
		end
		if (pmod_MOSI !== MOSI) begin
			error_count = error_count + 1;
			$display("[ERROR] pmod_MOSI mismatch");
		end
		if (pmod_MISO !== MISO) begin
			error_count = error_count + 1;
			$display("[ERROR] pmod_MISO mismatch");
		end
		if (pmod_piclk !== pi_clk) begin
			error_count = error_count + 1;
			$display("[ERROR] pmod_piclk mismatch");
		end
	end

	always @(posedge pmod_sync) begin
		sync_events = sync_events + 1;
	end

	initial begin
		reg [11:0] read_data;

		pi_clk = 1'b0;
		SEL = 1'b1;
		MOSI = 1'b0;

		repeat (20) @(posedge ico_clk);

		spi_write(6'd0, 4'hA);
		check_rpi_ios(4'hA);
		sample_output_pin(0, 4'hA);

		spi_write(6'd1, 4'h5);
		sample_output_pin(1, 4'h5);

		spi_write(6'd3, 4'hF);
		sample_output_pin(3, 4'hF);

		spi_read(6'd0, read_data);
		if (read_data !== 12'h00A) begin
			error_count = error_count + 1;
			$display("[ERROR] Readback mismatch addr0 expected 00A got %03h", read_data);
		end else begin
			$display("[INFO] Readback addr0 OK (%03h)", read_data);
		end

		spi_read(6'd1, read_data);
		if (read_data !== 12'h005) begin
			error_count = error_count + 1;
			$display("[ERROR] Readback mismatch addr1 expected 005 got %03h", read_data);
		end else begin
			$display("[INFO] Readback addr1 OK (%03h)", read_data);
		end

		if (sync_events == 0) begin
			error_count = error_count + 1;
			$display("[ERROR] pmod_sync never toggled");
		end else begin
			$display("[INFO] Observed %0d sync events", sync_events);
		end

		if (error_count == 0) begin
			$display("TEST PASSED");
		end else begin
			$display("TEST FAILED with %0d errors", error_count);
		end

		$finish;
	end
endmodule
