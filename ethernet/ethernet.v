module ethernet (
                 input wire clk, reset,
                 output wire ethernet_reset,
                 input wire ethernet_rx_clk, ethernet_rx_dv,
                 input wire [3:0] ethernet_rx,
                 output wire ethernet_mdc,
                 inout wire ethernet_mdio,
                 input wire ethernet_rd,
                 output wire ethernet_ready, ethernet_empty, ethernet_full,
                 output wire [7:0] frame_rx
                );

    wire init;
    wire frame_ready, aggregated_frame_ready;
    wire [3:0] frame;
    wire [7:0] aggregated_frame;

    ethernet_init ethernet_init_unit (.clk(clk), .reset(reset), .ethernet_reset(ethernet_reset),
                                      .ethernet_mdc(ethernet_mdc), .ethernet_mdio(ethernet_mdio),
                                      .init(init));

    ethernet_rx ethernet_rx_unit (.clk(clk), .reset(reset), .start(init), .ethernet_rx_clk(ethernet_rx_clk),
                                  .ethernet_rx_dv(ethernet_rx_dv), .ethernet_rx(ethernet_rx),
                                  .frame_ready(frame_ready), .frame(frame));

    ethernet_frame_aggegator ethernet_frame_aggegator_unit (.clk(clk), .reset(reset), .inframe(frame),
                                                            .inready(frame_ready), .outframe(aggregated_frame),
                                                            .outready(aggregated_frame_ready));

    fifo fifo_unit0 (.clk(clk), .reset(reset), .rd(ethernet_rd), .wr(init && aggregated_frame_ready),
                     .w_data(aggregated_frame), .empty(ethernet_empty), .full(ethernet_full), .r_data(frame_rx));

    assign ethernet_ready = init;

endmodule
