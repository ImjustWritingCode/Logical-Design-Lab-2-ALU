module ALU (A, B, sel, Cin, Y, Zero);
	input [32 - 1 : 0] A, B;
	input [3 : 0] sel;
	input Cin;
	output [32 - 1 : 0] Y;
	output Zero;
	reg [32-1:0] Y;		//in always block -> reg
	reg Zero;
	reg [15:0] AX, BX;

	//external module output wire
	wire and_out, or_out, not_out, xor_out, xnor_out, nor_out;
	wire [5-1:0] arbiter_out;
	wire [32-1:0] decoder_out;
	//main
	always@(*)begin
		case(sel)
			0:begin
				Y = and_out;		//AND
				Zero = !and_out;
			end
			1:begin
				Y = or_out;			//OR
				Zero = !or_out;
			end
			2:begin
				Y = not_out;		//NOT
				Zero = A[0];
			end
			3:begin
				Y = xor_out;		//XOR
				Zero = !xor_out;
			end
			4:begin
				Y = xnor_out;		//XNOR
				Zero = !xnor_out;
			end
			5:begin
				Y = nor_out;		//NOR
				Zero = !nor_out;
			end
			6:begin
				Y = A+B+Cin;					//A+B
				if (Y == 0) Zero = 1;
				else Zero = 0;
			end
			7:begin
				Y = A-B;						//A-B
				if (A == B) Zero = 1;
				else Zero = 0;
			end
			8:begin								//|A-B|
				if (A < B) Y = B-A;
				else Y = A-B;
				if (A == B) Zero = 1;
				else Zero = 0;
			end
			9:begin								//A[15:0]*B[15:0]
				AX = A[15:0];
				BX = B[15:0];
				Y = AX*BX;
				if (AX == 0 && BX == 0) Zero = 1;
				else Zero = 0;
			end
			10:begin							//slli 1
				Y = A << 1;
				if (Y == 0) Zero = 1;
				else Zero = 0;
			end
			11:begin							//sali 1
				Y = A << 1;
				if (Y == 0) Zero = 1;
				else Zero = 0;
			end
			12:begin							//slri 1
				Y = A >> 1;
				if (Y == 0) Zero = 1;
				else Zero = 0;
			end
			13:begin
				Y = A >> 1;						//sari 1
				Y[31] = Y[30];
				if (Y == 0) Zero = 1;
				else Zero = 0;
			end
			14:begin
				Y = decoder_out;
				if (Y == 0) Zero = 1;
				else Zero = 0;
			end
			15:begin
				Y = arbiter_out;
				if (Y == 0) Zero = 1;
				else Zero = 0;
			end
			default: begin
				Y = {31{1'b0}};
				Zero = 1'b1;
			end
		endcase
	end
	//include exist modules
	AND my_and (.a(A[0]), .b(B[0]), .c(and_out));
	OR my_or (.a(A[0]), .b(B[0]), .c(or_out));
	NOT my_not (.a(A[0]), .b(not_out));
	XOR my_xor (.a(A[0]), .b(B[0]), .c(xor_out));
	XNOR my_xnor (.a(A[0]), .b(B[0]), .c(xnor_out));
	NOR my_nor (.a(A[0]), .b(B[0]), .c(nor_out));
	Arbiter my_arbiter (.r(A[5-1:0]), .g(arbiter_out));
	Decoder my_decoder (.a(A[5-1:0]), .b(decoder_out));
endmodule 

module Arbiter(r, g); // find-first-one unit
	input [5 - 1 : 0] r;
	output[5 - 1 : 0] g;
	reg [5-1:0] g;

	always@* begin
		g = {5{1'b0}};
		if (r[0] == 1'b1) g[0] = 1'b1;
		else if (r[1] == 1'b1) g[1] = 1'b1;
		else if (r[2] == 1'b1) g[2] = 1'b1;
		else if (r[3] == 1'b1) g[3] = 1'b1;
		else if (r[4] == 1'b1) g[4] = 1'b1;
	end

endmodule

module Decoder(a, b); // binary to one-hot decoder
	input [5 - 1 : 0] a;
	output[32- 1 : 0] b;
	reg [32-1:0] b;

	always@(*)begin
		b = {32{1'b0}};
		case (a)
			0: b[0] = 1;
			1: b[1] = 1;
			2: b[2] = 1;
			3: b[3] = 1;
			4: b[4] = 1;
			5: b[5] = 1;
			6: b[6] = 1;
			7: b[7] = 1;
			8: b[8] = 1;
			9: b[9] = 1;
			10: b[10] = 1;
			11: b[11] = 1;
			12: b[12] = 1;
			13: b[13] = 1;
			14: b[14] = 1;
			15: b[15] = 1;
			16: b[16] = 1;
			17: b[17] = 1;
			18: b[18] = 1;
			19: b[19] = 1;
			20: b[20] = 1;
			21: b[21] = 1;
			22: b[22] = 1;
			23: b[23] = 1;
			24: b[24] = 1;
			25: b[25] = 1;
			26: b[26] = 1;
			27: b[27] = 1;
			28: b[28] = 1;
			29: b[29] = 1;
			30: b[30] = 1;
			31: b[31] = 1;
		endcase
	end

endmodule

module AND (a, b, c);
	input  a, b;
	output c;

	wire nand0;

	nand nand_first(nand0, a, b);
	nand nand_final(c, nand0, nand0);

endmodule

module OR (a, b, c);
	input  a, b;
	output c;
	
	wire nota, notb;

	nand not_a(nota, a, a);
	nand not_b(notb, b, b);
	nand nand_final(c, nota, notb);
endmodule

module NOT (a, b);
	input  a;
	output b;

	nand nand_final(b, a, a);
	
endmodule

module XOR (a, b, c);
	input  a, b;
	output c;

	wire nota, notb,nand1, nand2;

	nand not_a (nota, a, a);
	nand not_b (notb, b, b);
	nand nand_1 (nand1, a, notb);
	nand nand_2 (nand2, nota, b);
	nand nand_final (c, nand1, nand2);
endmodule

module XNOR (a, b, c);
	input  a, b;
	output c;
	
	wire nota, notb,nand1, nand2;

	nand not_a (nota, a, a);
	nand not_b (notb, b, b);
	nand nand_1 (nand1, a, b);
	nand nand_2 (nand2, nota, notb);
	nand nand_final (c, nand1, nand2);
endmodule

module NOR (a, b, c);
	input  a, b;
	output c;
	
	wire nota, notb, wire3;

	nand not_a(nota, a, a);
	nand not_b(notb, b, b);
	nand nand_or(wire3, nota, notb);
	nand nand_final(c, wire3, wire3);
endmodule