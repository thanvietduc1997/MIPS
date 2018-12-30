module shift_operator(
							 input [31:0] in,
							 input [4:0] shamt,
							 input [1:0] shiftcontrol,
							 output reg [31:0] out
							 );

	always@(*)
		case(shiftcontrol)
			2'b00: out <= in << shamt;
			2'b10: out <= in >> shamt;
			2'b11: out <= $signed(in) >>> shamt;
			default: out <= 32'bx;
		endcase
endmodule
