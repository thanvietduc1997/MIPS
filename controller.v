module controller(
						input  [5:0] op, 
						input  [5:0] funct,
						output       memtoreg, 
						output       memwrite,
						output       branch,
						output       alusrc,
						output       regdst, 
						output       regwrite,
						output       jump,
						output       link,
						output       shift,
						output       jumpr,
						output [2:0] alucontrol,
						output [1:0] shiftcontrol,
						output [1:0] move
						);
	
	wire [1:0] alushiftop;
	maindec maindec(
		.op(op),
		.memtoreg(memtoreg),
		.memwrite(memwrite),
		.branch(branch),
		.alusrc(alusrc),
		.regdst(regdst),
		.regwrite(regwrite),
		.jump(jump),
		.link(link),
		.alushiftop(alushiftop)
	);
	alushiftdec asd(
		.funct(funct),
		.alushiftop(alushiftop),
		.alucontrol(alucontrol),
		.shiftcontrol(shiftcontrol),
		.shift(shift),
		.jumpr(jumpr),
		.move(move)
	);
endmodule
