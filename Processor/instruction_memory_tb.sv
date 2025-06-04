`timescale 1ns/1ps

module instruction_memory_tb();
    // Señales de prueba
    logic [31:0] A;
    logic [31:0] RD;

    // Instancia del módulo
    instruction_memory dut(
        .A  (A),
        .RD (RD)
    );

    // Estímulos y verificación
    initial begin
        // Inicialización
        A = 32'h0;
        #10;

        $display("\n=== Pruebas de Memoria de Instrucciones ===");
        
        // Prueba 1: MOV R0, #1
        A = 32'h0;
        #10;
        $display("Direccion: 0x%h  Instruccion: 0x%h  (MOV R0, #1)", A, RD);
        
        // Prueba 2: MOV R1, #2
        A = 32'h4;
        #10;
        $display("Direccion: 0x%h  Instruccion: 0x%h  (MOV R1, #2)", A, RD);
        
        // Prueba 3: ADD R2, R0, R1
        A = 32'h8;
        #10;
        $display("Direccion: 0x%h  Instruccion: 0x%h  (ADD R2, R0, R1)", A, RD);
        
        // Prueba 4: ADD R3, R0, R2
        A = 32'hC;
        #10;
        $display("Direccion: 0x%h  Instruccion: 0x%h  (ADD R3, R0, R2)", A, RD);
        
        // Prueba 5-8: NOPs
        for (int i = 4; i < 8; i++) begin
            A = i * 4;
            #10;
            $display("Direccion: 0x%h  Instruccion: 0x%h  (NOP)", A, RD);
        end

        $display("=== Fin de las pruebas ===\n");
        #10 $finish;
    end

endmodule