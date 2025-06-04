module datapath(
    input  logic        clk, reset,
    input  logic [1:0]  RegSrc,
    input  logic        RegWrite,
    input  logic [1:0]  ImmSrc,
    input  logic [1:0]  ALUSrc,
    input  logic [2:0]  ALUControl,
    input  logic        MemWrite,
    input  logic        MemtoReg,
    input  logic        PCSrc,
    input  logic        BL,          // Nueva señal para Branch and Link
    input  logic        ShiftEn,     // Nueva señal para habilitar shift
    output logic [31:0] PC,
	 input  logic [1:0]  Op,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    input  logic [31:0] ReadData,
    input  logic [31:0] Instr,
    output logic [3:0]  ALUFlags
);
    // Señales internas existentes
    logic [31:0] PCNext, PCPlus4, PCPlus8;
    logic [31:0] Result;
    logic [3:0]  RA1, RA2;
    logic [31:0] RD1, RD2;
    logic [31:0] ExtImm;
    logic [31:0] SrcA, SrcB;
	 logic [31:0] ALUOut;
    
    // Nuevas señales para shift
    logic [31:0] ShiftedRD2;
    logic [31:0] PreSrcB;

    // Program Counter Logic con PCPlus8
    flopr #(32) pcreg(
        .clk(clk),
        .reset(reset),
        .d(PCNext),
        .q(PC)
    );

    adder #(32) pcadd4(
        .a(PC),
        .b(32'd4),
        .y(PCPlus4)
    );

    adder #(32) pcadd8(
        .a(PCPlus4),
        .b(32'd4),
        .y(PCPlus8)
    );

    // MUX para selección de valor a escribir en registro (incluye PCPlus8 para BL)
    mux2 #(32) pcmux(
        .d0(PCPlus4),
        .d1(Result),
        .s(PCSrc),
        .y(PCNext)
    );

    // Register File Logic
    mux2 #(4) ra1mux(
        .d0(Instr[19:16]),
        .d1(4'b1111),
        .s(RegSrc[0]),
        .y(RA1)
    );

    mux2 #(4) ra2mux(
        .d0(Instr[3:0]),
        .d1(Instr[15:12]),
        .s(RegSrc[1]),
        .y(RA2)
    );

    // Nuevo MUX para seleccionar entre Result y PCPlus8
    logic [31:0] WriteValue;
    mux2 #(32) link_mux(
        .d0(Result),
        .d1(PCPlus8),
        .s(BL),
        .y(WriteValue)
    );

    register_file rf(
        .clk(clk),
        .we3(RegWrite),
        .ra1(RA1),
        .ra2(RA2),
        .wa3(Instr[15:12]),
        .wd3(WriteValue),  // Para el valor a escribir
        .r15(PC),         // Conectamos r15 al PC
        .rd1(RD1),
        .rd2(RD2)
    );
    extend ext(
        .Instr(Instr[23:0]),
        .ImmSrc(ImmSrc),
        .ExtImm(ExtImm)
    );

    // Nuevo módulo shifter
    shifter shift(
	 Instr[11:7],Instr[6:5],Instr[4],RD2,WriteData
	 );

    // MUX para seleccionar entre RD2 normal y shifteado
    mux2 #(32) shift_mux(
        .d0(RD2),
        .d1(ShiftedRD2),
        .s(ShiftEn),
        .y(PreSrcB)
    );
    // ALU Logic (ahora usa PreSrcB)
    assign SrcA = RD1;
	 
    
    //mux3 #(32) srcbmux(
    //    .d0(PreSrcB),     // Ahora usa la salida del shifter
    //    .d1(ExtImm),
    //    .d2(32'd0),
    //    .s(ALUSrc),
    //    .y(SrcB)
    //);
	 
	 mux2 #(32) srcbmux(WriteData,ExtImm,ALUSrc,SrcB);

    alu main_alu(
        .A(SrcA),
        .B(SrcB),
        .ALU_Sel(ALUControl),
        .ALU_Result(ALUOut),
        .ALU_Flags(ALUFlags)
    );
	 
    // Selección final del resultado
    assign ALUResult = ALUOut;


    // WriteData para memoria (solo una asignación)
    //assign WriteData = RD2;  // Dato directo del registro para STR

    mux2 #(32) resmux(
        .d0(ALUResult),
        .d1(ReadData),
        .s(MemtoReg),
        .y(Result)
    );

endmodule