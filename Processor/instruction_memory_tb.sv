`timescale 1ns/1ps

module instruction_memory_tb();
    // Señales de prueba
    logic [31:0] A;  // Dirección de entrada (Program Counter)
    logic [31:0] RD; // Instrucción leída

    // Instancia del módulo
    instruction_memory dut(
        .A  (A),
        .RD (RD)
    );

    // Estímulos y verificación
    initial begin
        // Inicialización de la dirección A
        A = 32'h0;
        #10; // Pequeño retardo para que la memoria se inicialice y RD se propague

        $display("\n=== Pruebas de Memoria de Instrucciones con programa de Calculadora ===");
        $display("----------------------------------------------------------------------");
        
        // --- Prueba de las primeras instrucciones del programa de la calculadora ---
        // Asumiendo que program.dat tiene el código de la calculadora
        // y que la primera instrucción está en 0x00000000

        // Direccion 0x00000000 (Primera instrucción: LDR R0, =OPERAND1_ADDR)
        // Valor esperado en program.dat: E59F0068 (o similar si LDR R0, =0x1000)
        A = 32'h00000000;
        #10;
        $display("Leyendo PC: 0x%h  -> Instruccion: 0x%h  (Esperado: LDR R0, =OPERAND1_ADDR)", A, RD);
        
        // Direccion 0x00000004 (Segunda instrucción: LDR R1, =OPERAND2_ADDR)
        // Valor esperado en program.dat: E59F0068 (o similar)
        A = 32'h00000004;
        #10;
        $display("Leyendo PC: 0x%h  -> Instruccion: 0x%h  (Esperado: LDR R1, =OPERAND2_ADDR)", A, RD);

        // Direccion 0x00000008 (Tercera instrucción: LDR R2, =OPERATOR_ADDR)
        // Valor esperado en program.dat: E59F0064 (o similar)
        A = 32'h00000008;
        #10;
        $display("Leyendo PC: 0x%h  -> Instruccion: 0x%h  (Esperado: LDR R2, =OPERATOR_ADDR)", A, RD);

        // --- Pruebas de direcciones más lejanas para verificar el mapeo A[11:2] ---
        // Escoge una dirección más alta que sepas que contiene una instrucción
        // (Por ejemplo, si tienes un salto o una función más abajo en tu código)
        // Si tu programa solo tiene 30 instrucciones, las direcciones altas serán ceros o 'x'
        // Puedes verificar esto observando tu program.dat para encontrar una instrucción lejana.

        // Ejemplo: Si el programa es pequeño, esta podría ser 0.
        // Si tienes una instruccion en PC 0x00000050 (índice 0x14), léela
        A = 32'h00000050; // Ejemplo: Dirección de una instrucción en el medio de tu código
        #10;
        $display("Leyendo PC: 0x%h  -> Instruccion: 0x%h  (Ejemplo: Instruccion intermedia)", A, RD);
        
        // Ejemplo: Leer una dirección al final de tu programa (o donde esperas un final)
        // Por ejemplo, si tu programa termina en la instrucción 28 (índice 0x1C * 4), PC = 0x70
        // Podrías probar la dirección de fin de tu programa o una dirección de salto.
        A = 32'h00000070; // Por ejemplo, la última instrucción válida en tu program.dat
        #10;
        $display("Leyendo PC: 0x%h  -> Instruccion: 0x%h  (Ejemplo: Ultima instruccion relevante)", A, RD);

        // Prueba una dirección fuera del rango de tu programa (pero dentro de la ROM)
        // Esto debería dar '00000000' (si rellenaste el .dat con ceros) o 'xxxxxxxx' (si no)
        A = 32'h00000200; // Índice 0x80 (256 decimal)
        #10;
        $display("Leyendo PC: 0x%h  -> Instruccion: 0x%h  (Esperado: 0 o X, fuera del programa)", A, RD);

        $display("----------------------------------------------------------------------");
        $display("=== Fin de las pruebas de Memoria de Instrucciones ===\n");
        #10 $finish; // Termina la simulación
    end

endmodule