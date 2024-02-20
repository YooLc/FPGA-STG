`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/05 23:45:57
// Design Name: 
// Module Name: top
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


module game_module (
    input wire clk,
    input wire rstn,
    input wire frame_rst,
    input wire [18:0] buf_addr,
    input wire [7:0] keyboard_data,
    output wire [15:0] frame_cnt,
    output wire [11:0] buf_data,
    output wire started,
    output wire crash,
    output wire crashed,
    output wire game_rdy,
    output wire [3:0] life_cnt
);

    localparam MAX_LIFE = 8;
    localparam KEY_ENTER = 3'd7;

    reg [15:0] frame_cnt_reg = 16'd0;
    reg ready = 1'b0;
    reg [3:0] life_cnt_reg = MAX_LIFE;
    reg [1:0] crash_reg = 2'b00;

    wire render_ready;
    assign game_rdy = ready;
    assign frame_cnt = frame_cnt_reg;

    // 游戏开始判断
    reg started_reg = 1'b0;
    assign started = started_reg;
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            started_reg <= 1'b0;
        end else if (keyboard_data[KEY_ENTER] == 1'b1) begin // 按回车键开始
            started_reg <= 1'b1;
        end else begin
            started_reg <= started_reg;
        end
    end

    // 游戏结束判断
    assign life_cnt = life_cnt_reg;
    assign crashed = (life_cnt_reg == 4'd0) ? 1'b1 : 1'b0;

    // 帧计数
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            frame_cnt_reg <= 16'd0;
        end else if (frame_rst && started && !crashed) begin
            frame_cnt_reg <= frame_cnt_reg + 1'd1;
        end else begin
            frame_cnt_reg <= frame_cnt_reg;
        end
    end

    // 游戏模块初始化判断
    always @ (posedge clk or negedge rstn) begin
        if (~rstn) begin
            ready <= 1'b0;
        end else if (frame_rst) begin
            ready <= 1'b0;
        end else if (render_ready) begin
            ready <= 1'b1;
        end else begin
            ready <= ready;
        end
    end

    // 碰撞判断，减少残机数量
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            crash_reg <= 2'b00;
        end else begin
            crash_reg <= {crash_reg[0], crash};
        end
    end
    always @ (posedge clk or negedge rstn) begin
		if (!rstn) begin
			life_cnt_reg <= MAX_LIFE;
		end else if (crash_reg == 2'b01 && life_cnt_reg > 4'd0) begin // 只检测 crash 变化
			life_cnt_reg <= life_cnt_reg - 1'd1;
		end else begin
			life_cnt_reg <= life_cnt_reg;
		end
	end

    wire [87:0] script_data, object_data;
    wire script_wren;
    wire object_rden, object_empty;
    script scripter(
        .clk(clk),
        .rstn(rstn),
        .frame_cnt(frame_cnt_reg),
        .obj_req_wren(script_wren),
        .obj_request(script_data)
    );
    object_requests requests(
        .clk(clk),
        .din(script_data),
        .wr_en(script_wren),
        .full(),
        .almost_full(),
        .dout(object_data),
        .rd_en(object_rden),
        .empty(object_empty)
    );

    // 玩家逻辑处理
    wire [39:0] player_data;
    wire [15:0] player_x = player_data[31 -: 16];
    wire [15:0] player_y = player_data[15 -: 16];
    wire player_mode; // 是否为低速模式
    wire [7:0] masked_data = (!crashed ? keyboard_data : 8'd0);
    player Reimu (
        .clk(clk),
        .rstn(rstn),
        .frame_rst(frame_rst),
        .ps2_data(masked_data),
        .render_data(player_data),
        .low_mode(player_mode)
    );

    wire render_full, render_rden, render_empty;
    wire engine_wren;
    wire [39:0] engine_data, render_data;
    engine game_engine(
        .clk(clk),
        .rstn(rstn),
        .frame_rst(frame_rst),
        .ps2_data(keyboard_data),
        .started(started),
        .req_empty(object_empty),
        .req_data(object_data),
        .req_rden(object_rden),
        .render_full(render_full),
        .render_data(engine_data),
        .render_wren(engine_wren),
        .crashed(crashed),
        .player_data(player_data),
        .player_mode(player_mode)
    );
    render_requests render_req(
        .clk(clk),
        .wr_en(engine_wren),
        .din(engine_data),
        .full(),
        .almost_full(render_full),
        .rd_en(render_rden),
        .dout(render_data),
        .empty(render_empty)
    );

    wire [11:0] buffer_data;
    wire [18:0] buffer_addr;
    wire buffer_wea;

    render renderer(
        .clk(clk),
        .rstn(rstn),
        .frame_rst(frame_rst),
        .req_data(render_data),
        .req_empty(render_empty),
        .req_rden(render_rden),
        .buffer_addr(buffer_addr),
        .buffer_wea(buffer_wea),
        .buffer_data(buffer_data),
        .ready(render_ready),
        .crash(crash),
        .player_x(player_x),
        .player_y(player_y)
    );
    frame_buffer buffer(
        .addra(buffer_addr),
        .clka(clk),
        .dina(buffer_data),
        .wea(buffer_wea),
        .addrb(buf_addr),
        .clkb(clk),
        .doutb(buf_data)
    );
    
endmodule
