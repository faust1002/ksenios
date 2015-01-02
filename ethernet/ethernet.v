module ethernet #(parameter B = 8) (
                 input wire clk, reset,
                 output wire ethernet_reset,
                 input wire ethernet_rx_clk, ethernet_rx_dv, ethernet_crs,
                 input wire [3:0] ethernet_rx,
                 output wire ethernet_mdc,
                 inout wire ethernet_mdio,
                 input wire ethernet_rd,
                 output wire ethernet_ready, ethernet_empty, ethernet_full,
                 output wire [B-1:0] frame_rx
                );

    localparam [1:0] undefined = 2'b00,
                     advreg    = 2'b01,
                     neg       = 2'b10,
                     ready     = 2'b11;

                     

    reg [1:0] state_reg, state_next;
    reg reset_reg, reset_next;
    reg [13:0] cnt_reg, cnt_next;
    reg smi_init_reg, smi_init_next;
    reg [4:0] smi_register_reg, smi_register_next;
    reg [15:0] smi_content_reg, smi_content_next;
    wire smi_ready;

    wire frame_ready;
    reg delay;
    wire [B-1:0] frame;

    always @(posedge clk)
        delay <= frame_ready;

    ethernet_rx ethernet_rx_unit (.clk(clk), .reset(reset), .start(ethernet_ready), .ethernet_rx_clk(ethernet_rx_clk), .ethernet_rx_dv(ethernet_rx_dv), .ethernet_crs(ethernet_crs), .ethernet_rx(ethernet_rx), .frame_ready(frame_ready), .frame(frame));

    ethernet_smi ethernet_smi_unit (.clk(clk), .reset(reset), .init(smi_init_reg), .register(smi_register_reg), .content(smi_content_reg), .ethernet_mdc(ethernet_mdc), .ethernet_mdio(ethernet_mdio), .ready(smi_ready));

    fifo #(.B(B), .W(7)) fifo_unit0 (.clk(clk), .reset(reset), .rd(ethernet_rd), .wr(ethernet_ready && frame_ready && ~delay), .w_data(frame), .empty(ethernet_empty), .full(ethernet_full), .r_data(frame_rx));

    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= undefined;
            reset_reg <= 1'b0;
            cnt_reg <= 14'h0;
            smi_init_reg <= 1'b0;
            smi_register_reg <= 5'h0;
            smi_content_reg <= 16'h0;
        end
        else begin
            state_reg <= state_next;
            reset_reg <= reset_next;
            cnt_reg <= cnt_next;
            smi_init_reg <= smi_init_next;
            smi_register_reg <= smi_register_next;
            smi_content_reg <= smi_content_next;
        end

    always @* begin
        state_next = state_reg;
        reset_next = reset_reg;
        cnt_next = cnt_reg;
        smi_init_next = smi_init_reg;
        smi_register_next = smi_register_reg;
        smi_content_next = smi_content_reg;
        case (state_reg)
            undefined: begin
                cnt_next = cnt_reg + 1'b1;
                if (14'h9c5 == cnt_next) begin
                    state_next = ready;
                    reset_next = 1'b1;
                    smi_init_next = 1'b1;
                    smi_register_next = 5'd4;
                    smi_content_next = 16'b0000000111100001;
                end
            end
            advreg: begin
                if (smi_ready) begin
                    state_next = neg;
                    smi_init_next = 1'b1;
                    smi_register_next = 5'd0;
                    smi_content_next = 16'b0001001000000000;
                end
            end
            neg: begin
                smi_init_next = 1'b0;
                if (smi_ready) begin
                    state_next = ready;
                end
            end
            ready: begin
                state_next = ready;
            end
        endcase
    end

    assign ethernet_reset = reset_reg;
    assign ethernet_ready = state_reg == ready;

endmodule
