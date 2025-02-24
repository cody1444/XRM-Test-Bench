module receive (
    input wire i_clk,
    input wire uart_rx,
    output LED1,
    output LED2,
    output LED3,
    output LED4,
    output LED5
);
    
    reg D = 1'b0;
    reg Q = 1'b0;
    // Declare received_str as an 88-bit vector (11 bytes)
    reg [8*11-1:0] received_str;
    wire valid;

    uart_rx my_uart (
        .clk(i_clk),
        .uart_rx(uart_rx),
        .data(received_str),
        .valid(valid)
    );

    always @(posedge i_clk) begin
        if (valid) begin
            D <= ~Q;
        end
        Q <= D;
    end

    assign LED1 = Q;
    assign LED2 = 0;
    assign LED3 = 0;
    assign LED4 = 0;
    assign LED5 = 0;

endmodule
