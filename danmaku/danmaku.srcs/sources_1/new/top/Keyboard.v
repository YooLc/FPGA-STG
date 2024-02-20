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


module Keyboard (
    input wire clk,
    input wire rstn,
    input wire ps2_clk,
    input wire ps2_data,
    output wire [7:0] status
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

    // 上下左右键 键盘码
    localparam ARROW_UP_CODE = 8'h75;
    localparam ARROW_DOWN_CODE = 8'h72;
    localparam ARROW_LEFT_CODE = 8'h6B;
    localparam ARROW_RIGHT_CODE = 8'h74;
    // 上下左右键 数组下标
    localparam ARROW_UP = 4'd0;
    localparam ARROW_DOWN = 4'd1;
    localparam ARROW_LEFT = 4'd2;
    localparam ARROW_RIGHT = 4'd3;

    // 正常按键 键盘码
    localparam KEY_SHIFT_CODE = 8'h12;
    localparam KEY_Z_CODE = 8'h1A;
    localparam KEY_X_CODE = 8'h22;
    localparam KEY_ENTER_CODE = 8'h5A;
    // 正常按键 数组下标
    localparam KEY_SHIFT = 4'd4;
    localparam KEY_Z = 4'd5;
    localparam KEY_X = 4'd6;
    localparam KEY_ENTER = 4'd7;

    reg [2:0] state = STATE_RESET;
    reg [7:0] key_pressed = 8'h00;
    assign status = key_pressed;

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
                STATE_READ: begin // 读取键盘码
                    if (rdy) begin
                        case (data) // 正常键通码
                            KEY_SHIFT_CODE: key_pressed[KEY_SHIFT] <= 1'b1;
                            KEY_Z_CODE: key_pressed[KEY_Z] <= 1'b1;
                            KEY_X_CODE: key_pressed[KEY_X] <= 1'b1;
                            KEY_ENTER_CODE: key_pressed[KEY_ENTER] <= 1'b1;
                            default: key_pressed <= key_pressed;
                        endcase
                        case (data) // 小键盘通码 / 正常键断码
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
                STATE_BREAK: begin // 处理正常键断码
                    if (rdy) begin
                        case (data)
                            KEY_SHIFT_CODE: key_pressed[KEY_SHIFT] <= 1'b0;
                            KEY_Z_CODE: key_pressed[KEY_Z] <= 1'b0;
                            KEY_X_CODE: key_pressed[KEY_X] <= 1'b0;
                            KEY_ENTER_CODE: key_pressed[KEY_ENTER] <= 1'b0;
                            default: key_pressed <= key_pressed;
                        endcase
                        state <= STATE_READ;
                    end else begin
                        rdn <= rdn;
                        state <= state;
                        key_pressed <= key_pressed;
                    end
                end
                STATE_NMPAD: begin // 处理小键盘按键
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
                STATE_NMPAD_BREAK: begin // 处理小键盘断码
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

// 参考: https://nju-projectn.github.io/dlco-lecture-note/exp/07.html
module ps2_drive(input wire clk,      // 模块时钟
                 input wire clrn,     // 复位信号
                 input wire ps2_clk,  // PS2 时钟
                 input wire ps2_data, // PS2 数据 (来自键盘)
                 input wire rdn,      // 读使能 (来自上层模块)
			     output wire [7:0] data, // 数据 (PS2键盘码)
			     output wire ready,      // 数据有效信号
                 output reg overflow);  // FIFO 满信号
	reg [3:0] count; 		// count ps2_data bits, internal signal, for test
	reg [9:0] buffer; 		// ps2_data bits
	reg [7:0] fifo[7:0]; 	// data fifo
	reg [2:0] w_ptr, r_ptr;	// fifo write and read pointers
	reg [2:0] ps2_clk_sync;

	always @ (posedge clk) begin
		ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk};
	end

	wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
	always @ (posedge clk) begin
		if (clrn == 0) begin
		    count <= 0;
		    w_ptr <= 0;
		    r_ptr <= 0;
		    overflow <= 0;
	    end else if (sampling) begin
		    if (count == 4'd10) begin
			    if ((buffer[0] == 0) &&	 // start bit
			        (ps2_data) && 		 // stop bit
			        (^buffer[9:1])) begin 	    // odd prity：SWORD用偶校验
			       fifo[w_ptr] <= buffer[8:1]; 	// keyboard scan code
			       w_ptr <= w_ptr + 3'b1;
			       overflow <= overflow |  (r_ptr == (w_ptr + 3'b1)); // FIFO 满
		       	end	
		      	count <= 0; // for next
		    end else begin // 采样下一位信息
		       	buffer[count] <= ps2_data;	 // store ps2_data
		       	count <= count + 3'b1;	     // count ps2_data bits
		    end
	    end
        if (!rdn && ready) begin // 读取数据
            r_ptr <= r_ptr + 3'b1; // 读指针自增
            overflow <= 0;
        end
    end

    assign ready = (w_ptr != r_ptr);
    assign data = fifo[r_ptr];
endmodule
