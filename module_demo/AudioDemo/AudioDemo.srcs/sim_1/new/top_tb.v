`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/16 12:37:31
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
    

    reg clk = 1'b0;
    wire buzzer, AUD_PWM, AUD_SD;
    Top inst(.clk(clk),.switch(1'b1),.switch2(1'b1),.buzzer(buzzer),.AUD_PWM(AUD_PWM),.AUD_SD(AUD_SD));
    initial begin
        forever begin
            // 100 Mhz clock
            #5 clk = ~clk;
        end
    end
endmodule
