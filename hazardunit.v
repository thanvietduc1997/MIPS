module hazardunit(
		rsd,
		rtd,
		rse,
		rte,
		writerege,
		writeregm,
		writeregw,
		branchd,
		memtorege,
		regwritee,
		memtoregm,
		regwritem,
		regwritew,
		shiftm,
		shiftw,
		link,
		move,

		stallf,
		stalld,
		forwardad,
		forwardbd,
		flushe,
		forwardae,
		forwardbe
	);
	input [4:0] rsd, rtd, rse, rte;
	input [4:0] writerege, writeregm, writeregw;
	input branchd, memtorege, regwritee, memtoregm, regwritem, regwritew;
	input shiftm, shiftw;
	input link;
	input [1:0] move;
	
	output reg stallf, stalld, forwardad, forwardbd, flushe;
	output reg [2:0] forwardae;
	output reg [2:0] forwardbe;
	reg lwstall;
	reg branchstall;
	reg jalstall;
	reg movstall;
	
	always@(*)
		begin
			if ((rse != 5'b0) && (rse == writeregm) && (regwritem))
				if(shiftm) forwardae <= 3'b110;
				else forwardae <= 3'b010;
			else if ((rse != 5'b0) && (rse == writeregw) && (regwritew))
				if(shiftw) forwardae <= 3'b101;
				else forwardae <= 3'b001;
			else forwardae <= 3'b000;
			
			if ((rte != 5'b0) && (rte == writeregm) && (regwritem))
				if(shiftm) forwardbe <= 3'b110;
				else forwardbe <= 3'b010;
			else if ((rte != 5'b0) && (rte == writeregw) && (regwritew))
				if(shiftw) forwardbe <= 3'b101;
				else forwardbe <= 3'b001;
			else forwardbe <= 3'b000;
			
			lwstall <= ((rsd == rte) || (rtd == rte)) && memtorege;
			
			forwardad <= (rsd != 5'b0) && (rsd == writeregm) && regwritem;
			forwardbd <= (rtd != 5'b0) && (rtd == writeregm) && regwritem;
			
			branchstall <= branchd && regwritee && (writerege == rsd || writerege == rtd) 
								|| branchd && memtoregm && (writeregm == rsd || writeregm == rtd);
			
			jalstall <= (link & regwritew);
			movstall <= (|move) & (regwritew | link);
			
			stallf <= lwstall | branchstall | jalstall | movstall;
			stalld <= lwstall | branchstall | jalstall | movstall;
			flushe <= lwstall | branchstall | jalstall | movstall;
		end
endmodule

		