`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/15 17:40:00
// Design Name: 
// Module Name: player
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


module player(
    input wire clk,
    input wire rstn,
    input wire frame_rst,
    input wire [7:0] ps2_data,

    output wire low_mode,
    output wire [39:0] render_data
    );

    localparam RESET = 2'b00;
    localparam STAY  = 2'b01; // 静止或上下移动
    localparam TRANS = 2'b10; // 左右转身过渡
    localparam MOVE  = 2'b11; // 转身

    localparam V_LOW  = 8'd2;
    localparam V_HIGH = 8'd5;

    // 键盘
    localparam ARROW_UP = 4'd0;
    localparam ARROW_DOWN = 4'd1;
    localparam ARROW_LEFT = 4'd2;
    localparam ARROW_RIGHT = 4'd3;
    localparam KEY_SHIFT = 4'd4;

    reg [1:0] state = 2'd0;

    // 在刷新一帧时采样键盘数据
    reg [7:0] keyboard_reg = 8'd0;
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            keyboard_reg <= 8'd0;
        end else if (frame_rst) begin
            keyboard_reg <= ps2_data;
        end else begin
            keyboard_reg <= keyboard_reg;
        end
    end

    // 灵梦的位置与当前使用的素材
    localparam RES_STAY = 8'd0;
    localparam RES_LEFT_TRANS = 8'd8;
    localparam RES_RIGHT_TRANS = 8'd12;
    localparam RES_LEFT = 8'd16;
    localparam RES_RIGHT = 8'd20;

    reg [4:0] frame_cnt = 5'd0;
    reg [7:0] cur_res_id = 8'd0;
    reg [15:0] pos_x = 16'd400, pos_y = 16'd500;
    assign render_data = {cur_res_id, pos_x, pos_y};

    // 一些状态相关的值
    wire [7:0] velocity;
    assign velocity = keyboard_reg[KEY_SHIFT] ? V_LOW : V_HIGH;
    assign low_mode = keyboard_reg[KEY_SHIFT] ? 1'b1 : 1'b0;

    // 根据采样操作更新位置
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            pos_x <= 16'd400;
            pos_y <= 16'd500;
        end else if (frame_rst) begin
            if (keyboard_reg[ARROW_LEFT] ^ keyboard_reg[ARROW_RIGHT]) begin
                if (keyboard_reg[ARROW_LEFT]) begin
                    pos_x <= pos_x - velocity;
                end else begin
                    pos_x <= pos_x + velocity;
                end
            end else begin
                pos_x <= pos_x;
            end

            if (keyboard_reg[ARROW_UP] ^ keyboard_reg[ARROW_DOWN]) begin
                if (keyboard_reg[ARROW_UP]) begin
                    pos_y <= pos_y - velocity;
                end else begin
                    pos_y <= pos_y + velocity;
                end
            end else begin
                pos_y <= pos_y;
            end
        end else begin
            pos_x <= pos_x;
            pos_y <= pos_y;
        end
    end

    wire moving;
    assign moving = (keyboard_reg[ARROW_LEFT] ^ keyboard_reg[ARROW_RIGHT]);

    // 确定绘制的 id
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= RESET;
        end else begin
            case (state)
                RESET: begin
                    state <= STAY;
                    frame_cnt <= 5'd0;
                    cur_res_id <= 8'd0;
                end
                STAY: begin
                    if (frame_rst) begin
                        if (moving) begin
                            state <= TRANS;
                            frame_cnt <= 5'd0;
                            cur_res_id <= keyboard_reg[ARROW_LEFT] ? RES_LEFT_TRANS : RES_RIGHT_TRANS;
                        end else begin
                            state <= state;
                            frame_cnt <= frame_cnt + 5'd1;
                            cur_res_id <= RES_STAY + frame_cnt[4:2];
                        end
                    end else begin
                        state <= state;
                        frame_cnt <= frame_cnt;
                        cur_res_id <= cur_res_id;
                    end
                end
                TRANS: begin
                    if (frame_rst) begin
                        if (frame_cnt == 4'd3) begin
                            state <= MOVE;
                            frame_cnt <= 4'd0;
                            cur_res_id <= keyboard_reg[ARROW_LEFT] ? RES_LEFT : RES_RIGHT;
                        end else begin
                            state <= state;
                            frame_cnt <= frame_cnt + 5'd1;
                            cur_res_id <= (keyboard_reg[ARROW_LEFT] ? RES_LEFT_TRANS : RES_RIGHT_TRANS) + frame_cnt[3:2];
                        end
                    end else begin
                        state <= state;
                        frame_cnt <= frame_cnt;
                        cur_res_id <= cur_res_id;
                    end
                end
                MOVE: begin
                    if (frame_rst) begin
                        if (!moving) begin
                            state <= STAY;
                            frame_cnt <= 4'b0;
                            cur_res_id <= RES_STAY;
                        end else begin
                            state <= state;
                            frame_cnt <= frame_cnt + 4'd1;
                            cur_res_id <= (keyboard_reg[ARROW_LEFT] ? RES_LEFT : RES_RIGHT) + frame_cnt[3:2];
                        end
                    end else begin
                        state <= state;
                        frame_cnt <= frame_cnt;
                        cur_res_id <= cur_res_id;
                    end
                end
                default: begin
                    state <= RESET;
                end
            endcase
        end
    end

endmodule
