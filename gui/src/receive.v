module receive (
    input wire i_clk,
    input wire uart_rx,
    output reg LED1,
    output reg LED2,
    output reg LED3,
    output reg LED4,
    output reg LED5
);

    wire valid;
    wire [7:0] received_byte;
    reg [7:0] buffer [0:9]; // Buffer for incoming characters (max 10 chars)
    reg [3:0] buf_index = 0; // Tracks current buffer position

    uart_rx my_uart (
        .clk(i_clk),
        .uart_rx(uart_rx),
        .valid(valid),
        .data(received_byte)
    );

    always @(posedge i_clk) begin
        if (valid) begin
            if (received_byte == 8'h0A) begin  // Newline (\n) → Process command
                if (buffer[0] == "L" && buffer[1] == "E" && buffer[2] == "D") begin
                    case (buffer[3])  // Extract LED number
                        "1": begin
                            if (buffer[5] == "O" && buffer[6] == "N")  LED1 <= 1;
                            if (buffer[5] == "O" && buffer[6] == "F")  LED1 <= 0;
                        end
                        "2": begin
                            if (buffer[5] == "O" && buffer[6] == "N")  LED2 <= 1;
                            if (buffer[5] == "O" && buffer[6] == "F")  LED2 <= 0;
                        end
                        "3": begin
                            if (buffer[5] == "O" && buffer[6] == "N")  LED3 <= 1;
                            if (buffer[5] == "O" && buffer[6] == "F")  LED3 <= 0;
                        end
                        "4": begin
                            if (buffer[5] == "O" && buffer[6] == "N")  LED4 <= 1;
                            if (buffer[5] == "O" && buffer[6] == "F")  LED4 <= 0;
                        end
                        "5": begin
                            if (buffer[5] == "O" && buffer[6] == "N")  LED5 <= 1;
                            if (buffer[5] == "O" && buffer[6] == "F")  LED5 <= 0;
                        end
                    endcase
                end
                buf_index <= 0;  // Reset buffer after processing
            end else begin
                buffer[buf_index] <= received_byte;  // Store received character
                if (buf_index < 9) begin
                    buf_index <= buf_index + 1;
                end
            end
        end
    end

endmodule
