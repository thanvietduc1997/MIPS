module maindec(
					input  [5:0] op,
               output       memtoreg, 
					output       memwrite,
					output       branch,
					output       alusrc,
					output       regdst, 
					output       regwrite,
					output       jump,
					output		 link,
					output [1:0] alushiftop
					);
	reg [9:0] controls;
	assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, alushiftop, jump, link} = controls;
	
	always@(*)
	   case(op)
		   6'b000_000: controls <= 10'b110_000_1000; //R type
			6'b100_011: controls <= 10'b101_001_0000; //lw
			6'b101_011: controls <= 10'b001_010_0000; //sw
			6'b000_100: controls <= 10'b000_100_0100; //beq
			6'b001_000: controls <= 10'b101_000_0000; //addi
			6'b000_010: controls <= 10'b000_000_0010; //jump
			6'b000_011: controls <= 10'b000_000_0011; //jump and link
			default:    controls <= 10'bxxx_xxx_xxxx;
		endcase
endmodule
