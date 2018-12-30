module testbench();
	reg clk;
	reg reset;
	
	wire [31:0] writedata, dataadr;
	wire        memwrite;
	
	reg [31:0] wdexpected, daexpected;
	
	reg [31:0] vectornum, errors;
	reg [63:0] testvectors[10000:0];
	wire cond1, cond2;
	
	top dut(clk, reset, writedata, dataadr, memwrite);
	
	initial
	begin
		$readmemh("testvector.dat", testvectors);
		vectornum = 0; errors = 0;
		reset <= 1; #22; reset <= 0;
	end
	
	always
	   begin 
		   clk <= 1; #5; clk <= 0; #5;
		end

	always@(posedge memwrite)
	   begin 
		   #1 {daexpected, wdexpected} = testvectors[vectornum];
			if((dataadr !== daexpected) || (writedata !== wdexpected)) begin
				//$display (“Error: inputs = %b”, {a, b, c});
				$display ("Error: Data Address = %d (%d expected)", dataadr, daexpected);
				$display ("Error: Write Data = %d (%d expected)", writedata, wdexpected);
				errors = errors + 1;
			end
			vectornum = vectornum + 1;
			if (testvectors[vectornum] === 64'bx) begin
				$display ("%d tests completed with %d errors", vectornum, errors);
				$stop;
			end
		end
endmodule
