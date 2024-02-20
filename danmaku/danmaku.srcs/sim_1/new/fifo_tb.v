`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/29 19:02:39
// Design Name: 
// Module Name: fifo_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_tb(

    );

    reg clk_200;
    reg clk_100;
    reg clk_25;
    reg wr_en;
    reg rd_en;
    reg [15:0] wr_din;
    reg frame_rst;
    wire [127:0] dout;
    reg app_wdf_wren;
    reg rst = 1'b0;
    wire [6:0] wbuf_rcount;
    wire [9:0] wbuf_wcount;

    always #2.5 clk_200 = ~clk_200;
    always #5 clk_100 = ~clk_100;
    always #20 clk_25 = ~clk_25;

    always @(posedge clk_100) begin
        wr_din = wr_din + 1;
    end

    initial begin
        clk_200 = 0;
        clk_100 = 0;
        clk_25 = 0;
        wr_en = 0;
        rd_en = 0;
        wr_din = 0;
        frame_rst = 0;
        #500;
        wr_en = 1;
        #25;
        rd_en = 1;
    end
    
    fifo_generator_w wbuf(
        .rst(rst),
        .wr_clk(clk_100),
        .rd_clk(clk_200),

        // FIFO_WRITE
        .full(),
        .din(wr_din),
        .wr_en(wr_en),

        // FIFO_READ
        .empty(),
        .dout(dout),
        .rd_en(rd_en),

        .prog_full(wfull),
        .wr_rst_busy(wr_rst_busy),
        .rd_rst_busy(rd_rst_busy)
    );
endmodule
