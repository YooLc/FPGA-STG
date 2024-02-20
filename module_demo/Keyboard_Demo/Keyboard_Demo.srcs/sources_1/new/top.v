`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/24 20:03:47
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


module top(
    input wire clk,
    input wire rstn,
    input wire ps2_clk,
    input wire ps2_data,
    output wire [7:0] LED
    );

    reg rdn = 1'b1;
    wire rdy, overflow;
    wire [7:0] data;
    ps2_drive keyboard(.clk(clk),.clrn(rstn), .ps2_clk(ps2_clk), .ps2_data(ps2_data),
                       .rdn(rdn), .data(data), .ready(rdy), .overflow(overflow));
    
    localparam STATE_RESET = 3'b000; // 复位
    localparam STATE_READ  = 3'b001; // 读取键盘码
    localparam STATE_BREAK = 3'b010; // 断码 8'hF0
    localparam STATE_NMPAD = 3'b011; // 小键盘区域按键 8'hE0
    localparam STATE_NMPAD_BREAK = 3'b100; // 小键盘区域断码 8'hE0F0

    localparam BREAK_CODE = 8'hF0;
    localparam NMPAD_CODE = 8'hE0;

    localparam ARROW_UP_CODE = 8'h75;
    localparam ARROW_DOWN_CODE = 8'h72;
    localparam ARROW_LEFT_CODE = 8'h6B;
    localparam ARROW_RIGHT_CODE = 8'h74;
    localparam ARROW_UP = 4'd0;
    localparam ARROW_DOWN = 4'd1;
    localparam ARROW_LEFT = 4'd2;
    localparam ARROW_RIGHT = 4'd3;

    localparam KEY_A_CODE = 8'h1C;
    localparam KEY_S_CODE = 8'h1B;
    localparam KEY_D_CODE = 8'h23;
    localparam KEY_F_CODE = 8'h2B;
    localparam KEY_A = 4'd4;
    localparam KEY_S = 4'd5;
    localparam KEY_D = 4'd6;
    localparam KEY_F = 4'd7;

    reg [2:0] state = STATE_RESET;
    reg [7:0] key_pressed = 8'h00;
    assign LED = key_pressed;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rdn <= 1'b1;
            state <= STATE_RESET;
            key_pressed <= 8'h00;
        end else begin
            case (state)
                STATE_RESET: begin
                    rdn <= 1'b0;
                    state <= STATE_READ;
                    key_pressed <= key_pressed;
                end
                STATE_READ: begin
                    if (rdy) begin
                        case (data)
                            KEY_A_CODE: key_pressed[KEY_A] <= 1'b1;
                            KEY_S_CODE: key_pressed[KEY_S] <= 1'b1;
                            KEY_D_CODE: key_pressed[KEY_D] <= 1'b1;
                            KEY_F_CODE: key_pressed[KEY_F] <= 1'b1;
                            default: key_pressed <= key_pressed;
                        endcase
                        case (data)
                            BREAK_CODE: state <= STATE_BREAK;
                            NMPAD_CODE: state <= STATE_NMPAD;
                            default: state <= state;
                        endcase
                    end else begin
                        rdn <= rdn;
                        state <= state;
                        key_pressed <= key_pressed;
                    end
                end
                STATE_BREAK: begin
                    if (rdy) begin
                        case (data)
                            KEY_A_CODE: key_pressed[KEY_A] <= 1'b0;
                            KEY_S_CODE: key_pressed[KEY_S] <= 1'b0;
                            KEY_D_CODE: key_pressed[KEY_D] <= 1'b0;
                            KEY_F_CODE: key_pressed[KEY_F] <= 1'b0;
                            default: key_pressed <= key_pressed;
                        endcase
                        state <= STATE_READ;
                    end else begin
                        rdn <= rdn;
                        state <= state;
                        key_pressed <= key_pressed;
                    end
                end
                STATE_NMPAD: begin
                    if (rdy) begin
                        case (data)
                            ARROW_UP_CODE:    key_pressed[ARROW_UP]    <= 1'b1;
                            ARROW_DOWN_CODE:  key_pressed[ARROW_DOWN]  <= 1'b1;
                            ARROW_LEFT_CODE:  key_pressed[ARROW_LEFT]  <= 1'b1;
                            ARROW_RIGHT_CODE: key_pressed[ARROW_RIGHT] <= 1'b1;
                            default: key_pressed <= key_pressed;
                        endcase
                        case (data)
                            BREAK_CODE: state <= STATE_NMPAD_BREAK;
                            default: state <= STATE_READ;
                        endcase
                    end else begin
                        rdn <= rdn;
                        state <= state;
                        key_pressed <= key_pressed;
                    end
                end
                STATE_NMPAD_BREAK: begin
                    if (rdy) begin
                        case (data)
                            ARROW_UP_CODE:    key_pressed[ARROW_UP]    <= 1'b0;
                            ARROW_DOWN_CODE:  key_pressed[ARROW_DOWN]  <= 1'b0;
                            ARROW_LEFT_CODE:  key_pressed[ARROW_LEFT]  <= 1'b0;
                            ARROW_RIGHT_CODE: key_pressed[ARROW_RIGHT] <= 1'b0;
                            default: key_pressed <= key_pressed;
                        endcase
                        state <= STATE_READ;
                    end else begin
                        rdn <= rdn;
                        state <= state;
                        key_pressed <= key_pressed;
                    end
                end
                default: begin
                    state <= STATE_RESET;
                end
            endcase
        end
    end

endmodule
