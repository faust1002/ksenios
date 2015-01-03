module ethernet_nibble_aggegator (
    input wire clk, reset,
    input wire [3:0] nibble,
    input wire nibble_ready,
    output wire [7:0] byte,
    output wire byte_ready
);

    localparam empty = 1'b0,
               first = 1'b1;

    reg state_reg, state_next;
    reg [7:0] byte_reg, byte_next;
    reg byte_ready_reg, byte_ready_next;

    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= empty;
            byte_reg <= 8'h0;
            byte_ready_reg <= 1'b0;
        end
        else begin
            state_reg <= state_next;
            byte_reg <= byte_next;
            byte_ready_reg <= byte_ready_next;
        end

    always @* begin
        state_next = state_reg;
        byte_next = byte_reg;
        byte_ready_next = byte_ready_reg;
        case (state_reg)
            empty: begin
                byte_ready_next = 1'b0;
                if (nibble_ready) begin
                    state_next = first;
                    byte_next = {nibble, byte_reg[7:4]};
                end
            end
            first: begin
                if (nibble_ready) begin
                    state_next = empty;
                    byte_next = {nibble, byte_reg[7:4]};
                    byte_ready_next = 1'b1;
                end
            end
        endcase
    end

    assign byte = byte_reg;
    assign byte_ready = byte_ready_reg;

endmodule
