module uart_rx #(
    parameter CLK_FREQ = 12000000,  // 12 MHz system clock
    parameter BAUD_RATE = 9600,       // UART baud rate
    parameter MAX_LEN = 11            // Maximum number of characters in the string
)(
    input  wire clk,         // System clock
    input  wire uart_rx,     // Serial input
    output reg [8*MAX_LEN-1:0] data,  // Flattened buffer: 11 bytes in one vector
    output reg valid         // Asserted when a full command is received
);

    // Internal registers
    reg [3:0] bit_index = 0;
    reg [7:0] shift_reg = 0;
    reg [15:0] baud_counter = 0;
    reg receiving = 0;
    reg [3:0] buf_index = 0;  // Index for storing bytes in the flat vector

    always @(posedge clk) begin
        if (receiving) begin
            baud_counter <= baud_counter + 1;
            if (baud_counter >= (CLK_FREQ / BAUD_RATE)) begin
                baud_counter <= 0;
                // Shift in the next bit from uart_rx
                shift_reg <= {uart_rx, shift_reg[7:1]};
                bit_index <= bit_index + 1;
                if (bit_index == 8) begin
                    // Store the received byte into the correct 8-bit slice
                    data[buf_index*8 +: 8] <= shift_reg;
                    // Check for newline termination or buffer full
                    if (shift_reg == "\n") begin
                        valid <= 1;
                        buf_index <= 0;
                    end else begin
                        buf_index <= buf_index + 1;
                        if (buf_index == MAX_LEN-1) begin
                            valid <= 1;
                            buf_index <= 0;
                        end else begin
                            valid <= 0;
                        end
                    end

                    bit_index <= 0;
                    receiving <= 0;
                end
            end
        end else if (!uart_rx) begin
            // Start bit detected: begin receiving a new byte
            receiving <= 1;
            baud_counter <= 0;
            bit_index <= 0;
        end else begin
            valid <= 0;
        end
    end

endmodule

