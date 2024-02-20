`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/10/17 12:25:41
// Design Name: 
// Module Name: Top
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


module Top(
	input clk,
	input rstn,
	input [15:0]SW,
	input ps2_clk,
	input ps2_data,
	output hs,
	output vs,
	output [3:0] r,
	output [3:0] g,
	output [3:0] b,

	output SEGLED_CLK,
	output SEGLED_CLR,
	output SEGLED_DO,
	output SEGLED_PEN,

	output [7:0] LED,
	output buzzer,
	output AUD_PWM,
	output AUD_SD,

	inout [15:0]  ddr3_dq,
	inout [1:0]   ddr3_dqs_n,
	inout [1:0]   ddr3_dqs_p,
	output [13:0] ddr3_addr,
	output [2:0]  ddr3_ba,
	output        ddr3_ras_n,
	output        ddr3_cas_n,
	output        ddr3_we_n,
	output        ddr3_reset_n,
	output [0:0]  ddr3_ck_p,
	output [0:0]  ddr3_ck_n,
	output [0:0]  ddr3_cke,
	output [0:0]  ddr3_cs_n,
	output [1:0]  ddr3_dm,
	output [0:0]  ddr3_odt
);
	
	wire sys_clk, vga_clock, ddr_clock, pwm_clk;
	clock_wiz clock(.clk_in1(clk),
					.sys_clk(sys_clk),
					.ddr_clk(ddr_clock),
					.vga_clk(vga_clock),
					.pwm_clk(pwm_clk));

	wire [10:0] row_addr;
	wire [10:0] col_addr;
	wire [15:0] render_data;
	wire [15:0] vga_data;

	wire rd_en;
	assign rd_en = (col_addr <= 11'd799 && row_addr <= 11'd599) ? 1'b1 : 1'b0;

	wire frame_rst;
	assign frame_rst = (col_addr == 11'd799 && row_addr == 11'd599) ? 1'b1 : 1'b0;

	// 处理跨时钟域问题
	reg [1:0] frame_rst_reg;
	wire frame_rst_sync;
    assign frame_rst_sync = (frame_rst_reg == 2'b01);
	always @ (posedge sys_clk) begin
        frame_rst_reg <= {frame_rst_reg[0], frame_rst};
    end

	wire ddr_top_init_complete;
	wire init_calib_complete;
	wire [15:0] frame_cnt;

	reg [31:0] clkdiv;
	always @ (posedge sys_clk) begin
		clkdiv <= clkdiv + 1'b1;
	end

	// 八位七段数码管，显示分数与残机
	wire crashed;
	wire [3:0] sout;
	wire [3:0] life_cnt;
	wire [31:0] seg_data = crashed ? {4'hD, 4'hE, 4'hA, 4'hD, frame_cnt} : (frame_cnt >= 16'h0F00) ? {32'h6666_6666} : {4'h5, frame_cnt, 4'hc, 4'h0, life_cnt};
    Seg7Device segDevice(.clkIO(clkdiv[3]), .clkScan(clkdiv[15:14]), .clkBlink(clkdiv[25]),
		.data(seg_data), .point(8'h0), .LES(8'h0), .sout(sout));

	assign SEGLED_CLK = sout[3];
	assign SEGLED_DO = sout[2];
	assign SEGLED_PEN = sout[1];
	assign SEGLED_CLR = sout[0];

	wire [18:0] buf_addr;
	wire [11:0] buf_data;
	wire ready;
	wire wr_en;

	ddr_top d0 (
		.ddr_clk(ddr_clock),
		.wr_clk(sys_clk),
		.wr_en(wr_en),
		.wr_din({buf_data, 4'h0}),
		.rd_clk(vga_clock),
		.rd_en(rd_en),
		.rd_dout(vga_data),
		.frame_rst(frame_rst_sync),
		.rst_n(rstn),
		.ddr_top_init_complete(ddr_top_init_complete),
		.init_calib_complete(init_calib_complete),
		.ddr3_dq(ddr3_dq),
		.ddr3_dqs_n(ddr3_dqs_n),
		.ddr3_dqs_p(ddr3_dqs_p),
		.ddr3_addr(ddr3_addr),
		.ddr3_ba(ddr3_ba),
		.ddr3_ras_n(ddr3_ras_n),
		.ddr3_cas_n(ddr3_cas_n),
		.ddr3_we_n(ddr3_we_n),
		.ddr3_reset_n(ddr3_reset_n),
		.ddr3_ck_p(ddr3_ck_p),
		.ddr3_ck_n(ddr3_ck_n),
		.ddr3_cke(ddr3_cke),
		.ddr3_cs_n(ddr3_cs_n),
		.ddr3_dm(ddr3_dm),
		.ddr3_odt(ddr3_odt)
	);

	wire [7:0] key_data;
	wire crash, started;
	game_module game (
		.clk(sys_clk),
		.rstn(rstn),
		.frame_rst(frame_rst_sync),
		.keyboard_data(key_data),
		.buf_addr(buf_addr),
		.buf_data(buf_data),
		.frame_cnt(frame_cnt),
		.game_rdy(ready),
		.life_cnt(life_cnt),
		.crash(crash),
		.crashed(crashed),
		.started(started)
	);

	data_mover mover(
		.clk(sys_clk),
		.buf_addr(buf_addr),
		.frame_rst(frame_rst_sync),
		.game_rdy(ready),
		.wr_en(wr_en)
	);

	vgac #(800, 600) v0 (
		.vga_clk(vga_clock),
		.clrn(SW[0]),
		.d_in(vga_data[15:4]),
		.row_addr(row_addr),
		.col_addr(col_addr),
		.r(r), .g(g), .b(b),
		.hs(hs), .vs(vs)
	);

	Keyboard k0 (
		.clk(sys_clk),
		.rstn(rstn),
		.ps2_clk(ps2_clk),
		.ps2_data(ps2_data),
		.status(key_data)
	);

	// Arduino LED 显示残机数量
	LED_decoder led_disp (
		.data(life_cnt),
		.out(LED)
	);

	// 音频播放
	Audio audio_inst (
		.sys_clk(sys_clk),
		.pwm_clk(pwm_clk),
		.rstn(rstn),
		.buzzer(buzzer),
		.buzzer_en(SW[1]),
		.AUD_EN(SW[2]),
		.AUD_SD(AUD_SD),
		.AUD_PWM(AUD_PWM),

		.started(started),
		.crash(crash),
		.crashed(crashed)
	);

	// ila_0 debug (
	// 	.clk(sys_clk),
	// 	.probe0(vga_data[15:4]),
	// 	.probe1(col_addr),
	// 	.probe2(row_addr),
	// 	.probe3(hs),
	// 	.probe4(vs),
	// 	.probe5(frame_rst_sync)
	// );

endmodule

module data_mover (
	input wire clk,
	input wire frame_rst,
	input wire game_rdy,
	output wire [18:0] buf_addr,
	output reg wr_en
);
	localparam RESET = 3'b000;
	localparam IDLE = 3'b001;
	localparam WAIT = 3'b010;
	localparam MOVE = 3'b100;

	localparam [18:0] MAX_ADDR = 19'd800 * 19'd600 - 1;

	reg [2:0] state = RESET;

	reg [18:0] addr = 19'd0;
	assign buf_addr = addr;

	always @ (posedge clk) begin
		case (state)
			RESET: begin
				state <= IDLE;
				wr_en <= 1'b0;
				addr <= 19'd0;
			end
			IDLE: begin
				if (frame_rst) begin // 下一个周期生效
					state <= WAIT;
				end else begin
					state <= state;
				end
			end
			WAIT: begin
				if (game_rdy) begin
					state <= MOVE;
				end else begin
					state <= state;
				end
				addr <= 19'd0;
				wr_en <= 1'b0;
			end
			MOVE: begin
				if (addr == MAX_ADDR) begin
					state <= IDLE;
					wr_en <= 1'b0;
					addr <= 19'd0;
				end else begin
					state <= state;
					wr_en <= 1'b1;
					addr <= addr + 19'd1;
				end
			end
			default: begin
				state <= RESET;
			end
		endcase
	end
endmodule

module LED_decoder (
	input wire [4:0] data,
	output reg [7:0] out = 8'd0
);
	always @ * begin
		case (data)
			4'h0: out <= 8'b00000000;
			4'h1: out <= 8'b10000000;
			4'h2: out <= 8'b11000000;
			4'h3: out <= 8'b11100000;
			4'h4: out <= 8'b11110000;
			4'h5: out <= 8'b11111000;
			4'h6: out <= 8'b11111100;
			4'h7: out <= 8'b11111110;
			4'h8: out <= 8'b11111111;
			default: out <= 8'b00000000;
		endcase
	end
endmodule