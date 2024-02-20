`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/16 16:53:01
// Design Name: 
// Module Name: audio
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


module Audio (
    input wire sys_clk,
    input wire pwm_clk,
    input wire rstn,
    
    // 蜂鸣器
    input wire buzzer_en,
    output wire buzzer,

    // 耳机接口
    input wire AUD_EN,
    output wire AUD_PWM,
    output wire AUD_SD,

    // 下面是与游戏相关的接口
    input wire started,  // 开始界面
    input wire crash,  // 单次死亡
    input wire crashed // 游戏结束
    );

    // 状态机逻辑
    localparam RESET = 4'b0001;
    localparam START = 4'b0010;
    localparam PLAY  = 4'b0100;
    localparam CRASH = 4'b1000;

    reg [3:0] state = RESET;

    // 对 PWM 时钟进行分频，得到与音频采样率匹配的频率
    reg [31:0] clkdiv = 0;
    always @ (posedge pwm_clk) begin
        clkdiv <= clkdiv + 1;
    end
    reg [31:0] clkdiv2 = 0;
    always @ (posedge sys_clk) begin
        clkdiv2 <= clkdiv2 + 1;
    end

    // 音频采样点个数
    localparam START_NOTE_CNT = 218227;
    localparam END_NOTE_CNT = 84167;

    reg [17:0] cur_note = 18'd0;
    wire [7:0] cur_pwm, start_pwm, end_pwm;
    reg pwm = 1'b0;
    reg [7:0] cnt = 8'd0; // 采样值域: uint8_t

    StartMusic start_music (
        .addra(cur_note),
        .clka(clkdiv[10]),
        .douta(start_pwm)
    );
    EndMusic end_music (
        .addra(cur_note[16:0]),
        .clka(clkdiv[10]),
        .douta(end_pwm)
    );
    assign cur_pwm = (state == START) ? start_pwm : end_pwm; // 根据状态切换曲目

    // 按照采样频率切换采样点
    always @ (posedge clkdiv[10] or negedge rstn) begin
        if (!rstn) begin
            cur_note <= 18'd0;
        end else if (state == START && cur_note == START_NOTE_CNT) begin
            cur_note <= 18'd0;
        end else if (state == CRASH && cur_note == END_NOTE_CNT) begin
            cur_note <= 18'd0;
        end else begin
            cur_note <= cur_note + 18'd1;
        end
    end

    // 根据采样点对应值进行占空比调整
    always @(posedge clkdiv2[1]) begin
        if (cnt < cur_pwm)
            pwm <= 1'b1;
        else
            pwm <= 1'b0;
        cnt <= cnt + 8'd1;
    end

    // 将死亡信号延长一段时间
    reg crash_reg = 1'b0;
    reg [18:0] counter = 18'd0;
    always @ (posedge sys_clk) begin
        if (crash) begin
            crash_reg <= 1'b1;
            counter <= 18'd0;
        end else if (counter == 18'h3FFFF) begin
            crash_reg <= 1'b0;
            counter <= 18'd0;
        end else begin
            crash_reg <= crash_reg;
            counter <= counter + 18'd1;
        end
    end

    wire out = (state == PLAY) ? (crash_reg ? clkdiv[11] : 1'b0) : pwm;
    assign buzzer = out & buzzer_en;
    assign AUD_PWM = out;
    assign AUD_SD = AUD_EN;

    always @ (posedge sys_clk or negedge rstn) begin
        if (!rstn) begin
            state <= RESET;
        end else begin
            case (state)
                RESET: begin
                    state <= START;
                end
                START: begin
                    if (started) begin
                        state <= PLAY;
                    end else begin
                        state <= state;
                    end
                end
                PLAY: begin
                    if (crashed) begin
                        state <= CRASH;
                    end else begin
                        state <= state;
                    end
                end
                CRASH: begin
                    state <= state;
                end
                default: begin
                    state <= RESET;
                end
            endcase
        end
    end

endmodule