module ethernet (
                 input wire clk, reset,
                 output wire ethernet_reset,
                 input wire ethernet_rx_clk, ethernet_rx_dv,
                 input wire [3:0] ethernet_rx,
                 output wire ethernet_mdc,
                 inout wire ethernet_mdio,
                 input wire ethernet_rd,
                 output wire ethernet_ready, ethernet_empty, ethernet_full,
                 output wire [7:0] byte_rx
                );

    wire init;
    wire nibble_ready, byte_ready;
    wire [3:0] nibble;
    wire [7:0] byte;

    ethernet_init ethernet_init_unit (.clk(clk), .reset(reset), .ethernet_reset(ethernet_reset),
                                      .ethernet_mdc(ethernet_mdc), .ethernet_mdio(ethernet_mdio),
                                      .init(init));

    ethernet_rx ethernet_rx_unit (.clk(clk), .reset(reset), .start(init), .ethernet_rx_clk(ethernet_rx_clk),
                                  .ethernet_rx_dv(ethernet_rx_dv), .ethernet_rx(ethernet_rx),
                                  .nibble_ready(nibble_ready), .nibble(nibble));

    ethernet_nibble_aggegator ethernet_nibble_aggegator_unit (.clk(clk), .reset(reset), .nibble(nibble),
                                                            .nibble_ready(nibble_ready), .byte(byte),
                                                            .byte_ready(byte_ready));

    fifo fifo_unit0 (.clk(clk), .reset(reset), .rd(ethernet_rd), .wr(init && byte_ready),
                     .w_data(byte), .empty(ethernet_empty), .full(ethernet_full), .r_data(byte_rx));

    assign ethernet_ready = init;

endmodule
