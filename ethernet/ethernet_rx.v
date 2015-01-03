module ethernet_rx (
                    input wire clk, reset,
                    input wire start,
                    input wire ethernet_rx_clk, ethernet_rx_dv,
                    input wire [3:0] ethernet_rx,
                    output wire frame_ready,
                    output wire [3:0] frame
                   );

    localparam [1:0] undefined = 2'b00,
                     idle      = 2'b01,
                     data      = 2'b10,
                     break     = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [3:0] frame_reg, frame_next;
    reg frame_ready_reg, frame_ready_next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= undefined;
            frame_reg <= 4'h0;
            frame_ready_reg <= 1'b0;
        end
        else begin
            state_reg <= state_next;
            frame_reg <= frame_next;
            frame_ready_reg <= frame_ready_next;
        end
    end

    always @* begin
        state_next = state_reg;
        frame_next = frame_reg;
        frame_ready_next = frame_ready_reg;
        case (state_reg)
            undefined: begin
                if (start) begin
                    state_next = data;
                end
            end
            data: begin
                if (ethernet_rx_dv & ethernet_rx_clk) begin
                    state_next = idle;
                    frame_next = ethernet_rx;
                    frame_ready_next = 1'b1;
                end
            end
            idle: begin
                frame_ready_next = 1'b0;
                if ((ethernet_rx_dv & ~ethernet_rx_clk) || (~ethernet_rx_dv)) begin
                    state_next = data;
                end
            end
        endcase
    end

    assign frame = frame_reg;
    assign frame_ready = frame_ready_reg;

endmodule
