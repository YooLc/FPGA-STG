`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/24 19:56:41
// Design Name: 
// Module Name: ps2_drive
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
