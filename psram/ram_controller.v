module ram_controller (
        input wire clk, reset,
        input wire mem, rw,
        input wire [22:0] address,
        input wire [15:0] data_in,
        output wire initialized, ready,
        //psram
        output wire [22:0] addr,
        output wire oe, we, cl, adv, ce, ub, lb, cre,
        inout [15:0] dq,
        output wire [15:0] data_out
        );

        localparam [3:0] undefined = 4'b0000,
                         init      = 4'b0001,
                         wrd0      = 4'b0010,
                         wrd1      = 4'b0011,
                         wrd2      = 4'b0100,
                         rd0       = 4'b0101,
                         rd1       = 4'b0110,
                         rd2       = 4'b0111,
                         dn        = 4'b1000;

        reg [3:0] state_reg, state_next;
        reg initialized_reg, initialized_next;
        reg [13:0] internal_cnt, internal_next;
        reg oe_reg, we_reg, ce_reg, lb_reg, ub_reg, hiz_reg;
        reg oe_next, we_next, lb_next, ub_next, ce_next, hiz_next;
        reg [15:0] data_reg, data_next;

        always @(posedge clk, posedge reset)
            if (reset) begin
                state_reg <= undefined;
                initialized_reg <= 1'b0;
                internal_cnt <= 14'd15100;
                oe_reg <= 1'b1;
                we_reg <= 1'b1;
                lb_reg <= 1'b1;
                ub_reg <= 1'b1;
                ce_reg <= 1'b1;
                hiz_reg <= 1'b1;
                data_reg <= 16'h0000;
            end
            else begin
                state_reg <= state_next;
                initialized_reg <= initialized_next;
                internal_cnt <= internal_next;
                oe_reg <= oe_next;
                we_reg <= we_next;
                lb_reg <= lb_next;
                ub_reg <= ub_next;
                ce_reg <= ce_next;
                hiz_reg <= hiz_next;
                data_reg <= data_next;
            end

        always @* begin
            state_next = state_reg;
            initialized_next = initialized_reg;
            internal_next = internal_cnt;
            oe_next = oe_reg;
            we_next = we_reg;
            lb_next = lb_reg;
            ub_next = ub_reg;
            ce_next = ce_reg;
            hiz_next = hiz_reg;
            data_next = data_reg;
            case (state_reg)
                undefined: begin
                    internal_next = internal_cnt - 1'b1;
                    if (0 == internal_next) begin
                        state_next = init;
                        initialized_next = 1'b1;
                    end
                end
                init: begin
                    if ((1'b1 == mem) && (1'b0 == rw)) begin
                        state_next = wrd0;
                        hiz_next = 1'b0;
                        ce_next = 1'b0;
                        lb_next = 1'b0;
                        ub_next = 1'b0;
                    end
                    else if ((1'b1 == mem) && (1'b1 == rw)) begin
                        state_next = rd0;
                        ce_next = 1'b0;
                        lb_next = 1'b0;
                        ub_next = 1'b0;
                        internal_next = 14'd5;
                    end
                end
                wrd0: begin
                    state_next = wrd1;
                    we_next = 1'b0;
                end
                wrd1: begin
                    state_next = wrd2;
                    internal_next = 14'd4;
                end
                wrd2: begin
                    internal_next = internal_cnt - 1'b1;
                    if (0 == internal_next) begin
                        state_next = dn;
                        hiz_next = 1'b1;
                        ce_next = 1'b1;
                        lb_next = 1'b1;
                        ub_next = 1'b1;
                        we_next = 1'b1;
                    end
                end
                rd0: begin
                    internal_next = internal_cnt - 1'b1;
                    if (0 == internal_next) begin
                        state_next = rd1;
                        oe_next = 1'b0;
                        internal_next = 14'd2;
                    end
                end
                rd1: begin
                    internal_next = internal_cnt - 1'b1;
                    if (0 == internal_next)
                        state_next = rd2;
                end
                rd2: begin
                    data_next = dq;
                    state_next = dn;
                    ce_next = 1'b1;
                    lb_next = 1'b1;
                    ub_next = 1'b1;
                    oe_next = 1'b1;
                end
                dn: begin
                    state_next = init;
                end
            endcase
        end

        assign initialized = initialized_reg;
        assign ready = state_reg == dn;
        assign addr = address;
        assign adv = 1'b0;
        assign cl = 1'b0;
        assign cre = 1'b0;

        assign oe = oe_reg;
        assign we = we_reg;
        assign lb = lb_reg;
        assign ub = ub_reg;
        assign ce = ce_reg;

        assign dq = (hiz_reg) ? 16'bz : data_in;
        assign data_out = data_reg;

endmodule
