module testbench;

    reg clk, reset, init;
    reg [4:0] register;
    wire ethernet_mdc, ethernet_mdio, ready;
    reg [15:0] content;

    ethernet_smi uut (.clk(clk), .reset(reset), .init(init), .register(register), .ethernet_mdc(ethernet_mdc), .ethernet_mdio(ethernet_mdio), .ready(ready), .content(content));

    initial begin
        $dumpfile("testbench_ethernet_smi.vcd");
        $dumpvars(0, uut);
    end

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        register = 5'd0;
        content = 16'h8000;
        #5;
        reset = 1'b0;
        #5;
        init = 1'b1;
        //#5000;
        wait(ready == 1'b1);
        #50;
        $finish;
    end

    always #5 clk = ~clk;

endmodule
