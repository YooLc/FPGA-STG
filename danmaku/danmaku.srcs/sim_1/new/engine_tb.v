`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/07 18:14:47
// Design Name: 
// Module Name: engine_tb
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


module engine_tb(

    );

    reg clk, frame_rst;
    reg [7:0] ps2_data;
    reg req_empty;
    reg [87:0] req_data;
    wire req_rden;
    reg render_full;
    wire [39:0] render_data;
    wire render_wren;
    engine game_engine(
        .clk(clk),
        .rstn(1'b1),
        .frame_rst(frame_rst),
        .ps2_data(ps2_data),
        .req_empty(req_empty),
        .req_data(req_data),
        .req_rden(req_rden),
        .render_full(render_full),
        .render_data(render_data),
        .render_wren(render_wren)
    );

    initial begin
        clk = 1;
        frame_rst = 0;
        req_empty = 0;
        req_data = {16'd0, 16'd0, 16'd32, 16'd32, 8'd32, 8'd32, 8'd0};
        ps2_data = 0;
        #50 frame_rst = 1;
        #10 frame_rst = 0;

        #50 req_empty = 1;

        #50 frame_rst = 1;
        req_empty = 0;
        #10 frame_rst = 0;
        #100 req_empty = 1;

        #60 frame_rst = 1;
        #10 frame_rst = 0;
    end

    always #5 clk = ~clk;
endmodule
