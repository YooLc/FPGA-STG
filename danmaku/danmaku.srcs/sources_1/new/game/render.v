`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/05 23:45:57
// Design Name: 
// Module Name: render
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


module render (
    input wire clk,
    input wire rstn,
    input wire frame_rst,

    // 处理请求 FIFO
    input wire [39:0] req_data,
    input wire req_empty,
    output reg req_rden,

    // 处理帧缓冲
    output reg [18:0] buffer_addr,
    output wire buffer_wea,
    output wire [11:0] buffer_data,
    output wire ready,

    // 处理碰撞逻辑
    output wire crash,
    input wire [15:0] player_x,
    input wire [15:0] player_y
    );

    localparam RESET   = 6'b000001;
    localparam IDLE    = 6'b000010;
    localparam CLEAR   = 6'b000100;
    localparam REQUEST = 6'b001000;
    localparam RENDER  = 6'b010000;
    localparam WRITE   = 6'b100000;

    localparam WIDTH  = 17'd800;
    localparam HEIGHT = 17'd600;
    localparam RES_WIDTH = 17'd512;

    reg [5:0] state = RESET;
    reg rendered = 1'b0;
    assign ready = rendered;

    // 游戏资源 ROM
    reg [16:0] res_addr = 17'd0;
    wire [11:0] res_data;
    resource_rom resources(
        .clka(clk),
        .addra(res_addr),
        .douta(res_data)
    );

    // 游戏资源描述 ROM
    reg [7:0] res_id = 8'd0;
    wire [63:0] res_desc;
    wire [15:0] res_x, res_y, res_w, res_h;
    resource_desc descriptions(
        .a(res_id),
        .spo(res_desc)
    );
    assign {res_x, res_y, res_w, res_h} = res_desc;

    // 背景素材 ROM
    reg [11:0] col = 12'd0;
    reg [11:0] row = 12'd0;
    wire [14:0] bg_addr = row[11:2] * 15'd200 + col[11:2];
    wire [11:0] bg_color;
    background_rom background (
        .a(bg_addr),
        .spo(bg_color)
    );

    // BRAM 交互
    reg [15:0] pos_x = 16'd0, pos_y = 16'd0;
    reg [15:0] cur_x0 = 16'd0, cur_x1 = 16'd0, cur_x2 = 16'd0;
    reg [15:0] cur_y0 = 16'd0, cur_y1 = 16'd0, cur_y2 = 16'd0;

    reg [16:0] offsetA = 17'd0;
    reg [18:0] offsetB = 19'd0;
    // assign offsetA = (res_y + cur_y0) * RES_WIDTH + (res_x + cur_x0);
    // assign offsetB = (pos_y + cur_y1) *     WIDTH + (pos_x + cur_x1);
    // RGB -> BGR
    assign buffer_data = (state == CLEAR) ? bg_color : res_data;
    // assign buffer_data = {cnt[3:0], cnt[7:4], cnt[11:8]};
    assign buffer_wea = (state == CLEAR) ? 1'b1 : ((state == RENDER) ? |res_data : 1'b0);
    //assign buffer_wea = (state == CLEAR) ? 1'b1 : ((state == RENDER) ? 1'b1 : 1'b0);

    localparam [18:0] MAX_ADDR = 19'd800 * 19'd600 - 19'd1;

    localparam CRASH_DIST = 16; // r <= 4px

    // 碰撞检测
    wire [15:0] center_xp, center_yp;
    wire [15:0] center_xo, center_yo;
    // 玩家中心
    assign center_xp = player_x + 16'd16;
    assign center_yp = player_y + 16'd24;
    // 子弹中心
    assign center_xo = pos_x + res_w[15:1];
    assign center_yo = pos_y + res_h[15:1];

    reg crash_reg = 1'b0;
    wire [31:0] dist;
    assign crash = crash_reg;
    assign dist = (center_xp - center_xo) * (center_xp - center_xo) + (center_yp - center_yo) * (center_yp - center_yo);

    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= RESET;
            crash_reg <= 1'b0;
        end else begin
            case (state)
                RESET: begin
                    state <= IDLE;
                    cur_x0 <= 16'd0;
                    cur_x1 <= 16'd0;
                    cur_x2 <= 16'd0;
                    cur_y0 <= 16'd0;
                    cur_y1 <= 16'd0;
                    cur_y2 <= 16'd0;
                    pos_x <= 16'd0;
                    pos_y <= 16'd0;
                    res_addr <= 17'd0;
                    res_id <= 8'd0;
                    buffer_addr <= 19'd0;
                    // buffer_wea <= 1'b0;
                    req_rden <= 1'b0;
                    rendered <= 1'b0;
                    offsetA <= 17'd0;
                    offsetB <= 19'd0;
                    crash_reg <= 1'b0;
                end
                IDLE: begin
                    if (frame_rst) begin
                        // state <= REQUEST;
                        state <= CLEAR;
                        col <= 12'd0;
                        row <= 12'd0;
                        buffer_addr <= 19'd0;
                    end else begin
                        state <= state;
                    end
                    rendered <= 1'b0;
                    crash_reg <= 1'b0;
                end
                CLEAR: begin
                    if (col == 12'd799) begin
                        if (row == 12'd599) begin
                            buffer_addr <= 19'd0;
                            state <= REQUEST;
                            col <= 12'd0;
                            row <= 12'd0;
                        end else begin
                            buffer_addr <= buffer_addr + 19'd1;
                            state <= state;
                            col <= 12'd0;
                            row <= row + 12'd1;
                        end
                    end else begin
                        buffer_addr <= buffer_addr + 19'd1;
                        state <= state;
                        col <= col + 12'd1;
                        row <= row;
                    end

                    crash_reg <= 1'b0;
                end
                REQUEST: begin
                    if (!req_empty) begin
                        {res_id, pos_x, pos_y} <= req_data;
                        req_rden <= 1'b1;
                        cur_x0 <= 16'd0;
                        cur_x1 <= 16'd0;
                        cur_x2 <= 16'd0;
                        cur_y0 <= 16'd0;
                        cur_y1 <= 16'd0;
                        cur_y2 <= 16'd0;
                        state <= RENDER;

                        buffer_addr <= 19'd0;
                    end else begin
                        state <= IDLE;
                        rendered <= 1'b1;
                    end

                    crash_reg <= 1'b0;
                end
                RENDER: begin
                    req_rden <= 1'b0;
                    // 同步的, x y 坐标打两拍
                    if (cur_x0 == res_w  - 16'd1 || cur_x0 == 16'hFFF) begin
                        if (cur_y0 == res_h - 16'd1 || cur_y0 == 16'hFFF) begin
                            cur_x0 <= 16'hFFF;
                            cur_y0 <= 16'hFFF;
                        end else begin
                            cur_x0 <= 16'd0;
                            cur_y0 <= cur_y0 + 16'd1;
                        end
                    end else begin
                        cur_x0 <= cur_x0 + 16'd1;
                        cur_y0 <= cur_y0;
                    end

                    // 移位寄存
                    cur_x1 <= cur_x0;
                    cur_x2 <= cur_x1;
                    cur_y1 <= cur_y0;
                    cur_y2 <= cur_y1;
                    offsetA <= (res_y + cur_y0) * RES_WIDTH + (res_x + cur_x0);
                    offsetB <= (pos_y + cur_y1) *     WIDTH + (pos_x + cur_x1);

                    // 慢一个周期
                    res_addr <= offsetA;

                    // 慢两个周期
                    buffer_addr <= offsetB;

                    if (cur_x2 == 16'hFFF && cur_y2 == 16'hFFF) begin
                        state <= REQUEST;
                        // buffer_wea <= 1'b0;
                    end else begin
                        state <= state;
                        // buffer_wea <= buffer_wea;
                    end

                    crash_reg <= (dist > 0 && dist <= CRASH_DIST) ? 1'b1 : 1'b0;
                end
                default: begin
                    state <= RESET;
                end
            endcase
        end
    end
endmodule
