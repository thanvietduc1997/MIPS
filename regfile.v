module regfile(input clk, reset, we3, input [4:0] ra1, ra2, wa3, input [31:0] wd3, output [31:0] rd1, rd2);
	reg [31:0] rf[31:0];
	
	always@(posedge clk or posedge reset)
		if(reset) begin
			rf[0] <= 32'b0;
			rf[1] <= 32'b0;
			rf[2] <= 32'b0;
			rf[3] <= 32'b0;
			rf[4] <= 32'b0;
			rf[5] <= 32'b0;
			rf[6] <= 32'b0;
			rf[7] <= 32'b0;
			rf[8] <= 32'b0;
			rf[9] <= 32'b0;
			rf[10] <= 32'b0;
			rf[11] <= 32'b0;
			rf[12] <= 32'b0;
			rf[13] <= 32'b0;
			rf[14] <= 32'b0;
			rf[15] <= 32'b0;
			rf[16] <= 32'b0;
			rf[17] <= 32'b0;
			rf[18] <= 32'b0;
			rf[19] <= 32'b0;
			rf[20] <= 32'b0;
			rf[21] <= 32'b0;
			rf[22] <= 32'b0;
			rf[23] <= 32'b0;
			rf[24] <= 32'b0;
			rf[25] <= 32'b0;
			rf[26] <= 32'b0;
			rf[27] <= 32'b0;
			rf[28] <= 32'b0;
			rf[29] <= 32'b0;
			rf[30] <= 32'b0;
			rf[31] <= 32'b0;
		end
		else
			if(we3) rf[wa3] <= wd3;

	assign rd1 = (ra1 == wa3) ? wd3 : ((ra1 != 0)? rf[ra1] : 0);
	assign rd2 = (ra2 == wa3) ? wd3 : ((ra2 != 0)? rf[ra2] : 0);
endmodule
