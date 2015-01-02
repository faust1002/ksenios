module testbench;

    reg clk, reset;
    wire ethernet_reset;
    reg ethernet_rx_clk, ethernet_rx_dv, ethernet_crs, ethernet_rx_er;
    reg [3:0] ethernet_rx;
    wire ethernet_mdc, ethernet_mdio;
    reg ethernet_rd;
    wire ethernet_ready, ethernet_empty, ethernet_full;
    wire [7:0] frame_rx;

    ethernet uut (.clk(clk), .reset(reset), .ethernet_reset(ethernet_reset), .ethernet_rx_clk(ethernet_rx_clk), .ethernet_rx_dv(ethernet_rx_dv), .ethernet_crs(ethernet_crs), .ethernet_rx_er(ethernet_rx_er), .ethernet_rx(ethernet_rx), .ethernet_mdc(ethernet_mdc), .ethernet_mdio(ethernet_mdio), .ethernet_rd(ethernet_rd), .ethernet_ready(ethernet_ready), .ethernet_empty(ethernet_empty), .ethernet_full(ethernet_full), .frame_rx(frame_rx));

    initial begin
        $dumpfile("testbench_ethernet.vcd");
        $dumpvars(0, uut);
    end

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        ethernet_rx_clk = 1'b0;
        ethernet_rx_dv = 1'b0;
        ethernet_crs = 1'b0;
        ethernet_rx_er = 1'b0;
        ethernet_rx = 4'b0;
        ethernet_rd = 1'b0;
        #10;
        reset = 1'b0;
        wait(1'b1 == ethernet_ready);
        #2000;
        $finish;
    end

    always #5 clk = ~clk;

endmodule
