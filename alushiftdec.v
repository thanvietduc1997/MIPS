module alushiftdec(
		input  [5:0] funct,
		input  [1:0] alushiftop,
		output [2:0] alucontrol,
		output [1:0] shiftcontrol,
		output shift,
		output jumpr,
		output [1:0] move
	);
	
	reg [8:0] parse;
	always@(*)
	case(alushiftop)
	   2'b00:        parse <= 9'b0000xx010; //add
		2'b01:        parse <= 9'b0000xx110; //subtract
		default: case(funct)
		   6'b100000: parse <= 9'b0000xx010; //add
			6'b100010: parse <= 9'b0000xx110; //subtract
			6'b100100: parse <= 9'b0000xx000; //and
			6'b100101: parse <= 9'b0000xx001; //or
			6'b100110: parse <= 9'b0000xx100; //xor
			6'b100111: parse <= 9'b0000xx101; //nor
			6'b101010: parse <= 9'b0000xx011; //slt
			6'b000000: parse <= 9'b000100xxx; //sll
			6'b000010: parse <= 9'b000110xxx; //srl
			6'b000011: parse <= 9'b000111xxx; //sra
			6'b001000: parse <= 9'b0010xxxxx; //jump register
			6'b011000: parse <= 9'b0000xx111; //mult
			6'b010000: parse <= 9'b1000xxxxx; //move from hi
			6'b010010: parse <= 9'b0100xxxxx; //move from lo
			default:   parse <= 9'b000xxxxxxx;
		endcase
	endcase
	
	assign move = parse[8:7];
	assign jumpr = parse[6];
	assign shift = parse[5];
	assign shiftcontrol = parse[4:3];
	assign alucontrol = parse[2:0];
endmodule
