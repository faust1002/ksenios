module xilinx_dist_ram_16x4 (input wire [3:0] data_in,
        output wire [3:0] data_out,
        input wire [3:0] waddr,
        input wire [3:0] raddr,
        input wire we, wclk);

    RAM16X1D ram00 (.DPO(data_out[0]),  .SPO(), .A0(waddr[0]), .A1(waddr[1]), .A2(waddr[2]), .A3(waddr[3]), .D(data_in[0]),  .DPRA0(raddr[0]), .DPRA1(raddr[1]), .DPRA2(raddr[2]), .DPRA3(raddr[3]), .WCLK(wclk), .WE(we));

    RAM16X1D ram01 (.DPO(data_out[1]),  .SPO(), .A0(waddr[0]), .A1(waddr[1]), .A2(waddr[2]), .A3(waddr[3]), .D(data_in[1]),  .DPRA0(raddr[0]), .DPRA1(raddr[1]), .DPRA2(raddr[2]), .DPRA3(raddr[3]), .WCLK(wclk), .WE(we));
    
    RAM16X1D ram02 (.DPO(data_out[2]),  .SPO(), .A0(waddr[0]), .A1(waddr[1]), .A2(waddr[2]), .A3(waddr[3]), .D(data_in[2]),  .DPRA0(raddr[0]), .DPRA1(raddr[1]), .DPRA2(raddr[2]), .DPRA3(raddr[3]), .WCLK(wclk), .WE(we));
    
    RAM16X1D ram03 (.DPO(data_out[3]),  .SPO(), .A0(waddr[0]), .A1(waddr[1]), .A2(waddr[2]), .A3(waddr[3]), .D(data_in[3]),  .DPRA0(raddr[0]), .DPRA1(raddr[1]), .DPRA2(raddr[2]), .DPRA3(raddr[3]), .WCLK(wclk), .WE(we));

endmodule
