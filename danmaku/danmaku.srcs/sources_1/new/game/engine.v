`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/05 23:45:57
// Design Name: 
// Module Name: engine
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


module engine(
    input wire clk,
    input wire rstn,
    input wire frame_rst,
    input wire [7:0] ps2_data,
    input wire started,

    input wire req_empty,
    input wire [87:0] req_data,
    output wire req_rden,

    input wire render_full,
    output reg [39:0] render_data,
    output reg render_wren,

    input wire crashed,
    input wire [39:0] player_data,
    input wire player_mode
);

    localparam RESET  = 3'b000;
    localparam IDLE   = 3'b001;
    localparam READY  = 3'b010;
    localparam PLAYER = 3'b011;
    localparam UPDATE = 3'b100;
    localparam ADD    = 3'b101;
    localparam START  = 3'b110;
    localparam CRASH  = 3'b111;

    localparam [7:0] LOW_RES_ID = 8'd24; // 低速模式判定点素材 ID
    localparam [7:0] START_RES_ID = 8'd103; // 开始界面素材 ID
    localparam [7:0] CRASH_RES_ID = 8'd104; // 结束界面素材 ID

    reg [2:0] state = RESET;

    // 游戏物体队列 FIFO
    reg pool_wren = 1'b0;
    reg [88:0] pool_din = 89'd0;
    wire pool_rden, pool_empty;
    wire [88:0] pool_dout;
    object_pool pool(
        .clk(clk),
        .full(),
        .din(pool_din),
        .wr_en(pool_wren),
        .empty(pool_empty),
        .dout(pool_dout),
        .rd_en(pool_rden)
    );

    // 物体参数连接到 FIFO 输出 (FWFT)
    wire [15:0] base_x, base_y;
    wire signed [15:0] rho, deg;
    wire [7:0] vdeg, vrho, res_id;
    wire id;
    assign {id, base_x, base_y, rho, deg, vrho, vdeg, res_id} = pool_dout;

    // 三角函数计算
    wire signed [15:0] sin_val, cos_val;
    sin_value sin(.a(deg), .spo(sin_val));
    cos_value cos(.a(deg), .spo(cos_val));

    // 下一次坐标计算
    wire signed [31:0] prod_x, prod_y;
    wire [16:0] result_x, result_y;
    wire [15:0] pos_x, pos_y;
    assign prod_x = rho * cos_val;
    assign prod_y = rho * sin_val;
    assign result_x = {1'b0, base_x} + prod_x[31 -: 17];
    assign result_y = {1'b0, base_y} + prod_y[31 -: 17];
    assign pos_x = result_x[15 -: 16];
    assign pos_y = result_y[15 -: 16];

    // 处理批次编号, 每处理一帧改变一次
    reg cur_id = 1'b1;

    // FIFO 使能
    assign req_rden  = (state == ADD) ? 1'b1 : 1'b0;
    assign pool_rden = (state == UPDATE && id != cur_id) ? 1'b1 : 1'b0;

    // 角度计算，取模
    wire [15:0] deg_sum;
    wire [15:0] new_deg;
    assign deg_sum = deg + vdeg;
    assign new_deg = (deg_sum >= 16'd360) ? deg_sum - 16'd360 : deg_sum;

    reg req_empty0 = 1'b0;
    reg player_render_state = 1'b0;

    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= RESET;
        end else begin
            case (state)
                RESET: begin
                    state <= IDLE;
                    render_data <= 40'd0;
                    render_wren <= 1'b0;
                    cur_id <= 1'b1;
                    req_empty0 <= 1'b0;
                    player_render_state <= 1'b0;
                end
                IDLE: begin // 空闲状态
                    if (frame_rst) begin // 接收到新一帧信号，进入准备状态
                        state <= READY;
                    end else begin
                        state <= IDLE;
                    end
                    render_wren <= 1'b0;
                    pool_wren <= 1'b0;
                end
                READY: begin
                    if (!started) begin // 游戏开始判断
                        state <= START;
                    end else if (!pool_empty) begin // 优先处理队列中的物体
                        state <= PLAYER;
                        cur_id <= ~cur_id;
                        player_render_state <= 1'b0;
                    end else if (!req_empty) begin // 添加新物体 - 在游戏结束后不再添加
                        if (!crashed) begin
                            state <= ADD;
                        end else begin
                            state <= CRASH;
                        end
                    end else if (crashed) begin // 结束画面
                        state <= CRASH;
                    end else begin
                        state <= state;
                    end
                    render_wren <= 1'b0;
                    pool_wren <= 1'b0;
                end
                PLAYER: begin
                    if (player_render_state == 1'b0) begin
                        render_data <= player_data;
                        render_wren <= 1;
                        state <= state;
                        player_render_state <= 1'b1;
                    end else begin
                        // 低速模式显示判定点
                        render_data <= {LOW_RES_ID, player_data[31 -: 16] - 16'd16, player_data[15 -: 16] - 16'd8};
                        render_wren <= player_mode;
                        state <= UPDATE;
                        player_render_state <= 1'b0;
                    end
                end
                UPDATE: begin
                    if (id == cur_id) begin
                        if (crashed) begin
                            state <= CRASH;
                        end else if (!req_empty) begin
                            state <= ADD;
                        end else begin
                            state <= IDLE;
                        end
                        render_wren <= 1'b0;
                        render_data <= 40'd0;

                        pool_wren <= 1'b0;
                        pool_din <= 89'd0;
                    end else begin
                        // 排除出界物体
                        if (pos_x >= 16'd800 || pos_y >= 16'd600) begin
                            render_wren <= 1'b0;
                            pool_wren <= 1'b0;
                        end else begin
                            render_wren <= 1'b1;
                            pool_wren <= 1'b1;
                        end

                        // 更新物体数据
                        if (!crashed) begin
                            pool_din <= {cur_id, base_x, base_y, rho + vrho, new_deg, vrho, vdeg, res_id};
                        end else begin
                            pool_din <= {cur_id, base_x, base_y, rho, deg, 8'd0, 8'd0, res_id};
                        end

                        // 更新渲染请求
                        render_data <= {res_id, pos_x, pos_y};
                    end
                end
                ADD: begin
                    if (req_empty0) begin
                        state <= IDLE;
                        pool_wren <= 1'b0;
                        pool_din <= 89'd0;

                        // render_data <= 40'd0;
                        // render_wren <= 1'b0;
                    end else begin
                        pool_wren <= 1'b1;
                        pool_din <= {cur_id, req_data};

                        // render_data <= {res_id, req_data[15:0], req_data[31:16]};
                        // render_wren <= 1'b1;
                    end
                    req_empty0 <= req_empty;
                end
                // 游戏开始与结束画面
                START: begin
                    state <= IDLE;
                    render_data <= {START_RES_ID, 16'd272, 16'd208};
                    render_wren <= 1'b1;
                end
                CRASH: begin
                    state <= IDLE;
                    render_data <= {CRASH_RES_ID, 16'd328, 16'd264};
                    render_wren <= 1'b1;
                end
                default: begin
                    state <= RESET;
                end
            endcase
        end
    end
endmodule
