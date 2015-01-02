module testbench;

    reg clk, reset;
    wire [22:0] addr;
    wire oe, we, cl, adv, ce, ub, lb, cre; 
    wire [15:0] dq;
    wire [3:0] an;
    wire [7:0] sseg;
    wire uart_tx, uart_tx_full, uart_tx_empty;
    wire ethernet_reset;
    //reg ethernet_rx_clk, ethernet_rx_dv, ethernet_crs, ethernet_rx_er;
    //reg [3:0] ethernet_rx;
    wire ethernet_mdc, ethernet_mdio;
    wire ethernet_rx_empty, ethernet_rx_full;
    wire dn;

    ksenios uut (.clk(clk), .reset(reset), .addr(addr), .oe(oe), .we(we), .cl(cl), .adv(adv), .ce(ce), .ub(ub), .lb(lb), .cre(cre), .dq(dq), .an(an), .sseg(sseg), .uart_tx(uart_tx), .uart_tx_full(uart_tx_full), .uart_tx_empty(uart_tx_empty), .ethernet_reset(ethernet_reset), /*.ethernet_rx_clk(ethernet_rx_clk), .ethernet_rx_dv(ethernet_rx_dv), .ethernet_crs(ethernet_crs), .ethernet_rx_er(ethernet_rx_er), .ethernet_rx(ethernet_rx),*/ .ethernet_mdc(ethernet_mdc), .ethernet_mdio(ethernet_mdio), .ethernet_rx_empty(ethernet_rx_empty), .ethernet_rx_full(ethernet_rx_full), .dn(dn));

    initial begin
        $dumpfile("testbench_ksenios.vcd");
        $dumpvars(0, uut);
    end

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        /*ethernet_rx_clk = 1'b0;
        ethernet_rx_dv = 1'b0;
        ethernet_rx = 4'h0;
        ethernet_crs = 1'b0;
        ethernet_rx_er = 1'b1;*/
        #10;
        reset = 1'b0;
        #20;
        wait(uut.state_reg == 3'b100);
        #5000;
        $finish;
    end

    always #5 clk = ~clk;

endmodule
