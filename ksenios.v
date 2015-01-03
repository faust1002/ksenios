module ksenios (
                //standard
                input wire clk, reset,
                //psram signals
                output wire [22:0] addr,
                output wire oe, we, cl, adv, ce, ub, lb, cre,
                inout [15:0] dq,
                //display signals
                output wire [3:0] an,
                output wire [7:0] sseg,
                //uart signals
                output wire uart_tx,
                output wire uart_tx_full, uart_tx_empty,
                //ethernet signals
                output wire ethernet_reset,
                input wire ethernet_rx_clk, ethernet_rx_dv,
                input wire [3:0] ethernet_rx,
                output wire ethernet_mdc,
                inout wire ethernet_mdio,
                output wire ethernet_rx_empty, ethernet_rx_full,
                //status leds
                output wire dn, fl
               );

    localparam [2:0] undefined  = 3'b000,
                     start      = 3'b001,
                     write      = 3'b010,
                     read       = 3'b011,
                     ready      = 3'b100,
                     ethernet   = 3'b101,
                     fail       = 3'b110;
    
    reg [2:0] state_reg, state_next;
    //psram part
    wire psram_initialized;
    reg psram_mem_reg, psram_mem_next, psram_rw_reg, psram_rw_next;
    wire psram_ready;
    wire [15:0] psram_data_out;
    reg [22:0] address_reg, address_next;
    //ethernet part
    wire ethernet_ready;
    reg ethernet_rd_reg, ethernet_rd_next;
    wire [7:0] frame_rx;
    wire [7:0] frame_rx_ascii1, frame_rx_ascii0;
    //shift register part
    reg we_reg, we_next;
    reg dec_reg, dec_next;
    wire empty;
    wire [7:0] uart_w_data;
    reg [15:0] data_reg, data_next;
    //debounce part
    wire wr_uart;
    //errors
    reg [15:0] errors_reg, errors_next;

    ram_controller ram_controller_unit (.clk(clk), .reset(reset), .mem(psram_mem_reg), .rw(psram_rw_reg), .address(address_reg), .data_in(address_reg[15:0]), .initialized(psram_initialized), .ready(psram_ready), .addr(addr), .oe(oe), .we(we), .cl(cl), .adv(adv), .ce(ce), .ub(ub), .lb(lb), .cre(cre), .dq(dq), .data_out(psram_data_out));
    
    ethernet ethernet_unit (.clk(clk), .reset(reset), .ethernet_reset(ethernet_reset), .ethernet_rx_clk(ethernet_rx_clk), .ethernet_rx_dv(ethernet_rx_dv), .ethernet_rx(ethernet_rx), .ethernet_mdc(ethernet_mdc), .ethernet_mdio(ethernet_mdio), .ethernet_rd(ethernet_rd_reg), .ethernet_ready(ethernet_ready), .ethernet_empty(ethernet_rx_empty), .ethernet_full(ethernet_rx_full), .frame_rx(frame_rx));
    bin2ascii bin2ascii_unit1 (.bin(frame_rx[7:4]), .ascii(frame_rx_ascii1));
    bin2ascii bin2ascii_unit0 (.bin(frame_rx[3:0]), .ascii(frame_rx_ascii0));
    
    display display_unit (.clk(clk), .reset(reset), .hex0(errors_reg[3:0]), .hex1(errors_reg[7:4]), .hex2(errors_reg[11:8]), .hex3(errors_reg[15:12]), .dp(4'b0000), .an(an), .sseg(sseg));
    
    uart uart_unit (.clk(clk), .reset(reset), .tx(uart_tx), .wr_uart(wr_uart), .w_data(uart_w_data), .tx_full(uart_tx_full), .tx_empty(uart_tx_empty));
    assign wr_uart = ~empty && (state_reg !== undefined) && ~uart_tx_full;

    shift_register #(.L(2)) shift_register_unit (.clk(clk), .reset(reset), .data_in(data_reg), .we(we_reg), .en(~uart_tx_full), .dec(dec_reg), .data_out(uart_w_data), .empty(empty));

    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= undefined;
            psram_mem_reg <= 1'b0;
            psram_rw_reg <= 1'b0;
            address_reg <= 23'h0;
            ethernet_rd_reg <= 1'b0;
            we_reg <= 1'b0;
            dec_reg <= 1'b1;
            data_reg <= 24'h0;
            errors_reg <= 16'h0;
        end
        else begin
            state_reg <= state_next;
            psram_mem_reg <= psram_mem_next;
            psram_rw_reg <= psram_rw_next;
            address_reg <= address_next;
            ethernet_rd_reg <= ethernet_rd_next;
            we_reg <= we_next;
            dec_reg <= dec_next;
            data_reg <= data_next;
            errors_reg <= errors_next;
        end

    always @* begin
        state_next = state_reg;
        psram_mem_next = psram_mem_reg;
        psram_rw_next = psram_rw_reg;
        address_next = address_reg;
        ethernet_rd_next = ethernet_rd_reg;
        we_next = we_reg;
        dec_next = dec_reg;
        data_next = data_reg;
        errors_next = errors_reg;
        case (state_reg)
            undefined: begin
                if (psram_initialized && ethernet_ready) begin
                    state_next = start;
                    we_next = 1'b0;
                end
            end
            start: begin
                `ifdef testbench
                 state_next = ready;
                `else
                state_next = write;
                psram_mem_next = 1'b1;
                psram_rw_next = 1'b0;
                `endif
            end
            write: begin
                if (psram_ready) begin
                    address_next = address_reg + 1'b1;
                    if (23'h0 == address_next) begin
                        state_next = read;
                        psram_rw_next = 1'b1;
                        address_next = 23'h0;
                    end
                end
            end
            read: begin
                if (psram_ready) begin
                    errors_next = errors_reg + (address_reg[15:0] !== psram_data_out);
                    address_next = address_reg + 1'b1;
                    if (23'h0 == address_next) begin
                        if (23'h0 == errors_reg) begin
                            state_next = ready;
                        end
                        else begin
                            state_next = fail;
                        end
                    end
                end
            end
            ready: begin
                if (~ethernet_rx_empty) begin
                    state_next = ethernet;
                    ethernet_rd_next = 1'b1;
                    we_next = 1'b1;
                    data_next = {frame_rx_ascii1, frame_rx_ascii0};
                end
                else begin
                    state_next = ready;
                    ethernet_rd_next = 1'b0;
                    we_next = 1'b0;
                    dec_next = 1'b1;
                end
            end
            ethernet: begin
                ethernet_rd_next = 1'b0;
                we_next = 1'b0;
                dec_next = 1'b0;
                if (empty) begin
                    state_next = ready;
                end
            end
            fail: begin
                state_next = fail;
            end
        endcase
    end

    assign dn =  ready == state_reg;
    assign fl = fail == state_reg;

endmodule
