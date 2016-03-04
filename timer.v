`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:14:34 03/04/2016 
// Design Name: 
// Module Name:    timer 
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
module timer #(parameter CTR_LEN = 26) (
	input clk,
	input reset,
	output tick
	);
	
	reg [CTR_LEN-1:0] counter_d, counter_q;
	
	assign tick = counter_q[CTR_LEN-1];
	
	always @(counter_q) begin
		counter_d = counter_q + 1'b1;
	end
   
	always @(posedge clk) begin
		if (reset) begin
			counter_q <= 25'b0;
		end else begin
			counter_q <= counter_d;
		end
	end
endmodule

