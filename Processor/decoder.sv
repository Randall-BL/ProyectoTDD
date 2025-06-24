module decoder(
    input logic [1:0] Op,
    input logic [5:0] Funct,
    input logic [3:0] Rd,
    input logic [3:0] Mul,
    input logic [3:0] movhi_field,
    output logic [1:0] FlagW,
    output logic PCS,RegW,MemW,NoWrite,
    output logic MemtoReg,
    output logic [1:0] ALUSrc,
    output logic [1:0] ImmSrc,RegSrc,
    output logic [2:0] ALUControl,
    output logic BL,
    output logic ShiftEn
);

    logic Branch, ALUOp;

    always_comb begin
        // Valores por defecto para todas las señales
        RegSrc     = 2'b00;
        ImmSrc     = 2'b00;
        ALUSrc     = 2'b00;
        MemtoReg   = 1'b0;
        RegW       = 1'b0;
        MemW       = 1'b0;
        Branch     = 1'b0;
        ALUOp      = 1'b0;
        NoWrite    = 1'b0;
        BL         = 1'b0;
        ShiftEn    = 1'b0;
        ALUControl = 3'bxxx; // 'x' para indefinido/no importa
        FlagW      = 2'b00;
        PCS        = 1'b0;

        case(Op)
            2'b00: begin // Data-processing (ADD, SUB, CMP, MUL, etc.)
                RegW   = 1'b1;
                ALUOp  = 1'b1;

                if (Funct[5]) begin // Operando es un Inmediato
                    ImmSrc = 2'b01;
                    ALUSrc = 2'b01;
                end else begin      // Operando es un Registro
                    ALUSrc = 2'b00;
                end

                // Decodificación de instrucciones específicas
                if (Funct[5] && (Funct[4:1] == 4'b1010)) begin // CMP Immediate
                    NoWrite    = 1'b1;
                    ALUControl = 3'b001; // SUB
                end else if (!Funct[5] && (Funct[4:1] == 4'b1010)) begin // CMP Register
                    NoWrite    = 1'b1;
                    ALUControl = 3'b001; // SUB
                end else if (Funct[5] && (Funct[4:1] == 4'b1101)) begin // MOV Immediate
                    ALUControl = 3'b101; // MOV
                end else if (!Funct[5] && (Funct[4:1] == 4'b0000) && (Mul == 4'b1001)) begin // MUL
                    ALUControl = 3'b100; // MUL
                end else begin // Lógica genérica para ADD, SUB, etc.
                    case(Funct[4:1])
                        4'b0100: ALUControl = 3'b000; // ADD
                        4'b0010: ALUControl = 3'b001; // SUB
                        4'b1100: ALUControl = 3'b011; // ORR
                        4'b0000: ALUControl = 3'b010; // AND
                        default: ALUControl = 3'bxxx;
                    endcase
                end
            end

            // --- SECCIÓN CORREGIDA ---
            2'b01: begin // LDR/STR (Load/Store)
                ALUOp      = 1'b1;    // Se usa la ALU para calcular la dirección (Base + Offset)
                ALUControl = 3'b000; // La operación es siempre una SUMA
                ALUSrc     = 2'b01;   // El segundo operando para la dirección es el inmediato

                if(Funct[0]) begin   // Es LDR (Load, bit L=1)
                    RegW     = 1'b1;   // Se escribe en un registro
                    MemtoReg = 1'b1;   // El dato viene de la memoria
                    MemW     = 1'b0;   // No se escribe en memoria
                end else begin         // Es STR (Store, bit L=0)
                    RegW     = 1'b0;   // NO se escribe en un registro
                    MemtoReg = 1'b0;   // El dato no va a un registro
                    MemW     = 1'b1;   // SÍ se escribe en memoria
                    RegSrc   = 2'b10;  // LA CLAVE: Selecciona Rd (Instr[15:12]) para la segunda lectura (RA2),
                                       // así su valor sale por RD2 y llega a WriteData.
                end
            end
            // --- FIN DE LA SECCIÓN CORREGIDA ---

            2'b10: begin // B (Branch)
                Branch = 1'b1;
                PCS    = 1'b1;
                if (Funct[4]) begin // Asumiendo que Funct[4] es el bit de BL
                    BL = 1'b1;
                end
            end
            
            default: begin // Instrucciones no implementadas
                // Los valores por defecto ya manejan esto.
            end
        endcase

        // Lógica común para FlagW
        if(ALUOp) begin
            FlagW[1] = Funct[0]; // Bit S
            FlagW[0] = Funct[0] & (ALUControl == 3'b000 || ALUControl == 3'b001);
        end else begin
            FlagW = 2'b00;
        end

        // Lógica común para PCS
        PCS = ((Rd == 4'b1111) & RegW) | Branch;
    end

endmodule