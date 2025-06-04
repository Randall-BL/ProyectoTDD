module instruction_memory(
    input  logic [31:0] A,      // Dirección de entrada (PC)
    output logic [31:0] RD      // Instrucción leída
);
    // Memoria ROM
    logic [31:0] rom [0:63];    // 64 palabras de 32 bits

    // Inicialización desde archivo
    initial begin
        $readmemh("./program.dat", rom);
    end

    // Lectura asíncrona
    assign RD = rom[A[7:2]];

endmodule