`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/11 12:48:12
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
    input wire  clk,
    input wire  switch,
    input wire  switch2,
    output wire buzzer,
    output wire AUD_PWM,
    output wire AUD_SD
    );

    reg [31:0] clkdiv = 4'b0;
    clk_wiz_0 clock(.clk_in1(clk), .clk_out1(pwm_clk),.clk_out2(clk_100M));
    always @ (posedge pwm_clk) begin
        clkdiv <= clkdiv + 1;
    end

    reg[31:0] clkdiv2 = 4'b0;
    always @(posedge clk_100M) begin
        clkdiv2 <= clkdiv2 + 1;
    end

    reg [15:0] memory [32767:0];
    initial begin
        $readmemh("D:/Xilinx/AudioDemo/AudioDemo.srcs/sources_1/new/tbc_cut_low.hex", memory);
    end
    
    reg pwm = 1'b0;
    reg [16:0] cur_note = 17'd0;
    reg [7:0] cur_pwm = 8'd0;
    reg [7:0] cnt = 8'd0;
    always @(posedge clkdiv[10]) begin
        if (cur_note & 1) begin
            cur_pwm <= memory[cur_note[16:1]][15:8];
        end else begin
            cur_pwm <= memory[cur_note[16:1]][7:0];
        end
        if (cur_note == 17'd68122) begin
            cur_note <= 17'd0;
        end else begin
            cur_note <= cur_note + 17'd1;
        end
    end

    always @(posedge clkdiv2[1]) begin
        if (cnt < cur_pwm)
            pwm <= 1'b1;
        else
            pwm <= 1'b0;
        cnt <= cnt + 8'd1;
    end

    assign buzzer = pwm & switch2;
    assign AUD_PWM = pwm;
    assign AUD_SD = switch;

endmodule
