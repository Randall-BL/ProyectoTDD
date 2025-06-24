module condlogic(input logic clk, reset,
	input logic [3:0] Cond,
	input logic [3:0] ALUFlags,
	input logic [1:0] FlagW,
	input logic PCS, RegW, MemW, NoWrite,
	output logic PCSrc, RegWrite,
	MemWrite);
	
	logic [1:0] FlagWrite;
	
	logic CondEx;
	
	condcheck cc(Cond, ALUFlags, CondEx);
	
	assign FlagWrite = FlagW & {2{CondEx}};
	assign RegWrite = RegW & ~NoWrite & CondEx;
	assign MemWrite = MemW & CondEx;
	assign PCSrc = PCS & CondEx;
	
endmodule