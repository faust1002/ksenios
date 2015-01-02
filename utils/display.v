module display (input wire clk, reset, input wire [3:0] hex0, hex1, hex2, hex3, input wire [3:0] dp, output wire [3:0] an, output wire [7:0] sseg);

    localparam [2:0] rst = 3'b000,
	                 s0 = 3'b001,
                     s1 = 3'b010,
                     s2 = 3'b011,
                     s3 = 3'b100;
    localparam N = 19;

    reg [N-1:0] cnt_reg;
    wire [N-1:0] cnt_next;
    reg [2:0] state_reg, state_next;
    wire [7:0] disp0, disp1, disp2, disp3;
    reg [3:0] an_reg, an_next;
    reg [7:0] sseg_reg, sseg_next;

    hex2disp hex2disp_0(.hex(hex0), .disp(disp0), .dp(dp[0]));
    hex2disp hex2disp_1(.hex(hex1), .disp(disp1), .dp(dp[1]));
    hex2disp hex2disp_2(.hex(hex2), .disp(disp2), .dp(dp[2]));
    hex2disp hex2disp_3(.hex(hex3), .disp(disp3), .dp(dp[3]));

    always @(posedge reset, posedge clk)
        if (reset) begin
            state_reg <= rst;
            cnt_reg <= 0;
            an_reg <= 0;
            sseg_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            cnt_reg <= cnt_next;
            an_reg <= an_next;
            sseg_reg <= sseg_next;
        end
    
    assign cnt_next = cnt_reg + 1'b1;

    always @* begin
        state_next = state_reg;
        an_next = an_reg;
        sseg_next = sseg_reg;
        case (state_reg)
            s0: begin
                if (0 == cnt_reg) begin
                    an_next = 4'b1110;
                    sseg_next = disp0;
                    state_next = s1;				
                end
            end
            s1: begin
                if (0 == cnt_reg) begin
                    an_next = 4'b1101;
                    sseg_next = disp1;
                    state_next = s2;
                end
            end
            s2: begin
                if (0 == cnt_reg) begin
                    an_next = 4'b1011;
                    sseg_next = disp2;
                    state_next = s3;
                end
            end
            s3: begin
                if (0 == cnt_reg) begin
                    an_next = 4'b0111;
                    sseg_next = disp3;
                    state_next = s0;
                end
            end
            default: begin
                an_next = 4'b1111;
                sseg_next = 8'b0;
                state_next = s0;
            end
        endcase
    end

    assign an = an_reg;
    assign sseg = sseg_next;

endmodule

module hex2disp(input wire [3:0] hex, output reg [7:0] disp, input wire dp);
    
    always @* begin
        case (hex)
            4'h0 : disp[7:1] = 7'b0000001;
            4'h1 : disp[7:1] = 7'b1001111;
            4'h2 : disp[7:1] = 7'b0010010;
            4'h3 : disp[7:1] = 7'b0000110;
            4'h4 : disp[7:1] = 7'b1001100;
            4'h5 : disp[7:1] = 7'b0100100;
            4'h6 : disp[7:1] = 7'b0100000;
            4'h7 : disp[7:1] = 7'b0001111;
            4'h8 : disp[7:1] = 7'b0000000;
            4'h9 : disp[7:1] = 7'b0000100;
            4'ha : disp[7:1] = 7'b0001000;
            4'hb : disp[7:1] = 7'b1100000;
            4'hc : disp[7:1] = 7'b0110001;
            4'hd : disp[7:1] = 7'b1000010;
            4'he : disp[7:1] = 7'b0110000;
            4'hf : disp[7:1] = 7'b0111000;
        endcase
        disp[0] = ~dp;
	 end

endmodule
