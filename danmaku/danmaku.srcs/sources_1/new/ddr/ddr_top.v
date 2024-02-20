`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/29 15:09:19
// Design Name: 
// Module Name: ddr_top
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


module ddr_top(
    input wire ddr_clk,
    input wire wr_clk,
    input wire wr_en,
    input wire [15:0] wr_din,
    input wire rd_clk,
    input wire rd_en,
    input wire rst_n,
    output wire [15:0] rd_dout,
    input wire frame_rst,
    output wire ddr_top_init_complete,
    output wire init_calib_complete,
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

    wire [15:0] wbuf_din;
    wire [127:0] wbuf_dout;
    wire [127:0] rbuf_din;
    wire [15:0] rbuf_dout;
    assign wbuf_din = wr_din;
    assign rd_dout = rbuf_dout;

    wire wbuf_wren = wr_en;
    wire rbuf_rden = rd_en;
    wire wfull, rfull;

    // DDR3 用户接口
	wire [27:0] app_addr;
	wire [2:0] app_cmd;
	wire [127:0] app_wdf_data;
	wire [15:0] app_wdf_mask;
	wire [127:0] app_rd_data;
	wire [11:0] device_temp;
    // wire init_calib_complete;

    wire [9:0] wbuf_wcount;
    wire [6:0] wbuf_rcount;

    wire ui_clk;

    wire wbuf_wrst_busy, wbuf_rrst_busy;
    wire rbuf_wrst_busy, rbuf_rrst_busy;

    wire wbuf_rst, rbuf_rst;
    reg [15:0] wbuf_rst_sreg;
    reg [15:0] rbuf_rst_sreg;

    assign ddr_top_init_complete = (wbuf_wrst_busy == 1'b0 && wbuf_rrst_busy == 1'b0) 
                                && (rbuf_wrst_busy == 1'b0 && rbuf_rrst_busy == 1'b0)
                                && !wbuf_rst && !rbuf_rst
                                && init_calib_complete;

    // 延时，提供 FIFO 同步重置信号
    assign wbuf_rst = |wbuf_rst_sreg;
    always @ (posedge ui_clk or negedge rst_n) begin
        if (!rst_n) begin
            wbuf_rst_sreg <= 16'h0000;
        end else begin
            wbuf_rst_sreg <= {wbuf_rst_sreg[14:0], frame_rst};
        end
    end

    assign rbuf_rst = |rbuf_rst_sreg;
    always @ (posedge ui_clk or negedge rst_n) begin
        if (!rst_n) begin
            rbuf_rst_sreg <= 16'h0000;
        end else begin
            rbuf_rst_sreg <= {rbuf_rst_sreg[14:0], frame_rst};
        end
    end
    
    fifo_generator_w wbuf(
        .rst(wbuf_rst),
        .wr_clk(wr_clk),
        .rd_clk(ui_clk),

        // FIFO_WRITE
        .full(),
        .din(wbuf_din),
        .wr_en(wbuf_wren),

        // FIFO_READ
        .empty(),
        .dout(app_wdf_data),
        .rd_en(app_wdf_wren),

        .prog_full(wfull),
        .wr_rst_busy(wbuf_wrst_busy),
        .rd_rst_busy(wbuf_rrst_busy)
    );

    fifo_generator_r rbuf(
        .rst(rbuf_rst),
        .wr_clk(ui_clk),
        .rd_clk(rd_clk),

        // FIFO_WRITE
        .full(),
        .din({app_rd_data[111 -: 48], app_rd_data[127 -: 16], app_rd_data[47 -: 48], app_rd_data[63 -: 16]}),
        .wr_en(app_rd_data_valid),

        // FIFO_READ
        .empty(),
        .dout(rbuf_dout),
        .rd_en(rbuf_rden),

        .prog_empty(rempty),
        .wr_rst_busy(rbuf_wrst_busy),
        .rd_rst_busy(rbuf_rrst_busy)
    );

    wire app_wdf_wren, app_rd_data_valid, rempty;
    wire app_en, app_rdy, app_wdf_end, app_wdf_rdy, app_rd_data_end;
    wire app_ref_ack, app_zq_ack, app_sr_active, ui_clk_sync_rst;
	mig_7series_0 ddr_inst(
	.ddr3_dq(ddr3_dq), .ddr3_dqs_n(ddr3_dqs_n), .ddr3_dqs_p(ddr3_dqs_p),
	.ddr3_addr(ddr3_addr), .ddr3_ba(ddr3_ba), .ddr3_ras_n(ddr3_ras_n),
	.ddr3_cas_n(ddr3_cas_n), .ddr3_we_n(ddr3_we_n), .ddr3_reset_n(ddr3_reset_n),
	.ddr3_ck_p(ddr3_ck_p), .ddr3_ck_n(ddr3_ck_n), .ddr3_cke(ddr3_cke),
	.ddr3_cs_n(ddr3_cs_n), .ddr3_dm(ddr3_dm), .ddr3_odt(ddr3_odt),

	.init_calib_complete(init_calib_complete), // IP 核初始化信号
	.sys_clk_i(ddr_clk),

	// 命令相关 API
	.app_addr(app_addr), // 地址 {bank, row, col}
	.app_cmd(app_cmd), // 读 / 写
	.app_en(app_en),   // 使能
	.app_rdy(app_rdy), // 就绪

	// 写入数据相关 API
	.app_wdf_data(app_wdf_data), // 写入的数据
	.app_wdf_end(app_wdf_end),   // 写入结束标志
	.app_wdf_mask(app_wdf_mask), // 字节掩码
	.app_wdf_wren(app_wdf_wren), // 写入使能
	.app_wdf_rdy(app_wdf_rdy),   // 写入就绪

	// 读取数据相关 API
	.app_rd_data(app_rd_data),
	.app_rd_data_end(app_rd_data_end),
	.app_rd_data_valid(app_rd_data_valid), // 读数据有效

	.app_ref_req(1'b0), // 刷新请求
	.app_ref_ack(app_ref_ack), // 刷新相应
	.app_zq_req(1'b0), // ZQ 校准请求
	.app_zq_ack(app_zq_ack), // ZQ 校准相应
	.app_sr_req(1'b0),
	.app_sr_active(app_sr_active),

	.ui_clk(ui_clk), // 用户时钟
	.ui_clk_sync_rst(ui_clk_sync_rst), 
	.device_temp(device_temp),
	.sys_rst(rst_n)
	);

    assign app_wdf_mask = 16'h0000;
    ddr_wr_manager m0(
        .clk(ui_clk),
        .init_calib_complete(init_calib_complete),
        .ddr_top_init_complete(ddr_top_init_complete),
        .frame_rst(frame_rst),
        .app_rdy(app_rdy),
        .app_wdf_rdy(app_wdf_rdy),
        .wfull(wfull),
        .rempty(rempty),
        .app_en(app_en),
        .app_addr(app_addr),
        .app_cmd(app_cmd),
        .app_wdf_wren(app_wdf_wren),
        .app_wdf_end(app_wdf_end)
    );
endmodule