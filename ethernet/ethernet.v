module ethernet (
                 input wire clk, reset,
                 output wire ethernet_reset,
                 input wire ethernet_rx_clk, ethernet_rx_dv,
                 input wire [3:0] ethernet_rx,
                 output wire ethernet_mdc,
                 inout wire ethernet_mdio,
                 input wire ethernet_rd,
                 output wire ethernet_ready, ethernet_empty, ethernet_full,
                 output wire [3:0] nibble_rx
                );

    wire init;
    wire nibble_ready/*, byte_ready, last_nibble, preamble_detected*/;
    wire [3:0] nibble;
    //wire [7:0] byte;

    ethernet_init ethernet_init_unit (.clk(clk), .reset(reset), .ethernet_reset(ethernet_reset),
                                      .ethernet_mdc(ethernet_mdc), .ethernet_mdio(ethernet_mdio),
                                      .init(init));

    ethernet_rx ethernet_rx_unit (.clk(clk), .reset(reset), .start(init), .ethernet_rx_clk(ethernet_rx_clk),
                                  .ethernet_rx_dv(ethernet_rx_dv), .ethernet_rx(ethernet_rx), .nibble_ready(nibble_ready),
                                  .nibble(nibble)/*, .last_nibble(last_nibble)*/);

    /*ethernet_nibble_aggegator ethernet_nibble_aggegator_unit (.clk(clk), .reset(reset), .nibble(nibble),
                                                            .nibble_ready(nibble_ready), .byte(byte),
                                                            .byte_ready(byte_ready));

    ethernet_preable_detector ethernet_preable_detector_unit (.clk(clk), .reset(reset | last_nibble), .byte_ready(byte_ready),
                                                              .byte(byte), .preamble_detected(preamble_detected));*/

    fifo_16x4 fifo_unit (.clk(clk), .reset(reset), .rd(ethernet_rd), .wr(init && nibble_ready/* && preamble_detected*/),
                        .w_data(nibble), .empty(ethernet_empty), .full(ethernet_full), .r_data(nibble_rx));

    assign ethernet_ready = init;

endmodule
