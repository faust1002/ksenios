module testbench_shift_register;

    localparam B = 8, L = 4;

    reg clk, reset, we;
    reg [B*L-1:0] data_in;
    wire [B-1:0] data_out;
    wire empty;

    shift_register #(.B(B), .L(L)) uut (.clk(clk), .reset(reset), .data_in(data_in), .we(we), .data_out(data_out), .empty(empty));

    initial begin
        $dumpfile("testbench_shift_register.vcd");
        $dumpvars(0, uut);
    end

    initial begin
        clk = 1'b1;
        reset = 1'b1;
        data_in = 32'haabbccdd; 
        we = 1'b0;
        #10;
        reset = 1'b0;
        we = 1'b1;
        #5;
        we = 1'b0;
        wait(8'h1 == empty);
        #5;
        we = 1'b1;
        #5;
        we = 1'b0;
        wait(8'h1 == empty);
        #100;
        $finish;
    end

    always #5 clk = ~clk;

endmodule
