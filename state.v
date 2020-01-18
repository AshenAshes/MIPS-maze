`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:39:52 01/07/2019 
// Design Name: 
// Module Name:    State 
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
module state(
	input wire reset, 
	input wire [3:0] Direction,
	input wire vs,
	input reg [9:0]Px,
	input reg [9:0]Py,
	output reg win
    );
	reg [1:0] state=0;
	parameter RESET = 2'b00, MOVE = 2'b01, CHECK = 2'b10;
	parameter PaDn=4'b0001,PaUp=4'b0100,PaRight=4'b0010,PaLeft=4'b1000,Stop=4'b0000;
	reg [299:0]map=0; 
	reg [299:0]exit=0; 
	
	//always@(posedge vs or posedge reset)begin	
	always@(posedge vs)begin
		map<=300'b11011111110111111101_10001000000100001001_10111110111101101001_10100000000000101111_10101011111111100001_10101001000010111001_11101111111010000011_00100010010011111001_10001010000000101101_10101000111100101001_11101111100110101001_10100100000000101100_10111110011111100110_10000000100010000000_11111111101111111100;
		if(reset)
			state<=RESET;
		case(state)
		RESET:begin 
		Px<=0;
		Py<=0;
		win<=0;
		map<=0;
		exit[299]<=1'b1;
		if(Direction==PaDn||Direction==PaUp||Direction==PaLeft||Direction==PaRight)
		state<=MOVE;
		end
		
		MOVE:begin
		case(Direction)
		PaDn:begin 
		if(Py<14)
			Py<=Py+1;
		end
		PaUp:begin
		if(Py>0)
			Py<=Py-1;
		end
		PaLeft:begin
		if(Px>0)
			Px<=Px-1;
		end
		PaRight:begin
		if(Px<19)
			Px<=Px+1;
		end
		endcase
		state<=CHECK;
		end
		
		CHECK:begin
		if(Px==10'b00000010001&&Py==10'b0000001110) begin
		win<=1'b1;
		state<=RESET;
		end
		else state<=MOVE;
		end
		
		endcase
		end

endmodule
