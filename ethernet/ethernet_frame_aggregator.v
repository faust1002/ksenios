module ethernet_frame_aggegator (
    input wire clk, reset,
    input wire [3:0] inframe,
    input wire inready,
    output wire [7:0] outframe,
    output wire outready
);

    localparam empty = 1'b0,
               first = 1'b1;

    reg state_reg, state_next;
    reg [7:0] outframe_reg, outframe_next;
    reg outready_reg, outready_next;

    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= empty;
            outframe_reg <= 8'h0;
            outready_reg <= 1'b0;
        end
        else begin
            state_reg <= state_next;
            outframe_reg <= outframe_next;
            outready_reg <= outready_next;
        end

    always @* begin
        state_next = state_reg;
        outframe_next = outframe_reg;
        outready_next = outready_reg;
        case (state_reg)
            empty: begin
                outready_next = 1'b0;
                if (inready) begin
                    state_next = first;
                    outframe_next = {inframe, outframe_reg[7:4]};
                end
            end
            first: begin
                if (inready) begin
                    state_next = empty;
                    outframe_next = {inframe, outframe_reg[7:4]};
                    outready_next = 1'b1;
                end
            end
        endcase
    end

    assign outframe = outframe_reg;
    assign outready = outready_reg;

endmodule
