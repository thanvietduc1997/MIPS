module multireg(
	clk,
	reset,
	we,
	wd,
	rd
);

	input clk;
	input reset;
	input we;
	input [31:0] wd;
	output [31:0] rd;
	
	reg [31:0] RAM;
	always@(posedge clk or posedge reset)
	if(reset)
		RAM <= 0;
	else if(we)
		RAM <= wd;
		
	assign rd = we ? wd : RAM;
endmodule
