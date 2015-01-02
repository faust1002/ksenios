module testbench;

    reg clk, reset, start, ethernet_rx_clk, ethernet_rx_dv, ethernet_crs, ethernet_rx_er;
    reg [3:0] ethernet_rx;
    wire frame_ready;
    wire [7:0] frame;

    ethernet_rx uut (.clk(clk), .reset(reset), .start(start), .ethernet_rx_clk(ethernet_rx_clk), .ethernet_rx_dv(ethernet_rx_dv), .ethernet_rx(ethernet_rx), .ethernet_crs(ethernet_crs), .ethernet_rx_er(ethernet_rx_er), .frame_ready(frame_ready), .frame(frame));

    initial begin
        $dumpfile("testbench_ethernet_rx.vcd");
        $dumpvars(0, uut);
    end

    initial begin
        clk = 1'b1;
        reset = 1'b1;
        start = 1'b0;
        ethernet_rx_clk = 1'b0;
        ethernet_rx_dv = 1'b0;
        ethernet_rx = 4'h0;
        ethernet_crs = 1'b0;
        ethernet_rx_er = 1'b0;
        #10;
        reset = 1'b0;
        #10;
        start = 1'b1;
        wait(uut.state_reg == 2'b11);
        #5;
        $finish;
    end

    always #5 clk = ~clk;

endmodule
