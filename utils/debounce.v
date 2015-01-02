module debounce (input wire clk, reset, input wire sw, output reg db_tick);

    localparam [1:0] zero = 2'b00,
                     wait0 = 2'b01,
                     one = 2'b10,
                     wait1 = 2'b11;

    localparam N = 2;

    reg [1:0] state_reg, state_next;
    reg [N-1:0] q_reg;
    wire [N-1:0] q_next;
    wire q_zero;
    reg q_load, q_dec;

    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= zero;
            q_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            q_reg <= q_next;
        end

    assign q_next = (q_load) ? {N{1'b1}} :
                    (q_dec) ? q_reg - 1'b1 :
                    q_reg;

    assign q_zero = (q_next == 0);

    always @* begin
        state_next = state_reg;
        q_load = 1'b0;
        q_dec = 1'b0;
        db_tick = 1'b0;
        case (state_reg)
            zero : begin
                if (sw) begin
                    state_next = wait1;
                    q_load = 1'b1;
                end
            end
            wait1: begin
                if (sw) begin
                    q_dec = 1'b1;
                    if (q_zero) begin
                        db_tick = 1'b1;
                        state_next = one;
                    end
                end
            end
            one: begin
                if (~sw) begin
                    state_next = wait0;
                    q_load = 1'b1;
                end
            end
            wait0: begin
                if (~sw) begin
                    q_dec = 1'b1;
                    if (q_zero)
                        state_next = zero;
                end
                else
                    state_next = one;
            end
            default: state_next = zero;
        endcase
    end


endmodule
