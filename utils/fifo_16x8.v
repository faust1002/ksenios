module fifo_16x8 (
    input wire clk, reset,
    input wire [7:0] w_data,
    input wire wr, rd,
    output wire [7:0] r_data,
    output wire full, empty
);

    localparam [4:0] EMPTY = 5'h0,
                     FULL  = 5'h10;

    reg [3:0] wr_reg, rd_reg, wr_next, rd_next;
    reg [4:0] cnt_reg, cnt_next;
    xilinx_dist_ram_16x8 ram_unit (.data_in(w_data), .data_out(r_data),
                                   .waddr(wr_reg), .raddr(rd_reg), .we(wr), .wclk(clk));

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            wr_reg <= 8'b0;
            rd_reg <= 8'b0;
            cnt_reg <= 16'b0;
        end
        else begin
            wr_reg <= wr_next;
            rd_reg <= rd_next;
            cnt_reg <= cnt_next;
        end
    end

    always @* begin
        wr_next = wr_reg;
        rd_next = rd_reg;
        cnt_next = cnt_reg;
        case ({wr, rd})
            2'b10: begin
                if (cnt_reg < FULL) begin
                    wr_next = wr_reg + 1'b1;
                    cnt_next = cnt_reg + 1'b1;
                end
            end
            2'b01: begin
                if (cnt_reg > EMPTY) begin
                    rd_next = rd_reg + 1'b1;
                    cnt_next = cnt_reg - 1'b1;
                end
            end
            2'b11: begin
                wr_next = wr_next + 1'b1;
                rd_next = rd_reg + 1'b1;
            end
        endcase
    end

    assign empty = (EMPTY == cnt_reg);
    assign full = (FULL == cnt_reg);

endmodule
