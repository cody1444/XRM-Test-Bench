`timescale 1ns/1ps

module spi_slave_tb;
    reg sclk = 0;
    reg cs = 1;
    reg mosi = 0;
    reg [2:0] counter= 0;
    reg [7:0] mosi_data;
    wire miso;
    integer i;

    // Instantiate SPI Slave
    spi_slave uut (
        .sclk(sclk),
        .cs(cs),
        .mosi(mosi),
        .miso(miso)
    );

    always @(negedge cs) begin
	    for (i = 0; i < 16; i = i + 1) begin
		    #10 sclk = ~sclk;
	    end
//	    while (!cs) begin
//		    sclk = ~sclk;
//	    end
    end

    always @(posedge sclk) begin
	    if (counter < 8) begin
		    mosi <= mosi_data[7 - counter];
		    counter <= counter + 1;
	    end else begin
		    counter <= 0;
	    end
    end


    initial begin
	    $dumpfile("spi_slave_tb.vcd");  // Create waveform file for GTKWave
	    $dumpvars(0, spi_slave_tb);    // Dump all signals

	    // Send first byte (0x00)
	    #20
	    mosi_data = 8'h00;
	    cs = 0;
	    #170;
	    cs = 1;

	    #80
	    mosi_data = 8'hA5;
	    cs = 0;
	    #170;
	    cs = 1;

	    #80
	    mosi_data = 8'h3C;
	    cs = 0;
	    #170;
	    cs = 1;

	    #80
	    mosi_data = 8'h7F;
	    cs = 0;
	    #170;
	    cs = 1;

	    #40 $finish;
    end
endmodule
