module ALU(
			  input [31:0] SrcA,
			  input [31:0] SrcB,
			  input [2:0]  ALUControl,
			  output reg [31:0] ALUResult,
			  output reg [31:0] Hi,
			  output reg [31:0] Lo
			  );	  

always@(*)
	begin
		ALUResult = 32'b0;
		Hi = 32'b0;
		Lo = 32'b0;
		case(ALUControl)
			3'd0: ALUResult = (SrcA & SrcB); //and
			3'd1: ALUResult = (SrcA | SrcB); //or
			3'd2: ALUResult = (SrcA + SrcB); //add
			3'd3: ALUResult = (SrcA < SrcB) ? 1 : 0; //slt
			3'd4: ALUResult = (SrcA ^ SrcB); //xor
			3'd5: ALUResult = ~(SrcA | SrcB); //nor
			3'd6: ALUResult = (SrcA - SrcB); //sub
			3'd7: {Hi, Lo}  = (SrcA * SrcB); //mult
		endcase
	end
endmodule
