`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/29 15:09:19
// Design Name: 
// Module Name: ddr_wr_manager
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

module ddr_wr_manager (
	input wire clk,
    input wire init_calib_complete,
    input wire ddr_top_init_complete,
    input wire app_rdy,
    input wire app_wdf_rdy,
    input wire frame_rst,

    input wire wfull,
    input wire rempty,

    output wire app_en,
    output reg [27:0] app_addr,
    output wire [2:0] app_cmd,
    output wire app_wdf_wren,
    output wire app_wdf_end
    );

	localparam RESET = 4'b0001;
	localparam  IDLE = 4'b0010;
	localparam  READ = 4'b0100;
	localparam WRITE = 4'b1000;

    localparam wr_burst_len = 8'd96;
    localparam rd_burst_len = 8'd96;

    reg [27:0] app_addr_wr;
    reg [27:0] app_addr_rd;
    reg [7:0] wr_cnt;
    reg [7:0] rd_cnt;
    reg app_page_wr, app_page_rd;

    reg [3:0] state = RESET;
    reg wrote;

    assign app_en = ((state == WRITE) & app_rdy & app_wdf_rdy) | (state == READ && app_rdy);
    assign app_wdf_wren = (state == WRITE & app_rdy & app_wdf_rdy);
    assign app_wdf_end = app_wdf_wren; // 突发读写结束，4:1 时不用考虑
    assign app_cmd = (state == READ) ? 3'b1 : 3'b0;

    always @(*) begin
        if (state == READ) begin
            app_addr <= {2'b0, app_page_rd, app_addr_rd[24:0]};
        end else if (state == WRITE) begin
            app_addr <= {2'b0, app_page_wr, app_addr_wr[24:0]};
        end else begin
            app_addr <= 28'd0;
        end
    end

    always @(posedge clk) begin
        case (state)
            RESET: begin
                if (ddr_top_init_complete) begin
                    state <= IDLE;
                end else begin
                    state <= RESET;
                end

                wr_cnt <= 8'd0;
                rd_cnt <= 8'd0;
                wrote <= 1'b0;
                app_addr_wr <= 28'd0;
                app_addr_rd <= 28'd0;
                app_page_wr <= 1'b0;
                app_page_rd <= 1'b0;
            end
            IDLE: begin
                if (frame_rst) begin
                    wr_cnt <= 8'd0;
                    rd_cnt <= 8'd0;
                    wrote <= 1'b0;
                    app_addr_wr <= 28'd0;
                    app_addr_rd <= 28'd1;
                    // 切换缓冲页
                    app_page_wr <= ~app_page_wr;
                    app_page_rd <= ~app_page_rd;
                end else if (!ddr_top_init_complete) begin
                    state <= IDLE;
                end else if (wfull) begin
                    state <= WRITE;
                end else if (rempty) begin // & wrote
                    state <= READ;
                end else begin
                    state <= IDLE;
                end
            end
            READ: begin
                if ((rd_cnt == rd_burst_len - 1) && app_rdy) begin
                    state <= IDLE;
                    rd_cnt <= 8'd0;
                    app_addr_rd <= app_addr_rd + 28'd8;
                end else if (app_rdy) begin
                    rd_cnt <= rd_cnt + 8'd1;
                    app_addr_rd <= app_addr_rd + 28'd8;
                end else begin
                    rd_cnt <= rd_cnt;
                    app_addr_rd <= app_addr_rd;
                end
            end
            WRITE: begin
                wrote <= 1'b1;
                if ((wr_cnt == wr_burst_len - 1) && (app_rdy && app_wdf_rdy)) begin
                    state <= IDLE;
                    wr_cnt <= 8'd0;
                    app_addr_wr <= app_addr_wr + 28'd8;
                end else if (app_rdy && app_wdf_rdy) begin
                    wr_cnt <= wr_cnt + 8'd1;
                    app_addr_wr <= app_addr_wr + 28'd8;
                end else begin
                    wr_cnt <= wr_cnt;
                    app_addr_wr <= app_addr_wr;
                end
            end
            default: begin
                state <= RESET;
            end
        endcase
    end

endmodule