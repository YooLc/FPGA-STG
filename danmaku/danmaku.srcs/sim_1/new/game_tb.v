`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/07 20:51:45
// Design Name: 
// Module Name: game_tb
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


module game_tb(

    );

    reg clk, frame_rst;
    reg [7:0] key_data = 8'd0;
    wire ready;

    wire [11:0] buf_data;
    wire [18:0] buf_addr;
    game_module game (
		.clk(clk),
		.rstn(1'b1),
		.frame_rst(frame_rst),
		.keyboard_data(key_data),
		.buf_addr(buf_addr),
		.buf_data(buf_data),
		.game_rdy(ready)
	);

    reg flag;
    data_mover_a mover(
        .clk(clk),
        .frame_rst(frame_rst),
        .game_rdy(ready),
        .buf_addr(buf_addr),
        .wr_en(wren)
    );

    integer i = 0, j = 0, k = 0;
    initial begin
        clk = 1;
        frame_rst = 0;
        flag = 0;
        
        #50 frame_rst = 1;
        #10 frame_rst = 0;

        for (k = 0; k < 60; k = k+1) begin
            
            #5000 flag = 1;
            #70000 flag = 0;
            #300 frame_rst = 1;
            #10 frame_rst = 0;
        end
    end

    always #5 clk = ~clk;
endmodule

module data_mover_a (
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

	reg [1:0] frame_rst_reg = 2'd0;
    always @ (posedge clk) begin
        frame_rst_reg <= {frame_rst_reg[0], frame_rst};
    end

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
				if (frame_rst_reg == 2'b01) begin // 下一个周期生效
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
				end else begin
					state <= state;
					wr_en <= 1'b1;
				end
				addr <= addr + 19'd1;
			end
			default: begin
				state <= RESET;
			end
		endcase
	end
endmodule