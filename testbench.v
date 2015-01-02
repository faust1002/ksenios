module testbench;

    reg clk, reset, mem, rw;
    wire ready;

    ram_controller uut (.clk(clk), .reset(reset), .mem(mem), .rw(rw), .address(23'hFFFFF), .data_in(16'hFFFF), .ready(ready));

    initial begin
        $dumpfile("ram_controller.vcd");
        $dumpvars(0, uut);
    end

    initial begin
        clk = 1'b1;
        reset = 1'b1;
        mem = 1'b0;
        rw = 1'b0;
        #10 reset = 1'b0;
        wait(1'b1 == ready);
        #5 mem = 1'b1;
        #5 mem = 1'b0;
        wait(1'b1 == ready);
        #5 mem = 1'b1; rw = 1'b1;
        wait(1'b1 == ready);
        #100;
        $finish;
    end

    always #5 clk = ~clk;

endmodule
