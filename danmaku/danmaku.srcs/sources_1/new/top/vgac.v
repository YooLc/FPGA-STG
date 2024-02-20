`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Companrow_addr: 
// Engineer: 
// 
// Create Date:    00:27:04 01/02/2016 
// Design Name: 
// Module Name:    vgac 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vgac #(
	parameter width  = 640,     // 输出图像宽度
	parameter height = 480      // 输出图像高度
	)(
	input wire         vga_clk, // VGA 时钟, 需与图像分辨率对应
	input wire         clrn,
	input wire [11:0]  d_in,    // 颜色数据输入 RGB444, 顺序为 bbbb_gggg_rrrr

	output wire [10:0] col_addr,
	output wire [10:0] row_addr,
	output wire  	   hs,      // h_sync
	output wire 	   vs,      // v_sync
	output wire [3:0]  r,       // RGB444 色彩输出
	output wire [3:0]  g,
	output wire [3:0]  b
	);

	generate // generate块，使用对应分辨率的时序参数，并调用底层模块
		if (width == 800 && height == 600) begin       // 800x600 @ 60Hz  40 MHz clk
			vga_mod #(.h_active(800), .h_front(40),  .h_pulse(128), .h_back(88),
					  .v_active(600), .v_front(1),   .v_pulse(4),   .v_back(23))
					inst (vga_clk, clrn, d_in, col_addr, row_addr, hs, vs, r, g, b);
		end
		else if (width == 1280 && height == 720) begin // 1280x720 @ 60Hz 74.25 MHz clk
			vga_mod #(.h_active(1280), .h_front(110), .h_pulse(40), .h_back(220),
					  .v_active(720),  .v_front(5),   .v_pulse(5),  .v_back(20))
					inst (vga_clk, clrn, d_in, col_addr, row_addr, hs, vs, r, g, b);
		end
		else begin // Default: 640x480 @ 60Hz 25.175 MHz clk
			vga_mod inst (vga_clk, clrn, d_in, col_addr, row_addr, hs, vs, r, g, b);
		end
	endgenerate

endmodule

module vga_mod #(
	parameter h_active = 640,   // 默认时序参数，640*480@60Hz
	parameter h_front  =  16,
	parameter h_pulse  =  96,
	parameter h_back   =  48,
	parameter v_active = 480,
	parameter v_front  =  11,
	parameter v_pulse  =   2,
	parameter v_back   =  31
	)(
	input wire         vga_clk, // VGA 时钟, 需与图像分辨率对应
	input wire         clrn,
	input wire [11:0]  d_in,    // 颜色数据输入 RGB444, 顺序为 bbbb_gggg_rrrr

	output wire [10:0] col_addr,
	output wire [10:0] row_addr,
	output wire  	   hs,      // h_sync
	output wire 	   vs,      // v_sync
	output wire [3:0]  r,       // RGB444 色彩输出
	output wire [3:0]  g,
	output wire [3:0]  b
	);

	localparam h_whole = h_active + h_front + h_pulse + h_back;
	localparam v_whole = v_active + v_front + v_pulse + v_back;

	// 垂直与水平扫描计数器
	reg [11:0] h_count;
	reg [11:0] v_count;

	/*
	时序:        Active -- Front Porch -- Sync Pulse -- Back Porch
	视频有效:    ^^^^^^^^
	同步信号:    ------------------------|           |-------------
										|-----------|
	*/

	// Active
	wire h_enable = (h_count >= 11'b0 && h_count < h_active) ? 1'b1 : 1'b0; // 水平有效信号
	wire v_enable = (v_count >= 11'b0 && v_count < v_active) ? 1'b1 : 1'b0; // 垂直有效信号
	assign col_addr = h_enable ? h_count : h_active;  // 水平坐标
	assign row_addr = v_enable ? v_count : v_active;  // 垂直坐标
	assign {r, g, b} = h_enable & v_enable ? d_in : 12'b0; // 颜色信号 (rgb，注意顺序，bmp存储是bgr)

	// Sync Pulse
	assign hs = (h_count >= h_active + h_front && h_count < h_whole - h_back) ? 1'b0 : 1'b1;
	assign vs = (v_count >= v_active + v_front && v_count < v_whole - v_back) ? 1'b0 : 1'b1;

	always @(posedge vga_clk or negedge clrn) begin
		if(!clrn) begin // 重置
			h_count <= 12'b0;
			v_count <= 12'b0;
		end
		else begin
			if (h_count < h_whole)
				h_count <= h_count + 1'b1; // 扫描新的一列
			else begin
				h_count <= 12'b0; // 回到左侧

				if(v_count < v_whole)
					v_count <= v_count + 1'b1; // 扫描新的一行
				else 
					v_count <= 12'b0; // 回到顶侧
			end
		end
	end
endmodule