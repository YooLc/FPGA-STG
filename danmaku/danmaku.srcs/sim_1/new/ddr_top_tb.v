`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/29 18:06:57
// Design Name: 
// Module Name: ddr_top_tb
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


module ddr_top_tb(

    );

    reg clk_200;
    reg clk_100;
    reg clk_25;
    reg wr_en;
    reg rd_en;
    reg [15:0] wr_din;
    reg frame_rst;
	wire [15:0] rd_dout;

	wire	[13:0]	 ddr3_addr     ;
	wire	 [2:0]	 ddr3_ba       ;
	wire		     ddr3_cas_n    ;
	wire	 [0:0]	 ddr3_ck_n     ;
	wire	 [0:0]	 ddr3_ck_p     ;
	wire	 [0:0]	 ddr3_cke      ;
	wire		     ddr3_ras_n    ;
	wire		     ddr3_reset_n  ;
	wire		     ddr3_we_n     ;
	wire	 [15:0]	 ddr3_dq       ;
	wire	 [1:0]	 ddr3_dqs_n    ;
    wire	 [1:0]	 ddr3_dqs_p    ;
    wire	 [0:0]	 ddr3_cs_n     ;
    wire	 [1:0]	 ddr3_dm       ;
    wire	 [0:0]	 ddr3_odt      ;

    wire ddr_top_init_complete;

    always #2.5 clk_200 = ~clk_200;
    always #5 clk_100 = ~clk_100;
    always #20 clk_25 = ~clk_25;

    integer x;
    integer y;

    initial begin
        clk_200 = 0;
        clk_100 = 0;
        clk_25 = 0;
        wr_en = 0;
        rd_en = 0;
        wr_din = 0;
        frame_rst = 0;

        #1200;
        frame_rst = 1;
        #5;
        frame_rst = 0;
    end

    initial begin
        wr_din = 0;
        #55000;
        for (x = 0; x < 80; x = x + 1) begin
            for (y = 0; y < 60; y = y + 1) begin
                wr_en = 1;
                wr_din = wr_din + 1;
                #10;
            end
        end
    end

    initial begin
        #55000;
        for (x = 0; x < 80; x = x + 1) begin
            for (y = 0; y < 60; y = y + 1) begin
                rd_en = 1;
                #10;
            end
        end
        #50;
        frame_rst = 1;
        #5;
        frame_rst = 0;
        #200;
        for (x = 0; x < 800; x = x + 1) begin
            for (y = 0; y < 600; y = y + 1) begin
                rd_en = 1;
                #10;
            end
        end
    end

    ddr_top inst(
        .ddr_clk(clk_200),
        .wr_clk(clk_100),
        .wr_en(wr_en),
        .rst_n(1'b1),
        .wr_din(wr_din),
        .rd_clk(clk_25),
        .rd_en(rd_en),
        .rd_dout(rd_dout),
        .frame_rst(frame_rst),
        .ddr_top_init_complete(ddr_top_init_complete),
        .ddr3_addr         (ddr3_addr	 [13:0]	),					
        .ddr3_ba           (ddr3_ba      [2:0]	),					
        .ddr3_cas_n        (ddr3_cas_n  		),				
        .ddr3_ck_n         (ddr3_ck_n    [0:0]	),					
        .ddr3_ck_p         (ddr3_ck_p    [0:0]	),					
        .ddr3_cke          (ddr3_cke     [0:0]	),					
        .ddr3_ras_n        (ddr3_ras_n  		),					
        .ddr3_reset_n      (ddr3_reset_n		),					
        .ddr3_we_n         (ddr3_we_n   		),					
        .ddr3_dq           (ddr3_dq      [15:0]	),					
        .ddr3_dqs_n        (ddr3_dqs_n   [1:0]	),					
        .ddr3_dqs_p        (ddr3_dqs_p   [1:0]	),					
        .ddr3_cs_n         (ddr3_cs_n    [0:0]	),					
        .ddr3_dm           (ddr3_dm      [1:0]	),					
        .ddr3_odt          (ddr3_odt     [0:0]	)
    );

    ddr3_model	ddr3_model_inst (	
        .rst_n   		(rst_n),	
        .ck      		(ddr3_ck_p),	
        .ck_n    		(ddr3_ck_n),	
        .cke     		(ddr3_cke),	
        .cs_n    		(ddr3_cs_n),	
        .ras_n   		(ddr3_ras_n),	
        .cas_n   		(ddr3_cas_n),	
        .we_n    		(ddr3_we_n),	
        .dm_tdqs 		(ddr3_dm),	
        .ba      		(ddr3_ba),	
        .addr    		(ddr3_addr),	
        .dq      		(ddr3_dq),	
        .dqs     		(ddr3_dqs_p),	
        .dqs_n   		(ddr3_dqs_n),	
        .tdqs_n  		(),
        .odt     		(ddr3_odt)	
    );
endmodule
