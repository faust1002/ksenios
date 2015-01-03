module ethernet_init (
    input wire clk, reset,
    output wire ethernet_reset,
    output wire ethernet_mdc,
    inout wire ethernet_mdio,
    output wire init
);

    localparam [1:0] undefined = 2'b00,
                     advreg    = 2'b01,
                     neg       = 2'b10,
                     ready     = 2'b11;

    wire smi_ready;
    reg [1:0] state_reg, state_next;
    reg reset_reg, reset_next;
    reg ready_reg, ready_next;
    reg [13:0] cnt_reg, cnt_next;
    reg smi_init_reg, smi_init_next;
    reg [4:0] smi_register_reg, smi_register_next;
    reg [15:0] smi_content_reg, smi_content_next;

    ethernet_smi ethernet_smi_unit (.clk(clk), .reset(reset), .init(smi_init_reg), .register(smi_register_reg), .content(smi_content_reg), .ethernet_mdc(ethernet_mdc), .ethernet_mdio(ethernet_mdio), .ready(smi_ready));

    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= undefined;
            reset_reg <= 1'b0;
            ready_reg <= 1'b0;
            cnt_reg <= 14'h0;
            smi_init_reg <= 1'b0;
            smi_register_reg <= 5'h0;
            smi_content_reg <= 16'h0;
        end
        else begin
            state_reg <= state_next;
            reset_reg <= reset_next;
            ready_reg <= ready_next;
            cnt_reg <= cnt_next;
            smi_init_reg <= smi_init_next;
            smi_register_reg <= smi_register_next;
            smi_content_reg <= smi_content_next;
        end
    
    always @* begin
        state_next = state_reg;
        reset_next = reset_reg;
        cnt_next = cnt_reg;
        smi_init_next = smi_init_reg;
        smi_register_next = smi_register_reg;
        smi_content_next = smi_content_reg;
        ready_next = ready_reg;
        case (state_reg)
            undefined: begin
                cnt_next = cnt_reg + 1'b1;
                if (14'h9c5 == cnt_next) begin
                    state_next = advreg;
                    reset_next = 1'b1;
                    smi_init_next = 1'b1;
                    smi_register_next = 5'h4;
                    smi_content_next = 16'h01e1;
                end
            end
            advreg: begin
                if (smi_ready) begin
                    state_next = neg;
                    smi_init_next = 1'b1;
                    smi_register_next = 5'h0;
                    smi_content_next = 16'h1200;
                end
            end
            neg: begin
                smi_init_next = 1'b0;
                if (smi_ready) begin
                    state_next = ready;
                    ready_next = 1'b1;
                end
            end
            ready: begin
                state_next = ready;
            end
        endcase
    end

    assign ethernet_reset = reset_reg;
    assign init = ready_reg;

endmodule
