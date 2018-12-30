module top(input clk, reset, output [31:0] writedataout, aluoutout, output memwriteout);
   wire [31:0] pcf, pcplus4f, pcplus4d, instrf, instrd, pcbranchd;
	wire regwrited, regwritee, regwritem, regwritew;
	wire memtoregd, memtorege, memtoregm, memtoregw;
	wire memwrited, memwritee, memwritem;
	wire branchd, equald;
	wire [2:0] alucontrold, alucontrole;
	wire alusrcd, alusrce;
	wire regdstd, regdste;
	wire [31:0] srcad, srchae, srcae, adhazard, bdhazard;
	wire [31:0] writedatad, writedatahe, writedatae, writedatam;
	wire [31:0] srcbe;
	wire [4:0] rsd, rtd, rdd, rse, rte, rde, shamtd, shamte;
	wire [4:0] writerege, writeregm, writeregw;
	wire pcsrcd;
	wire [31:0] aluoute, aluoutm, aluoutw, readdatam, readdataw, resultw;
	wire [31:0] ShiftOutE;
	wire [31:0] ShiftOutM;
	wire [31:0] ShiftOutW;
	wire ShiftD;
	wire ShiftE;
	wire ShiftM;
	wire ShiftW;
	wire [31:0] pcnext, signimmd, signimme, signimmshd, pcmux;
	wire stallf, stalld, forwardad, forwardbd, flushe;
	wire [2:0] forwardae, forwardbe;
	wire [1:0] shiftcontrold, shiftcontrole;
	wire jumpd;
	wire clrIFID;
	wire [31:0] pcj;
	wire [31:0] ALUSelectData;
	wire linkd;
	wire [4:0] waSel;
	wire [31:0] wdSel;
	wire weSel;
	wire jumprd;
	wire [31:0] pcrd1;
	wire [31:0] pcjr;
	wire [31:0] hi;
	wire [31:0] lo;
	wire [1:0] moveD;
	wire [31:0] hiOut;
	wire [31:0] loOut;
	wire sel1;
	wire sel0;
	wire [31:0] writeDataSel;
	
	assign aluoutout = aluoutm;
	assign memwriteout = memwritem;
	assign writedataout = writedatam;
	
	
	// Fetch stage
	assign pcrd1 = srcad; // gia tri cua rs
	mux2 pcJumpR(
		.d0(pcplus4f),
		.d1(pcrd1),
		.s(jumprd),
		.y(pcjr)
	);
	wire a;
	mux2 #(32) pcJump(
		.d0(pcjr), 
		.d1({pcplus4d[31:28], instrd[25:0], 2'b00}), 
		.s(jumpd), 
		.y(pcj)
	);
	
	mux2 #(32) pcnextmux(
		.d0(pcj), 
		.d1(pcbranchd), 
		.s(pcsrcd), 
		.y(pcnext)
	);
	
	register #(32) pc(
		.clk(clk), 
		.reset(reset), 
		.en(stallf), 
		.clear(1'b0), 
		.din(pcnext), 
		.dout(pcf)
	);
	
	imem imem(pcf[7:2], instrf);
	
	assign pcplus4f = pcf + 32'b100;

	// register IF/ID
	assign clrIFID = pcsrcd | jumpd | jumprd;
	register #(32) ifid_instr(
		.clk(clk), 
		.reset(reset), 
		.en(stalld), 
		.clear(clrIFID), 
		.din(instrf), 
		.dout(instrd)
   );
	register #(32) ifid_pc4fd(
		.clk(clk), 
		.reset(reset), 
		.en(stalld), 
		.clear(clrIFID), 
		.din(pcplus4f), 
		.dout(pcplus4d)
	);
	
	// Decode stage
	controller c(
		.op(instrd[31:26]),
		.funct(instrd[5:0]),
		.memtoreg(memtoregd),
		.memwrite(memwrited),
		.branch(branchd),
		.alusrc(alusrcd),
		.regdst(regdstd),
		.regwrite(regwrited),
		.jump(jumpd),
		.jumpr(jumprd),
		.move(moveD),
		.link(linkd),
		.shift(ShiftD),
		.alucontrol(alucontrold),
		.shiftcontrol(shiftcontrold)
	);
	
	assign sel1 = (~regwritew) & (~linkd) & (^moveD);
	assign sel0 = (~regwritew) & (~linkd) & (moveD[1]) & (~moveD[0]) | (~regwritew) & (linkd) & (~moveD[1]);
	
	mux4 #(5) writeMoveAdrSel(writeregw, 5'b11111, rsd, rsd, {sel1, sel0}, waSel);
	mux4 writeMoveDatSel(resultw, pcplus4d, loOut, hiOut, {sel1, sel0}, wdSel);
	
	assign weSel = regwritew || linkd || moveD;
	regfile rf(
		.clk(clk), 
		.reset(reset), 
		.we3(weSel), 
		.ra1(instrd[25:21]), 
		.ra2(instrd[20:16]), 
		.wa3(waSel), 
		.wd3(wdSel), 
		.rd1(srcad), 
		.rd2(writedatad)
	);
	
	mux2 #(32) srcahmux(srcad, aluoutm, forwardad, adhazard);
	mux2 #(32) srcbhmux(writedatad, aluoutm, forwardbd, bdhazard);
	
	assign equald = (adhazard == bdhazard);
	assign pcsrcd = branchd & equald;
	assign rsd = instrd[25:21];
	assign rtd = instrd[20:16];
	assign rdd = instrd[15:11];
	assign shamtd = instrd[10:6];
	// sign extent
	assign signimmd = {{16{instrd[15]}}, instrd[15:0]};
	// sign extent + shift by 2
	assign signimmshd = {{14{instrd[15]}}, instrd[15:0], 2'b00};
	// pc branch
	assign pcbranchd = pcplus4d + signimmshd;
	
	// register ID/IE
	register #(32) idie_rd1(clk, reset, 1'b0, flushe, srcad, srchae);
	register #(32) idie_rd2(clk, reset, 1'b0, flushe, writedatad, writedatahe);
	register #(5) idie_rs(clk, reset, 1'b0, flushe, rsd, rse);
	register #(5) idie_rt(clk, reset, 1'b0, flushe, rtd, rte);
	register #(5) idie_rd(clk, reset, 1'b0, flushe, rdd, rde);
	register #(32) idie_signimm(clk, reset, 1'b0, flushe, signimmd, signimme);
	register #(1) idie_regwritede(clk, reset, 1'b0, flushe, regwrited, regwritee);
	register #(1) idie_memtoregde(clk, reset, 1'b0, flushe, memtoregd, memtorege);
	register #(1) idie_memwritede(clk, reset, 1'b0, flushe, memwrited, memwritee);
	register #(3) idie_alucontrolde(clk, reset, 1'b0, flushe, alucontrold, alucontrole);
	register #(1) idie_alusrcde(clk, reset, 1'b0, flushe, alusrcd, alusrce);
	register #(1) idie_regdstde(clk, reset, 1'b0, flushe, regdstd, regdste);
	register #(1) idie_ShiftDE(clk, reset, 1'b0, flushe, ShiftD, ShiftE);
	register #(5) idie_shamtde(
										.clk(clk),
										.reset(reset),
										.en(1'b0),
										.clear(flushe),
										.din(shamtd),
										.dout(shamte)
										);
	register #(2) idie_shctrlde(
									.clk(clk),
									.reset(reset),
									.en(1'b0),
									.clear(flushe),
									.din(shiftcontrold),
									.dout(shiftcontrole)
									);
	
	// Execute stage
	mux8 srchamux(srchae, resultw, aluoutm, 32'b0, 32'b0, ShiftOutW, ShiftOutM, 32'b0, forwardae, srcae);
	mux8 srchbmux(writedatahe, resultw, aluoutm, 32'b0, 32'b0, ShiftOutW, ShiftOutM, 32'b0, forwardbe, writedatae);
	//mux4 #(32) srchamux(srchae, resultw, aluoutm, 32'b0, forwardae, srcae); // select source A for ALU with hazard
	//mux4 #(32) srchbmux(writedatahe, resultw, aluoutm, 32'b0, forwardbe, writedatae); 
	mux2 #(32) srcbmux(writedatae, signimme, alusrce, srcbe);
   ALU alu(
		.SrcA(srcae), 
		.SrcB(srcbe), 
		.ALUControl(alucontrole), 
		.ALUResult(aluoute), 
		.Hi(hi), 
		.Lo(lo)
	);
	
	multireg hiReg(
		.clk(clk),
		.reset(reset),
		.we(&(alucontrole)),
		.wd(hi),
		.rd(hiOut)
	);
	multireg loReg(
		.clk(clk),
		.reset(reset),
		.we(&(alucontrole)),
		.wd(lo),
		.rd(loOut)
	);

	
	shift_operator so(
							.in(writedatae),
							.shamt(shamte), 
							.shiftcontrol(shiftcontrole),
							.out(ShiftOutE)
							);
	mux2 #(5) writeregmux(rte, rde, regdste, writerege);
	
	// register IE/IM
	register #(32) ieim_aluoutem(clk, reset, 1'b0, 1'b0, aluoute, aluoutm);
	register #(32) ieim_writedataem(clk, reset, 1'b0, 1'b0, writedatae, writedatam);
	register #(5) ieim_writeregem(clk, reset, 1'b0, 1'b0, writerege, writeregm);
	register #(1) ieim_regwriteem(clk, reset, 1'b0, 1'b0, regwritee, regwritem);
	register #(1) ieim_memtoregem(clk, reset, 1'b0, 1'b0, memtorege, memtoregm);
	register #(1) ieim_memwriteem(clk, reset, 1'b0, 1'b0, memwritee, memwritem);
	register #(32) ieim_shiftoutem(
		.clk(clk),
		.reset(reset),
		.en(1'b0),
		.clear(1'b0),
		.din(ShiftOutE),
		.dout(ShiftOutM)
	);
							
	register #(1) idie_ShiftEM(clk, reset, 1'b0, 1'b0, ShiftE, ShiftM);

	// Memory stage
	/*mux2 WriteDataMux(
		.d0(writedatam),
		.d1(ShiftOutM),
		.s(ShiftM),
		.y(writeDataSel)
	);*/
	dmem dmem(
		.clk(clk), 
		.we(memwritem), 
		.a(aluoutm), 
		.wd(writedatam), 
		.rd(readdatam)
	);
	
	// register IM/IW
	register #(32) imiw_aluoutmw(clk, reset, 1'b0, 1'b0, aluoutm, aluoutw);
	register #(32) imiw_readdatamw(clk, reset, 1'b0, 1'b0, readdatam, readdataw);
	register #(5) imiw_writeregw(clk, reset, 1'b0, 1'b0, writeregm, writeregw);
	register #(1) imiw_regwritemw(clk, reset, 1'b0, 1'b0, regwritem, regwritew);
	register #(1) imiw_memtoregmw(clk, reset, 1'b0, 1'b0, memtoregm, memtoregw);
	register #(1) ShiftMW(.clk(clk), .reset(reset), .en(1'b0), .clear(1'b0), .din(ShiftM), .dout(ShiftW));
	register #(32) ShiftOutMW(
									  .clk(clk),
									  .reset(reset),
									  .en(1'b0),
									  .clear(1'b0),
									  .din(ShiftOutM),
									  .dout(ShiftOutW)
									  );
	// Writeback stage
	mux2 #(32) SelectALU(aluoutw, readdataw, memtoregw, ALUSelectData);
	mux2 #(32) SelectShift(ALUSelectData, ShiftOutW, ShiftW, resultw);
	
	// Hazard Unit
	hazardunit hu(
		.rsd(rsd),
		.rtd(rtd),
		.rse(rse),
		.rte(rte),
		.writerege(writerege),
		.writeregm(writeregm),
		.writeregw(writeregw),
		.branchd(branchd),
		.memtorege(memtorege),
		.regwritee(regwritee),
		.memtoregm(memtoregm),
		.regwritem(regwritem),
		.regwritew(regwritew),
		.shiftm(ShiftM),
		.shiftw(ShiftW),
		.link(linkd),
		.move(moveD),
		.stallf(stallf),
		.stalld(stalld),
		.forwardad(forwardad),
		.forwardbd(forwardbd),
		.flushe(flushe),
		.forwardae(forwardae),
		.forwardbe(forwardbe)
	);
endmodule
