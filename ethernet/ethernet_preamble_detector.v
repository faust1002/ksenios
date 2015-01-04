module ethernet_preable_detector (
    input wire clk, reset,
    input wire byte_ready,
    input wire [7:0] byte,
    output wire preamble_detected
);

    localparam [1:0] not_detected = 2'b00,
                     preamble     = 2'b01,
                     detected     = 2'b10;

    reg [1:0] state_reg, state_next;

    always @(posedge clk, posedge reset)
        if (reset)
            state_reg <= not_detected;
        else
            state_reg <= state_next;

    always @* begin
        state_next = state_reg;
        case (state_reg)
            not_detected: begin
                if (byte_ready && (8'hd5 == byte))
                    state_next = preamble;
            end
            preamble: begin
                state_next = detected;
            end
            detected: begin
                state_next = detected;
            end
        endcase
    end

    assign preamble_detected = (detected == state_reg);

endmodule
