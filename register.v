module register #(parameter width = 32)(clk, reset, en, clear, din, dout);
	input clk;
	input reset;
	input en;
	input clear;
	input [width-1:0] din;
	output reg [width-1:0] dout;
	
	always@(posedge clk or posedge reset)
		if(reset)
			dout <= 0;
		else 
			if(~en)
				if(clear)
					dout <= 0;
				else
					dout <= din;
endmodule
