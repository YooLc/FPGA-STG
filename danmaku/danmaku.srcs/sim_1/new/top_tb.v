`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/12 23:42:53
// Design Name: 
// Module Name: top_tb
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


module top_tb();

    reg clk;
	reg rstn = 1;
	reg [15:0]SW;
	reg ps2_clk;
	wire ps2_data;
	wire hs;
	wire vs;
	wire [3:0] r;
	wire [3:0] g;
	wire [3:0] b;
	// wire SEGLED_CLK;
	// wire SEGLED_CLR;
	// wire SEGLED_DO;
	// wire SEGLED_PEN;
    // wire LED_CLK;
	// wire LED_CLR;
	// wire LED_DO;
	// wire LED_PEN;
	// wire [4:0]BTN_X;
	// wire [3:0]BTN_Y;
	// wire buzzer;
	wire [15:0]  ddr3_dq;
	wire [1:0]   ddr3_dqs_n;
	wire [1:0]   ddr3_dqs_p;
	wire [13:0] ddr3_addr;
	wire [2:0]  ddr3_ba;
	wire        ddr3_ras_n;
	wire        ddr3_cas_n;
	wire        ddr3_we_n;
	wire        ddr3_reset_n;
	wire [0:0]  ddr3_ck_p;
	wire [0:0]  ddr3_ck_n;
	wire [0:0]  ddr3_cke;
	wire [0:0]  ddr3_cs_n;
	wire [1:0]  ddr3_dm;
	wire [0:0]  ddr3_odt;

    Top inst(
        .clk(clk),
        .rstn(rstn),
        .SW(SW),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .hs(hs),
        .vs(vs),
        .r(r),
        .g(g),
        .b(b),
        // .SEGLED_CLK(SEGLED_CLK),
        // .SEGLED_CLR(SEGLED_CLR),
        // .SEGLED_DO(SEGLED_DO),
        // .SEGLED_PEN(SEGLED_PEN),
        // .LED_CLK(LED_CLK),
        // .LED_CLR(LED_CLR),
        // .LED_DO(LED_DO),
        // .LED_PEN(LED_PEN),
        // .BTN_X(BTN_X),
        // .BTN_Y(BTN_Y),
        // .buzzer(buzzer),
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

    // 100Mhz clk
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

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
