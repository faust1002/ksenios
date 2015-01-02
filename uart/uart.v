module uart #(parameter DBIT = 8, SB_TICK = 16, DVSR = 54, DVSR_BIT = 6)
             (
              input wire clk, reset,
              output wire tx,
              input wire wr_uart,
              input wire [7:0] w_data,
              output wire tx_full, tx_empty
             );

    wire tick, rx_done_tick, tx_done_tick;
    wire [7:0] tx_data_out;

    baud_rate_generator #(.M(DVSR), .N(DVSR_BIT)) baud_gen_unit (.clk(clk), .reset(reset), .max_tick(tick));

    fifo fifo_tx_unit (.clk(clk), .reset(reset), .rd(tx_done_tick), .wr(wr_uart), .w_data(w_data), .empty(tx_empty), .full(tx_full), .r_data(tx_data_out));

    uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_tx_unit (.clk(clk), .reset(reset), .tx_start(~tx_empty), .s_tick(tick), .din(tx_data_out), .tx_done_tick(tx_done_tick), .tx(tx));

endmodule
