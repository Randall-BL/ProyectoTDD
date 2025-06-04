module condlogic(input logic clk,reset,
	input logic [3:0] Cond,
	input logic [3:0] ALUFlags,
	input logic [1:0] FlagW,
	input logic PCS,RegW,MemW,NoWrite,
	output logic PCSrc,RegWrite,
	MemWrite);
	
	 logic [1:0] FlagWrite;
	 logic [3:0] Flags;
	 logic CondEx;
	 
	 flopr #(2) flagreg1(clk, reset, ALUFlags[3:2], Flags[3:2]);

	 flopr #(2) flagreg0(clk, reset, ALUFlags[1:0], Flags[1:0]);

		 
	 //write controls are conditional
	 condcheck cc(Cond, Flags, CondEx);
	 assign FlagWrite= FlagW & {2{CondEx}};
	 assign RegWrite = RegW & ~NoWrite & CondEx;
	 assign MemWrite = MemW & CondEx;
	 assign PCSrc = PCS & CondEx;
	 
endmodule 