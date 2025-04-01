module uart_rx (
    input wire clk,          // System clock
    input wire uart_rx,      // Serial input
    output reg [7:0] data,   // Received byte
    output reg valid         // Data valid flag (1 cycle pulse)
);

    parameter CLK_FREQ = 12000000;  // 12 MHz system clock
    parameter BAUD_RATE = 9600;     // UART baud rate
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE; // Clock cycles per bit

    // State Encoding
    parameter IDLE        = 2'b00;
    parameter START_BIT   = 2'b01;
    parameter DATA_BITS   = 2'b10;
    parameter STOP_BIT    = 2'b11;

    reg [1:0] state = IDLE;
    reg [15:0] baud_counter = 0;
    reg [3:0] bit_index = 0;
    reg [7:0] shift_reg = 0;

    always @(posedge clk) begin
        case (state)
            // **IDLE: Wait for Start Bit**
            IDLE: begin
                valid <= 0;
                if (uart_rx == 0) begin  // Start bit detected
                    state <= START_BIT;
                    baud_counter <= 0;
                end
            end

            // **START_BIT: Wait for the middle of the start bit**
            START_BIT: begin
                if (baud_counter < CLKS_PER_BIT / 2) begin
                    baud_counter <= baud_counter + 1;
                end else begin
                    baud_counter <= 0;
                    state <= DATA_BITS;
                    bit_index <= 0;
                end
            end

            // **DATA_BITS: Receive 8 Data Bits**
            DATA_BITS: begin
                if (baud_counter < CLKS_PER_BIT) begin
                    baud_counter <= baud_counter + 1;
                end else begin
                    baud_counter <= 0;
                    shift_reg <= {uart_rx, shift_reg[7:1]}; // Shift LSB first
                    bit_index <= bit_index + 1;
                    
                    if (bit_index == 7) begin  // All 8 bits received
                        state <= STOP_BIT;
                    end
                end
            end

            // **STOP_BIT: Wait for Stop Bit**
            STOP_BIT: begin
                if (baud_counter < CLKS_PER_BIT) begin
                    baud_counter <= baud_counter + 1;
                end else begin
                    baud_counter <= 0;
                    data <= shift_reg;  // Store received byte
                    valid <= 1;         // Signal valid data for one clock cycle
                    state <= IDLE;      // Go back to idle state
                end
            end

            default: state <= IDLE;
        endcase
    end
endmodule

