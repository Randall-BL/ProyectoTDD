module arm(
    input  logic         clk, reset,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic         MemWrite,
    output logic [31:0] ALUResult, WriteData,
    input  logic [31:0] ReadData,
    
    // *** AGREGAR ESTAS NUEVAS SALIDAS PARA EL MONITOR ***
    output logic        RegWrite,    // Exponer señal de escritura de registros
    output logic        MemtoReg,    // Exponer selección de fuente de datos
    output logic [3:0]  A3,          // Registro destino
    
    // Puertos de salida para registros (ya existían)
    output logic [31:0] R0_val,
    output logic [31:0] R1_val,
    output logic [31:0] R2_val,
    output logic [31:0] R3_val,
    output logic [31:0] R7_val
);
    // Señales internas de control
    logic [1:0]  RegSrc;
    logic        RegWrite_internal;  // Renombrar la señal interna
    logic [1:0]  ImmSrc;
    logic [1:0]  ALUSrc;
    logic [2:0]  ALUControl;
    logic        MemtoReg_internal;  // Renombrar la señal interna
    logic        PCSrc;
    logic        BL;
    logic        ShiftEn;
    logic [3:0]  ALUFlags;
    
    // *** ASIGNAR LAS SEÑALES INTERNAS A LAS SALIDAS ***
    assign RegWrite = RegWrite_internal;
    assign MemtoReg = MemtoReg_internal;
    assign A3 = Instr[15:12];  // El registro destino típicamente está en los bits [15:12]
    
    // Instancia del controller
    controller c(
        .clk        (clk),
        .reset      (reset),
        .Instr      (Instr),
        .ALUFlags   (ALUFlags),
        .RegSrc     (RegSrc),
        .RegWrite   (RegWrite_internal),    // Usar la señal interna
        .ImmSrc     (ImmSrc),
        .ALUSrc     (ALUSrc),
        .ALUControl (ALUControl),
        .MemWrite   (MemWrite),
        .MemtoReg   (MemtoReg_internal),    // Usar la señal interna
        .PCSrc      (PCSrc),
        .BL         (BL),
        .ShiftEn    (ShiftEn)
    );
    
    // Instancia del datapath
    datapath dp(
        .clk(clk),
        .reset(reset),
        .RegSrc(RegSrc),
        .RegWrite(RegWrite_internal),       // Usar la señal interna
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemtoReg(MemtoReg_internal),       // Usar la señal interna
        .PCSrc(PCSrc),
        .BL(BL),
        .ShiftEn(ShiftEn),
        .MemWrite(MemWrite),                // *** AGREGAR CONEXIÓN FALTANTE ***
        .PC(PC),
        .Instr(Instr),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .ALUFlags(ALUFlags),
        .r0_val(R0_val),
        .r1_val(R1_val),
        .r2_val(R2_val),
        .r3_val(R3_val),
        .r7_val(R7_val)
    );
endmodule