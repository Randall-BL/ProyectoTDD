module controller(
    input logic clk, reset,
    input logic [31:0] Instr,
    input logic [3:0] ALUFlags, // ALUFlags desde el datapath, va a condlogic

    output logic [1:0] RegSrc,
    output logic RegWrite,
    output logic [1:0] ImmSrc,
    output logic [1:0] ALUSrc,
    output logic [2:0] ALUControl,
    output logic MemWrite,
    output logic MemtoReg,
    output logic PCSrc,
    output logic BL,
    output logic ShiftEn
);

    // Señales internas para el decoder y condlogic
    logic [1:0] FlagW;
    logic PCS, RegW, MemW, NoWrite;
    logic decoder_BL, decoder_ShiftEn; // Salidas del decoder

    // Instancia del decoder
    decoder dec(
        .Op         (Instr[27:26]),
        .Funct      (Instr[25:20]),
        .Rd         (Instr[15:12]),
        .Mul        (Instr[7:4]),
        .movhi_field(Instr[31:28]),
        .FlagW      (FlagW),
        .PCS        (PCS),
        .RegW       (RegW),
        .MemW       (MemW),
        .NoWrite    (NoWrite),
        .MemtoReg   (MemtoReg),
        .ALUSrc     (ALUSrc),
        .ImmSrc     (ImmSrc),
        .RegSrc     (RegSrc),
        .ALUControl (ALUControl),
        .BL         (decoder_BL),
        .ShiftEn    (decoder_ShiftEn)
    );

    // Conecta las salidas del decoder a los puertos de salida del controller
    assign BL = decoder_BL;
    assign ShiftEn = decoder_ShiftEn;

    // Instancia del condlogic (maneja la lógica de ejecución condicional)
    condlogic cl(
        .clk(clk),
        .reset(reset),
        .Cond (Instr[31:28]), // <--- ¡CAMBIO CRÍTICO AQUÍ! 'Cond' con C mayúscula.
        .ALUFlags(ALUFlags),
        .FlagW(FlagW),
        .PCS(PCS),
        .RegW(RegW),
        .MemW(MemW),
        .NoWrite(NoWrite),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite)
    );

endmodule