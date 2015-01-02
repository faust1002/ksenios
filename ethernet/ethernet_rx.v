module ethernet_rx (
                    input wire clk, reset,
                    input wire start,
                    input wire ethernet_rx_clk, ethernet_rx_dv, ethernet_crs,
                    input wire [3:0] ethernet_rx,
                    output wire frame_ready,
                    output wire [7:0] frame
                   );

    localparam [1:0] undefined = 2'b00,
                     idle      = 2'b01,
                     data      = 2'b10,
                     break     = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [7:0] frame_reg, frame_next;
    reg preamble_reg, preamble_next;
    reg [1:0] cnt_reg, cnt_next;

    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= undefined;
            frame_reg <= 8'h0;
            cnt_reg <= 2'h0;
            preamble_reg <= 1'b0;
        end
        else begin
            state_reg <= state_next;
            frame_reg <= frame_next;
            cnt_reg <= cnt_next;
            preamble_reg <= preamble_next;
        end

    always @* begin
        state_next = state_reg;
        frame_next = frame_reg;
        cnt_next = cnt_reg;
        case (state_reg)
            undefined: begin
                cnt_next = 2'b11;
                if (start) begin
                    state_next = idle;
                end
            end
            idle: begin
                cnt_next = 2'b11;
                if (ethernet_crs) begin
                    state_next = data;
                end
            end
            data: begin
                if (ethernet_rx_clk && ethernet_rx_dv) begin
                    cnt_next = cnt_reg - 1'b1;
                    state_next = break;
                    frame_next = {ethernet_rx, frame_reg[7:4]};
                end
                else if (~ethernet_rx_dv) begin
                    state_next = idle;
                end
            end
            break: begin
                if (~ethernet_rx_clk && ethernet_rx_dv) begin
                    cnt_next = cnt_reg - 1'b1;
                    state_next = data;
                end
                else if (~ethernet_rx_dv) begin
                    state_next = idle;
                end
            end
        endcase
    end

    always @* begin
        preamble_next = preamble_reg;
        if (idle == state_next) begin
            preamble_next = 1'b0;
        end
        else if (data == state_next) begin
            preamble_next = preamble_reg || (8'hd5 == frame_reg);
        end
    end

    assign frame_ready = (2'b00 == cnt_reg) && (break == state_reg) && preamble_reg;
    assign frame = frame_reg;

endmodule
