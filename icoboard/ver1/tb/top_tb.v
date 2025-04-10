`timescale 1ns / 1ps

module top_tb;

    // Inputs
    reg CLK = 0;         // System clock (internal logic)
    reg SCLK = 0;        // SPI clock
    reg CS = 1;          // Chip select (active low)
    reg MOSI = 0;        // SPI data

    // Output
    wire [63:0] pins;  // Output from pin controller

    // Instantiate the top module
    top uut (
        .CLK(CLK),
        .SCLK(SCLK),
        .CS(CS),
        .MOSI(MOSI),
        .pins(pins)
    );

    // Generate system clock (100 MHz)
    initial CLK = 0;
    always #5 CLK = ~CLK;

    // Task to send a single SPI byte (MSB first)
    task send_spi_byte(input [7:0] data);
        integer i;
        begin
            #5;

            for (i = 7; i >= 0; i = i - 1) begin
		SCLK = 0;
                #10;
		MOSI = data[i];

                SCLK = 1;
                #10;
            end

	    SCLK = 0;
	    #40;
        end
    endtask

    initial begin
        $display("Starting top module testbench...");
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        // Initialize inputs
        CS = 1;
        #40;
	CS = 0;

        send_spi_byte(8'h00);   // Toggle pin 0 ON
	#40;

        send_spi_byte(8'h00);   // Toggle pin 0 OFF
	#40;

        send_spi_byte(8'h03);   // Toggle pin 3 ON
	#40;

        send_spi_byte(8'h3F);   // Toggle pin 63 ON
	#40;
	
        send_spi_byte(8'h3F);   // Toggle pin 63 OFF
        #1000;
	CS = 1;
	#40;
        $display("Final pins = %b", pins);
        $finish;
    end

endmodule


