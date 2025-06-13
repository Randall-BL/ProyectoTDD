module arm(
    input  logic         clk, reset,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic         MemWrite,
    output logic [31:0] ALUResult, WriteData,
    input  logic [31:0] ReadData,
    // *** AGREGAR ESTOS PUERTOS DE SALIDA PARA REGISTROS ***
    output logic [31:0] R0_val, // Nombres consistentes con el testbench
    output logic [31:0] R1_val,
    output logic [31:0] R2_val,
    output logic [31:0] R3_val,
    output logic [31:0] R7_val  // <--- ¡Agrega este puerto!
);
    // Señales internas de control
    logic [1:0]  RegSrc;
    logic        RegWrite;
    logic [1:0]  ImmSrc;
    logic [1:0]  ALUSrc;
    logic [2:0]  ALUControl;
    logic        MemtoReg;
    logic        PCSrc;
    logic        BL;
    logic        ShiftEn;
    logic [3:0]  ALUFlags;

    // Instancia del controller
    controller c(
        .clk        (clk),
        .reset      (reset),
        .Instr      (Instr),
        .ALUFlags   (ALUFlags),
        .RegSrc     (RegSrc),
        .RegWrite   (RegWrite),
        .ImmSrc     (ImmSrc),
        .ALUSrc     (ALUSrc),
        .ALUControl (ALUControl),
        .MemWrite   (MemWrite),
        .MemtoReg   (MemtoReg),
        .PCSrc      (PCSrc),
        .BL         (BL),
        .ShiftEn    (ShiftEn)
    );

    // Instancia del datapath
    datapath dp( // Renombrado a dp para claridad
        .clk(clk),
        .reset(reset),
        .RegSrc(RegSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc),
        .BL(BL),
        .ShiftEn(ShiftEn),
        .PC(PC),
        .Instr(Instr),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .ALUFlags(ALUFlags),
        .r0_val(R0_val), // Conectando a los puertos de salida de arm
        .r1_val(R1_val),
        .r2_val(R2_val),
        .r3_val(R3_val),
        .r7_val(R7_val)  // <--- ¡Conecta R7_val aquí!
    );

endmodule