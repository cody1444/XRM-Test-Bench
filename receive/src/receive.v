module receive (
    input i_clk,
    input uart_rx,
    output LED1,
    output LED2,
    output LED3,
    output LED4,
    output LED5
);
    
    reg Q = 1'b0;
    wire [7:0] received_str;
    wire valid;

    uart_rx my_uart (
        .clk(i_clk),
        .uart_rx(uart_rx),
        .valid(valid),
        .data(received_str)
    );

    always @(posedge i_clk) begin
        if (valid) begin
            Q <= ~Q;
        end
    end

    assign LED1 = Q;
    assign LED2 = 0;
    assign LED3 = 0;
    assign LED4 = 0;
    assign LED5 = 0;

endmodule
