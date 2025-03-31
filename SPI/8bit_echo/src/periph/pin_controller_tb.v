`timescale 1ns / 1ps

module pin_controller_tb;

    // DUT inputs
    reg clk;
    reg toggle_enable;
    reg [63:0] toggle_mask;

    // DUT output
    wire [63:0] output_pins;

    // Instantiate DUT
    pin_controller uut (
        .clk(clk),
        .toggle_mask(toggle_mask),
        .toggle_enable(toggle_enable),
        .output_pins(output_pins)
    );

    // Clock generation: 50 MHz
    always #10 clk = ~clk;

    // Task to toggle a specific pin
    task toggle_pin(input [5:0] pin_index);
    	begin
		toggle_mask = 64'b1 << pin_index;
		toggle_enable = 1;

		@(posedge clk);
		#1;
		toggle_enable = 0;

		$display("Toggled pin %0d | out_pins = %b", pin_index, output_pins);
    	end
    endtask

    initial begin
        $display("Starting pin_controller testbench...");
        $dumpfile("pin_controller_tb.vcd");
        $dumpvars(0, pin_controller_tb);

        clk = 0;
        toggle_enable = 0;
        toggle_mask = 0;
        #20;

        toggle_pin(0);   // Toggle pin 0 ON
        toggle_pin(3);   // Toggle pin 3 ON
        toggle_pin(0);   // Toggle pin 0 OFF
        toggle_pin(63);  // Toggle pin 63 ON
        toggle_pin(63);  // Toggle pin 63 OFF

        #50;
        $display("Final out_pins = %b", output_pins);
        $finish;
    end

endmodule


