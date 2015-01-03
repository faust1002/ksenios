module ethernet (
                 input wire clk, reset,
                 output wire ethernet_reset,
                 input wire ethernet_rx_clk, ethernet_rx_dv, ethernet_crs,
                 input wire [3:0] ethernet_rx,
                 output wire ethernet_mdc,
                 inout wire ethernet_mdio,
                 input wire ethernet_rd,
                 output wire ethernet_ready, ethernet_empty, ethernet_full,
                 output wire [7:0] frame_rx
                );

    localparam undefined = 1'b0,
               ready     = 1'b1;

    reg state_reg, state_next;
    wire init;
    wire frame_ready;
    reg delay;
    wire [7:0] frame;

    always @(posedge clk)
        delay <= frame_ready;

    ethernet_init ethernet_init_unit (.clk(clk), .reset(reset), .ethernet_reset(ethernet_reset),
                                      .ethernet_mdc(ethernet_mdc), .ethernet_mdio(ethernet_mdio),
                                      .init(init));

    ethernet_rx ethernet_rx_unit (.clk(clk), .reset(reset), .start(ethernet_ready), .ethernet_rx_clk(ethernet_rx_clk), .ethernet_rx_dv(ethernet_rx_dv), .ethernet_crs(ethernet_crs), .ethernet_rx(ethernet_rx), .frame_ready(frame_ready), .frame(frame));

    fifo fifo_unit0 (.clk(clk), .reset(reset), .rd(ethernet_rd), .wr(ethernet_ready && frame_ready && ~delay), .w_data(frame), .empty(ethernet_empty), .full(ethernet_full), .r_data(frame_rx));

    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= undefined;
        end
        else begin
            state_reg <= state_next;
        end

    always @* begin
        state_next = state_reg;
        case (state_reg)
            undefined: begin
                if (init) begin
                    state_next = ready;
                end
            end
            ready: begin
                state_next = ready;
            end
        endcase
    end

    assign ethernet_ready = state_reg == ready;

endmodule
