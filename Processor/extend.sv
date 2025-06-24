module extend(
    input  logic [23:0] Instr,    // Campo inmediato de la instrucción
    input  logic [1:0]  ImmSrc,   // Control del tipo de extensión
    output logic [31:0] ExtImm    // Inmediato extendido
);

    // Extensión de signo según el tipo de instrucción
    always_comb
        case(ImmSrc)
            // 8-bit immediate (Data-processing)
            2'b00: ExtImm = {24'b0, Instr[7:0]};
            
            // 12-bit immediate (Memory)
            2'b01: ExtImm = {20'b0, Instr[11:0]};
            
            // 24-bit immediate (Branch)
            2'b10: ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00};
            
            // Default case
            default: ExtImm = 32'bx;
        endcase

endmodule