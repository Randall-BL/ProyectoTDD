module datapath(
    input  logic         clk, reset,
    input  logic [1:0]   RegSrc,
    input  logic         RegWrite,
    input  logic [1:0]   ImmSrc,
    input  logic [1:0]   ALUSrc,
    input  logic [2:0]   ALUControl,
    input  logic         MemWrite,
    input  logic         MemtoReg,
    input  logic         PCSrc,
    input  logic         BL,
    input  logic         ShiftEn,
    output logic [31:0] PC,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    input  logic [31:0] ReadData,
    input  logic [31:0] Instr,
    output logic [3:0]  ALUFlags,
    // ******* PUERTOS DE SALIDA PARA MONITOREAR REGISTROS ********
    output logic [31:0] r0_val,
    output logic [31:0] r1_val,
    output logic [31:0] r2_val,
    output logic [31:0] r3_val,
    output logic [31:0] r7_val // Puerto de salida para R7
);
    // Señales internas
    logic [31:0] PCNext, PCPlus4, PCPlus8;
    logic [31:0] Result;
    logic [3:0]  RA1, RA2; // Direcciones de lectura para el Register File
    logic [31:0] RD1, RD2;
    logic [31:0] ExtImm;
    logic [31:0] SrcA, SrcB;
    logic [31:0] ALUOut;
    
    // Señales para shifter
    logic [31:0] ShiftedRD2;
    logic [31:0] PreSrcB; // Salida del mux de shifter

    // Señal para la dirección de escritura en el registro
    logic [3:0]  WriteReg_addr;


    // Lógica del Program Counter (PC)
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

    // MUX para selección de PCNext (salto o PC+4)
    mux2 #(32) pcmux(
        .d0(PCPlus4),
        .d1(Result), // Result es el target del salto si PCSrc es 1
        .s(PCSrc),
        .y(PCNext)
    );

    // Lógica del Banco de Registros (Direcciones de Lectura)
    mux2 #(4) ra1mux(
        .d0(Instr[19:16]), // Rn para Data Processing y LDR/STR (base)
        .d1(4'b1111),      // R15 (PC)
        .s(RegSrc[0]),     // Este RegSrc puede seleccionar la fuente de RA1
        .y(RA1)            // La salida de este mux es RA1
    );

    mux2 #(4) ra2mux(
        .d0(Instr[3:0]),   // Rm para Data Processing register-register
        .d1(Instr[15:12]), // Rd (Destination Register) para LDR/STR offset (Rn)
        .s(RegSrc[1]),     // Este RegSrc puede seleccionar la fuente de RA2
        .y(RA2)            // La salida de este mux es RA2
    );

    // Generación de la dirección de escritura (Rd)
    // Para las instrucciones ADD y LDR, el registro destino es Instr[15:12] (Rd)
    // Si hay otros tipos de instrucción que escriban en otro Rd, esto necesitará un multiplexor (RegDst)
    assign WriteReg_addr = Instr[15:12];


    // MUX para seleccionar el valor a escribir en el registro destino (incluye PC+8 para BL)
    logic [31:0] WriteValue;
    mux2 #(32) link_mux(
        .d0(Result),   // Resultado de la ALU o dato de memoria (para LDR/ALU ops)
        .d1(PCPlus8),  // PC+8 para guardar en R14 (Link Register) en un BL
        .s(BL),        // Control de BL
        .y(WriteValue) // Este es el valor FINAL que se escribe en el REGISTRO
    );

    // ******* INSTANCIA DEL REGISTER_FILE CON LAS CONEXIONES CORREGIDAS *******
    register_file rf_inst( // Se renombra a rf_inst para evitar conflictos con el nombre de la señal si existiera
        .clk(clk),
        .reset(reset),
        .we3(RegWrite),
        .ra1(RA1),             // Conectado a la salida de ra1mux
        .ra2(RA2),             // Conectado a la salida de ra2mux
        .wa3(WriteReg_addr),   // Conectado a la dirección de escritura
        .wd3(WriteValue),      // Valor a escribir en el registro
        .r15(PCPlus8),         // Asumiendo que PCPlus8 es para R15
        .rd1(RD1),             // Salidas de datos de lectura
        .rd2(RD2),
        .r0_out(r0_val),       // Puertos de monitoreo
        .r1_out(r1_val),
        .r2_out(r2_val),
        .r3_out(r3_val),
        .r7_out(r7_val)        // ¡CONEXIÓN DE R7 A SU PUERTO DE SALIDA!
    );

    // Módulo de extensión de signo/cero para inmediatos
    extend ext(
        .Instr(Instr[23:0]), // Bits de la instrucción para el inmediato
        .ImmSrc(ImmSrc),
        .ExtImm(ExtImm)
    );

    // Instancia del shifter
    shifter shift_inst(
        .shift_amount (Instr[11:7]), // Cantidad de shift (si es por inmediato o registro)
        .shift_type   (Instr[6:5]),  // Tipo de shift (LSL, LSR, ASR, ROR)
        .mul          (Instr[4]),    // Bit para indicar MUL o register-shift
        .rd2          (RD2),         // Operando a desplazar (normalmente el segundo operando del registro)
        .data         (ShiftedRD2)   // Salida del shifter
    );

    // MUX para seleccionar entre RD2 original y RD2 shifteado
    mux2 #(32) shift_mux(
        .d0(RD2),          // RD2 sin shift
        .d1(ShiftedRD2),   // RD2 shifteado
        .s(ShiftEn),       // Selector: 0 para sin shift, 1 para shifteado
        .y(PreSrcB)        // Segundo operando de la ALU antes de seleccionar el inmediato
    );

    // Lógica de la ALU
    assign SrcA = RD1; // Primer operando de la ALU siempre de RD1 (primer registro leído)
    
    // MUX para seleccionar el segundo operando de la ALU (SrcB)
    mux2 #(32) srcbmux(
        .d0(PreSrcB),      // Operando desde el registro (posiblemente shifteado)
        .d1(ExtImm),       // Operando inmediato extendido
        .s(ALUSrc[0]),     // Selector del MUX (usa el bit 0 de ALUSrc)
        .y(SrcB)
    );

    // Instancia de la ALU principal
    alu main_alu(
        .A           (SrcA),
        .B           (SrcB),
        .ALU_Sel     (ALUControl),
        .ALU_Result  (ALUOut),
        .ALU_Flags   (ALUFlags) // ALUFlags sale directamente de la ALU
    );
    
    // Asignación de la salida de la ALU a ALUResult
    assign ALUResult = ALUOut;

    // Dato a escribir en la memoria de datos (¡CRÍTICO para STR!)
    // El valor que se guarda en la memoria de datos (dmem) en una instrucción STR
    // siempre proviene de un registro (generalmente RD2).
    assign WriteData = RD2;

    // MUX final para seleccionar el valor que se escribirá de vuelta en el banco de registros
    // (resultado de ALU o dato leído de memoria)
    mux2 #(32) resmux(
        .d0(ALUResult), // Resultado de la operación de la ALU
        .d1(ReadData),  // Dato leído de la memoria (para LDR)
        .s(MemtoReg),   // Selector: 0 para ALUResult, 1 para ReadData
        .y(Result)      // El valor final que se escribe en el registro destino
    );

endmodule