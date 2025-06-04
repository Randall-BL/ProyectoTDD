module arm(
    input  logic        clk, reset,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic        MemWrite,
    output logic [31:0] ALUResult, WriteData,
    input  logic [31:0] ReadData
);
    // Señales internas de control
    logic [1:0]  RegSrc;
    logic        RegWrite;
    logic [1:0]  ImmSrc;
    logic [1:0]  ALUSrc;
    logic [1:0]  ALUControl;
    logic        MemtoReg;
    logic        PCSrc;
    logic        BL;
    logic        ShiftEn;
    logic [3:0]  ALUFlags;
	 logic [1:0]  Op; 

    // Instancia del controller
    controller c(clk,reset,Instr,ALUFlags,
				 RegSrc,RegWrite,ImmSrc,ALUSrc,ALUControl,
             MemWrite,MemtoReg,PCSrc);

    // Instancia del datapath
    datapath dp(
        .clk(clk),
        .reset(reset),
        .RegSrc(RegSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc),
        .PC(PC),
        .Instr(Instr),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .ALUFlags(ALUFlags)
    );

endmodule