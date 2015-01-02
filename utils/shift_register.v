module shift_register #(parameter L = 8) (
                                        input wire clk, reset,
                                        input wire [(8*L)-1:0] data_in,
                                        input wire we, en, dec,
                                        output wire [7:0] data_out,
                                        output wire empty
                                       );

    reg [(8*(L+2))-1:0] data_in_reg, data_in_next;

    always @(posedge reset, posedge clk)
        if (reset)
            data_in_reg <= 0;
        else
            data_in_reg <= data_in_next;

    always @*
        if (we) begin
            if (dec)
                data_in_next = {8'h0d, 8'ha, data_in};
            else
                data_in_next = {data_in, 16'h0};
            //data_in_next = {data_in, 16'h0};
        end
        else if (en) begin
            data_in_next = data_in_reg << 8;
        end
        else begin
            data_in_next = data_in_reg;
        end

    assign data_out = data_in_reg[8*(L+2)-1:8*(L+1)];
    assign empty = 8'b0 == data_in_reg[8*(L+2)-1:8*(L+1)] && 1'b0 == we;

endmodule
