module decoder(
    input logic [1:0] Op,
    input logic [5:0] Funct,
    input logic [3:0] Rd,
    input logic [3:0] Mul,
    input logic [3:0] movhi_field, // Renombrado para evitar conflicto con la variable interna movhi
    output logic [1:0] FlagW,
    output logic PCS,RegW,MemW,NoWrite,
    output logic MemtoReg,
    output logic [1:0] ALUSrc,      // Ahora de 2 bits
    output logic [1:0] ImmSrc,RegSrc,
    output logic [2:0] ALUControl,
    output logic BL,                // Señal para Branch and Link
    output logic ShiftEn           // Señal para habilitar el shifter
);

    logic Branch, ALUOp; // Señales internas que se usarán en las asignaciones

    // Inicializar todas las salidas a un estado seguro por defecto
    // Esto es muy importante para synthesizable FSMs (aunque este es combinacional)
    // y para evitar latches implícitos.
    always_comb begin
        // Valores por defecto (para una instrucción no implementada o segura)
        RegSrc = 2'b00;
        ImmSrc = 2'b00;
        ALUSrc = 2'b00; // Por defecto: Operando de registro (no shifteado)
        MemtoReg = 1'b0;
        RegW = 1'b0;
        MemW = 1'b0;
        Branch = 1'b0;
        ALUOp = 1'b0;
        NoWrite = 1'b0; // Por defecto, se permite la escritura
        BL = 1'b0;      // Por defecto, no es Branch and Link
        ShiftEn = 1'b0; // Por defecto, no hay shift
        ALUControl = 3'b000; // Por defecto un ADD o un valor neutro
        FlagW = 2'b00;
        PCS = 1'b0;

        case(Op)
            2'b00: begin // Data-processing (Immediate/Register)
                // Default settings for Data-processing operations (most common)
                RegW = 1'b1;     // Most DP instructions write to register
                MemtoReg = 1'b0; // Result comes from ALU
                MemW = 1'b0;     // No memory write
                Branch = 1'b0;   // Not a direct branch
                ALUOp = 1'b1;    // Is an ALU operation

                // Determine ImmSrc, ALUSrc, RegSrc, ShiftEn based on Funct and Instr bits
                // Assuming Instr[25] determines Immediate vs Register based on ARM standard
                // and Instr[4] determines Shift by Register vs Immediate/No Shift
                if (Funct[5]) begin // Immediate
                    ImmSrc = 2'b01; // Use immediate
                    ALUSrc = 2'b01; // ALU B source is immediate
                    ShiftEn = 1'b0; // No shifter for immediate operand
                end else begin // Register
                    ImmSrc = 2'b00; // No immediate used for Immsrc, but ALUSrc might be 0
                    ALUSrc = 2'b00; // ALU B source is PreSrcB (register potentially shifteado)
                    // Check if there is a shift operation based on Instr[4]
                    if (Rd[0] == 1'b1) begin // This is just an example, check ARM docs for exact bit
                        ShiftEn = 1'b1; // Habilitar el shifter
                    end
                end

                // Specific Data-processing instructions
                if(Funct[5] & Funct[4:1] == 4'b1010) begin // CMP Immediate
                    NoWrite = 1'b1; // Do not write result to register
                    ALUControl = 3'b001; // SUB for CMP
                end else if(!Funct[5] & Funct[4:1] == 4'b1010) begin // CMP Register
                    NoWrite = 1'b1; // Do not write result to register
                    ALUControl = 3'b001; // SUB for CMP
                end else if(Funct[5] & Funct[4:1] == 4'b1101) begin // MOV Immediate (e.g., MOV R0, #10)
                    ALUControl = 3'b101; // MOV operation in ALU
                end else if(!Funct[5] & Funct[4:1] == 4'b1101 && movhi_field == 4'b1000) begin // MOVHI
                    ALUControl = 3'b110; // (Assuming 3'b110 is for MOVHI in ALU)
                end else if (Funct[5] & Funct[4:1] == 4'b1000) begin // MOVW
                    ALUControl = 3'b101; // MOV operation
                    ImmSrc = 2'b10; // Assuming ImmSrc=2'b10 is for MOVW/MOVT type immediates
                    ALUSrc = 2'b01; // ALU B source is immediate
                end else if (!Funct[5] & Funct[4:1] == 4'b0000 && Mul == 4'b1001) begin // MUL
                    ALUControl = 3'b100; // MUL operation
                end else if (Funct[5] & Funct[4:1] == 4'b0000) begin // AND Immediate
                    ALUControl = 3'b010; // AND operation
                end else if (!Funct[5] & Funct[4:1] == 4'b0000) begin // AND Register
                    ALUControl = 3'b010; // AND operation
                end
                // Add more DP operations here following similar pattern (ADD, SUB, ORR, etc.)
                // Example for ADD/SUB/ORR (if not covered by defaults/AND):
                case(Funct[4:1])
                    4'b0100: ALUControl = 3'b000; // ADD
                    4'b0010: ALUControl = 3'b001; // SUB
                    // ... other operations (ORR 4'b1100, etc.)
                    4'b1100: ALUControl = 3'b011; // ORR
                    default: ALUControl = 3'b000; // Default for unhandled DP is ADD, or X if truly undefined
                endcase
            end

            2'b01: begin // LDR/STR (Load/Store)
                RegW = 1'b1;     // LDR writes to register
                MemW = 1'b0;     // LDR doesn't write to memory
                MemtoReg = 1'b1; // LDR reads from memory
                ALUSrc = 2'b01;  // Address calculation uses immediate
                ALUOp = 1'b1;    // ALU used for address calculation (ADD)
                ALUControl = 3'b000; // ADD for address calculation
                // Note: RegSrc, ImmSrc, Branch, NoWrite, BL, ShiftEn default to 0

                if(Funct[0]) begin // LDR
                    // Defaults set above are for LDR
                end else begin // STR
                    RegW = 1'b0;     // STR doesn't write to register
                    MemW = 1'b1;     // STR writes to memory
                    MemtoReg = 1'b0; // STR doesn't read from memory to register
                end
            end

            2'b10: begin // B (Branch)
                RegW = 1'b0;
                MemW = 1'b0;
                MemtoReg = 1'b0;
                ALUSrc = 2'b00;
                ALUOp = 1'b0; // No ALU operation needed for branch target calc if just PC+offset
                Branch = 1'b1; // It is a branch
                PCS = 1'b1;    // Branch changes PC (handled by PCSrc in datapath)
                // Lógica para BL (Branch with Link):
                // Asumo que BL es un bit dentro del campo Funct o Instr. Por ejemplo, Instr[31] o Funct[0]
                // Esto es un placeholder, debes verificar la especificación ARM real para tu BL.
                // Si tu instrucción de Branch (Op=2'b10) tiene un bit que indica BL, ponlo aquí.
                if (Funct[4]) begin // Example: if Funct[4] is the BL bit
                    BL = 1'b1; // Activa Branch and Link
                end
            end

            default: begin // Unimplemented
                // Todas las señales ya están en sus valores por defecto (0) al inicio del always_comb
            end
        endcase

        // Lógica común para FlagW y NoWrite
        // Esta parte es tu ALUDecoder, pero ahora integrado en el mismo always_comb
        if(ALUOp)begin // Si es una instrucción de procesamiento de datos
             // ALUControl se asigna dentro del case(Op) para cada instrucción
             // NoWrite se asigna dentro del case(Op) para CMP

             // FlagW (determina si las flags se actualizan)
             FlagW[1] = Funct[0]; // Bit S (update all flags if S is set)
             FlagW[0] = Funct[0] & (ALUControl == 3'b000 || ALUControl == 3'b001); // C y V solo para aritméticas si S está set
        end else begin
            // Si no es ALUOp (e.g., LDR, STR, B), no actualizar flags
            FlagW = 2'b00;
        end

        // PCS (Program Counter Source)
        // Ya lo tienes bien en tu diseño original
        PCS = ((Rd==4'b1111) & RegW) | Branch; // Rd = R15 y se escribe, o es una instrucción Branch
    end

endmodule