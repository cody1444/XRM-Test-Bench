`timescale 1ns / 1ps

module decoder_tb;

    // DUT inputs
    reg [7:0] command_byte;
    reg byte_ready;

    // DUT output
    wire [63:0] toggle_mask;

    // Instantiate the DUT
    decoder uut (
        .command_byte(command_byte),
        .byte_ready(byte_ready),
        .toggle_mask(toggle_mask)
    );

    // Task to test a single byte
    task test_command(input [7:0] cmd);
        begin
            command_byte = cmd;
            byte_ready = 1;
            #1;
            byte_ready = 0;
            #1;
            $display("Command: 0x%h | Index: %0d | Toggle Mask: %b", cmd, cmd[5:0], toggle_mask);
        end
    endtask

    initial begin
        $display("Starting decoder testbench...");
        $dumpfile("decoder_tb.vcd");
        $dumpvars(0, decoder_tb);

        byte_ready = 0;
        command_byte = 0;
        #5;

        test_command(8'h00);  // Should set bit 0
        test_command(8'h01);  // Should set bit 1
        test_command(8'h3F);  // Should set bit 63
        test_command(8'hA5);  // Bit 37
        test_command(8'hFF);  // Lower 6 bits = 63 again

        #10;
        $finish;
    end

endmodule


