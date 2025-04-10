`timescale 1ns / 1ps

module spi_rx_tb;

    // Parameters
    parameter WIDTH = 8;

    // DUT Inputs
    reg sclk = 0;
    reg cs = 1;
    reg mosi = 0;

    // DUT Outputs
    wire [WIDTH-1:0] command_byte;
    wire byte_ready;

    // Instantiate the DUT (Device Under Test)
    spi_rx #(.WIDTH(WIDTH)) uut (
        .sclk(sclk),
        .cs(cs),
        .mosi(mosi),
        .command_byte(command_byte),
        .byte_ready(byte_ready)
    );

    // Task to send 1 byte over SPI (MSB first)
    task send_spi_byte(input [7:0] data);
        integer i;
        begin
	    #5;
	    
            for (i = 7; i >= 0; i = i - 1) begin
		sclk = 0;
		#10
		mosi = data[i];

		sclk = 1;
		#10;
            end

	    sclk = 0;
	    #20;
        end
    endtask

    // Test sequence
    initial begin
        $display("Starting SPI RX Test");
        $dumpfile("spi_rx_tb.vcd");    // for waveform viewer
        $dumpvars(0, spi_rx_tb);
	
	cs = 1;
	#40;
	cs = 0;

        // Send first byte: 0xA5
        send_spi_byte(8'hA5);
	#40;

	// Send first byte: 0xB3
        send_spi_byte(8'hB3);
	#40;

	cs = 1;
	#40;

        $display("Test complete");
        $finish;
    end

endmodule


