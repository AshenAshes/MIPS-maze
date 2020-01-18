`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:43:22 01/04/2019 
// Design Name: 
// Module Name:    top 
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
module top(
	input clk,
	input rstn,
	input [15:0]SW,
	input wire ps2_clk,
	input wire ps2_data,
	output hs,
	output vs,
	output [3:0] R,
	output [3:0] G,
	output [3:0] B
    );
	parameter RESET = 2'b00, MOVE = 2'b01, CHECK = 2'b10;
	parameter PaDn=4'b0001,PaUp=4'b0100,PaRight=4'b0010,PaLeft=4'b1000,Stop=4'b0000;
	wire clk_100ms;
	reg [31:0]clkdiv;
	always@(posedge clk) begin
		clkdiv <= clkdiv + 1'b1;
	end
	wire [15:0] SW_OK;
	AntiJitter #(4) a0[15:0](.clk(clkdiv[15]), .I(SW), .O(SW_OK));
/*ip core for maze
	wire [11:0] mazergb;
	reg [11:0] mazeaddr;
	maze m1(.a(mazeaddr),.spo(mazergb));
*/
	reg [9:0] Px;
	reg [9:0] Py;
	reg win;
	wire reset;
	reg [3:0]Direction=4'b0000;
	assign reset=SW[6];
//	assign Direction[3]=SW[5];
//	assign Direction[2]=SW[4];
//	assign Direction[1]=SW[3];
//	assign Direction[0]=SW[2];
//	state s1(.reset(SW[6]),.Direction(SW[5:2]),.vs(vs),.Px(xxx),.Py(yyy),.win(win));
	reg [1:0] state=0;
	reg [299:0]map=0; 
	reg [299:0]exit=0; 
	
	//always@(posedge vs or posedge reset)begin	
	counter_100ms counter(.clk(clk),.clk_100ms(clk_100ms));
	always@(posedge clk_100ms)begin
		map<=300'b11011111110111111101_10001000000100001001_10111110111101101001_10100000000000101111_10101011111111100001_10101001000010111001_11101111111010000011_00100010010011111001_10001010000000101101_10101000111100101001_11101111100110101001_10100100000000101100_10111110011111100110_10000000100010000000_11111111101111111100;
		Direction[3]<=SW_OK[5];
		Direction[2]<=SW_OK[4];
		Direction[1]<=SW_OK[3];
		Direction[0]<=SW_OK[2];
		if(reset)begin
			state<=RESET;
			Px<=0;
			Py<=0;
			win<=0;
		end
		case(state)
		RESET:begin 
		Px<=0;
		Py<=0;
		win<=0;
		exit[159]<=1'b1;
		if(Direction==4'b0001||Direction==4'b0010||Direction==4'b0100||Direction==4'b1000)
		state<=MOVE;
		end
		MOVE:begin
		case(Direction)
		PaDn:begin 
		if(map[20*Py+Px+20]==0&&Py<14)
			Py<=Py+1;
		end
		PaUp:begin
		if(map[20*Py+Px-20]==0&&Py>0)
			Py<=Py-1;
		end
		PaLeft:begin
		if(map[20*Py+Px-1]==0&&Px>0)
			Px<=Px-1;
		end
		PaRight:begin
		if(map[20*Py+Px+1]==0&&Px<19)
			Px<=Px+1;
		end
		endcase
		state<=CHECK;
		end
		
		CHECK:begin
		if(Px==10'b00000010011&&Py==10'b0000000111) begin
		win<=1'b1;
		state<=RESET;
		end
		else state<=MOVE;
		end
		
		endcase
		end
	
	wire [11:0] funrgb;
	reg [11:0] funaddr;
	fun f1(.addra(funaddr),.clka(clkdiv[0]),.douta(funrgb));
	
	wire [11:0] wallrgb;
	reg [11:0] walladdr;
	wall block(.addra(walladdr),.clka(clkdiv[0]),.douta(wallrgb));	
/*	
	wire [11:0] beginpicrgb;
	reg [18:0] beginpicaddr;
	beginpic pic1(.addra(beginpicaddr),.CLKA(clkdiv[0]),.DOUTA(beginpicrgb));
	*/
	/*
	wire [11:0] winpicrgb;
	reg [18:0] winpicaddr;
	winpic pic1(.addra(winpicaddr),.CLKA(clkdiv[0]),.DOUTA(winpicrgb));
	*/
	reg [9:0] x;
	reg [8:0] y;
	
 	reg [11:0] vga_data;
 	wire [9:0] col_addr;
 	wire [8:0] row_addr;
	reg [299:0] walle;	
//	reg [299:0] people;
	vgac v0 (
		.vga_clk(clkdiv[1]), .clrn(SW_OK[0]), .d_in(vga_data), .row_addr(row_addr), .col_addr(col_addr), .r(R), .g(G), .b(B), .hs(hs), .vs(vs)
	);

	//判断在圆的范围内，则显示特定颜色
	always@(clkdiv[3])begin
		walle <= 300'b11011111110111111101_10001000000100001001_10111110111101101001_10100000000000101111_10101011111111100001_10101001000010111001_11101111111010000011_00100010010011111001_10001010000000101101_10101000111100101001_11101111100110101001_10100100000000101100_10111110011111100110_10000000100010000000_11111111101111111100;
//		people[299:0]<=300'b0;
//		people[Px/32*20+Py/32]<=1'b1;
	end
	always@(*) begin
/*
		if(~SW_OK[15]&&~win)begin
			beginpicaddr = (row_addr%480)*480+(col_addr%640);
			vga_data={beginpicrgb[3:0],beginpicrgb[7:4],beginpicrgb[11:8]};
		end
*/
/*		else if(win)begin
			winpicaddr = (row_addr%32)*32+(col_addr%32);
			vga_data={winpicrgb[3:0],winpicrgb[7:4],winpicrgb[11:8]};
		end
		*/
		if(walle[row_addr/32*20+col_addr/32]==1 && SW_OK[15])begin
			walladdr = (row_addr%32)*32+(col_addr%32);
			vga_data={wallrgb[3:0],wallrgb[7:4],wallrgb[11:8]};
		end
		else if(row_addr/32==Py && col_addr/32==Px && SW_OK[15])begin
			funaddr = (row_addr%32)*32+(col_addr%32);
			vga_data={funrgb[3:0],funrgb[7:4],funrgb[11:8]};
		end
		else vga_data = 12'b0;
	end
	
	wire [9:0] data;
	wire keyReady;
	reg edge_negative;
	initial begin
		edge_negative = keyReady;
	end
	ps2 keyboard(.clk(clk),.rst(),.ps2_clk(ps2_clk),.ps2_data(ps2_data),.data_out(data),.ready(keyReady));
	
	always @(posedge clk) begin
		if (!edge_negative && keyReady) begin
			if(data[7:0]==8'h1d && data[8]==1'b1) 		//'W'
				;
			else if(data[7:0]==8'h1c && data[8]==1'b0)	//'A'
				;
			else if(data[7:0]==8'h1b)	//'S'
				;
			else if(data[7:0]==8'h23)	//'D'
				;
		end
		
		edge_negative <= keyReady;
	end
endmodule
