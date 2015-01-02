module ethernet_smi (
                     input wire clk, reset,
                     input wire init,
                     input wire [4:0] register,
                     input wire [15:0] content,
                     output wire ethernet_mdc,
                     inout wire ethernet_mdio,
                     output wire ready
                    );

    //clocking part part
    reg clock_state_reg;
    wire clock_state_next;
    reg [5:0] clock_cnt_reg;
    wire [5:0] clock_cnt_next;
    wire tick;

    localparam limit = 6'h28;

    always @(posedge clk, posedge reset)
        if (reset) begin
            clock_state_reg <= 1'b0;
            clock_cnt_reg <= 6'h0;
        end
        else begin
            clock_state_reg <= clock_state_next;
            clock_cnt_reg <= clock_cnt_next;
        end
    assign clock_state_next = (6'h0 == clock_cnt_reg) ? clock_state_reg + 1'b1 : clock_state_reg;
    assign clock_cnt_next = (limit == clock_cnt_reg) ? 6'h0 : clock_cnt_reg + 1'b1;
    assign ethernet_mdc = clock_state_reg;
    assign tick = (6'h14 == clock_cnt_reg) && (1'b1 == clock_state_reg);

    //data part
    localparam [3:0] idle      = 4'b0000,
                     preamble  = 4'b0001,
                     start     = 4'b0010,
                     opcode    = 4'b0011,
                     phyaddr   = 4'b0100,
                     regaddr   = 4'b0101,
                     turn      = 4'b0110,
                     data      = 4'b0111,
                     done      = 4'b1000;
    reg [4:0] state_reg, state_next;
    reg tri_reg, tri_next;
    reg [4:0] cnt_reg, cnt_next;
    reg ethernet_mdio_reg, ethernet_mdio_next;
    reg [4:0] register_reg, register_next;
    reg [15:0] content_reg, content_next;

    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= idle;
            tri_reg <= 1'b1;
            cnt_reg <= 5'h0;
            ethernet_mdio_reg <= 1'b1;
            register_reg <= 5'h0;
            content_reg <= 16'h0;
        end
        else begin
            state_reg <= state_next;
            tri_reg <= tri_next;
            cnt_reg <= cnt_next;
            ethernet_mdio_reg <= ethernet_mdio_next;
            register_reg <= register_next;
            content_reg <= content_next;
        end

    always @* begin
        state_next = state_reg;
        tri_next = tri_reg;
        cnt_next = cnt_reg;
        ethernet_mdio_next = ethernet_mdio_reg;
        register_next = register_reg;
        content_next = content_reg;
        case (state_reg)
            idle: begin
                if (init) begin
                    register_next = register;
                    content_next = content;
                    state_next = preamble;
                end
            end
            preamble: begin
                if (tick) begin
                    `ifdef testbench
                    cnt_next = cnt_reg + 1'b1;
                    `else
                    cnt_next = cnt_reg + ethernet_mdio;
                    `endif
                    if (5'h0 == cnt_next) begin
                        state_next = start;
                        tri_next = 1'b0;
                        ethernet_mdio_next = 1'b0;
                    end
                end
            end
            start: begin
                if (tick) begin
                    if (1'b1 == ethernet_mdio_reg) begin
                        state_next = opcode;
                        ethernet_mdio_next = 1'b0;
                    end
                    else begin
                        ethernet_mdio_next = 1'b1;
                    end
                end
            end
            opcode: begin
                if (tick) begin
                    if (1'b1 == ethernet_mdio_reg) begin
                        state_next = phyaddr;
                        ethernet_mdio_next = 1'b0;
                        cnt_next = 31'h0;
                    end
                    else begin
                        ethernet_mdio_next = 1'b1;
                    end
                end
            end
            phyaddr: begin
                if (tick) begin
                    cnt_next = cnt_reg + 1'b1;
                    if (6'h4 == cnt_reg) begin
                        state_next = regaddr;
                        cnt_next = 31'h0;
                        ethernet_mdio_next = register_reg[4];
                        register_next = register_reg << 1;
                    end
                end
            end
            regaddr: begin
                if (tick) begin
                    cnt_next = cnt_reg + 1'b1;
                    ethernet_mdio_next = register_reg[4];
                    register_next = register_reg << 1;
                    if (31'h4 == cnt_reg) begin
                        state_next = turn;
                        cnt_next = 31'h0;
                        ethernet_mdio_next = 1'b1;
                    end
                end
            end
            turn: begin
                if (tick) begin
                    if (1'b0 == ethernet_mdio_reg) begin
                        state_next = data;
                        ethernet_mdio_next = content_reg[15];
                        content_next = content_reg << 1;
                    end
                    else begin
                        ethernet_mdio_next = 1'b0;
                    end
                end
            end
            data: begin
                if (tick) begin
                    cnt_next = cnt_reg + 1'b1;
                    ethernet_mdio_next = content_reg[15];
                    content_next = content_reg << 1;
                    if (31'hE == cnt_reg) begin
                        state_next = done;
                        tri_next = 1'b1;
                    end
                end
            end
            done: begin
                state_next = idle;
            end
        endcase
    end

    assign ethernet_mdio =  (tri_reg) ? 1'bz : ethernet_mdio_reg;
    assign ready = done == state_reg;

endmodule
