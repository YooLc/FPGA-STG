`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/05 23:45:57
// Design Name: 
// Module Name: script
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


module script(
    input wire clk,
    input wire rstn,
    input wire [15:0] frame_cnt,
    output wire obj_req_wren,
    output wire [87:0] obj_request
);

    // 定义状态机状态编码
    localparam RESET = 1'b0;
    localparam WORK  = 1'b1;
    reg state = RESET;

    // 与 ROM 交互
    reg [11:0] addr = 12'd0;
    wire [103:0] item;
    wire [15:0] cur_frame;
    reg [15:0] frame = 16'd0, base_x = 16'd0, base_y = 16'd0, deg = 16'd0, rho = 16'd0;
    reg [7:0] vdeg = 8'd0, vrho = 8'd0, res_id = 8'd0;
    script_rom scripts(
        .a(addr),
        .spo(item)
    );

    // ROM 输出
    assign cur_frame = item[103 -: 16]; // 异步读取 - 当前帧
    always @ (posedge clk) begin // 打一拍转为同步
        {frame, base_x, base_y, deg, rho, vdeg, vrho, res_id} <= item;
    end

    // FIFO 输入与使能
    assign obj_request  = {base_x, base_y, deg, rho, vdeg, vrho, res_id};
    assign obj_req_wren = (frame == frame_cnt) ? 1'b1 : 1'b0;

    // 状态机
    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= RESET;
        end else begin
            case (state)
                RESET: begin
                    state <= WORK;
                    addr <= 12'd0;
                end
                WORK: begin
                    if (cur_frame == frame_cnt)
                        addr <= addr + 12'd1;
                    state <= state;
                end
                default: begin
                    state <= RESET;
                end
            endcase
        end
    end
endmodule
