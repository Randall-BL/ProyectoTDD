`timescale 1ns/1ps

module condcheck_tb();
    // Señales de prueba
    logic [3:0] Cond;
    logic [3:0] Flags;
    logic       CondEx;

    // Instancia del módulo
    condcheck dut(
        .Cond(Cond),
        .Flags(Flags),
        .CondEx(CondEx)
    );

    // Estructura para casos de prueba
    typedef struct {
        logic [3:0] cond;
        logic [3:0] flags;
        logic       expected;
        string      description;
    } test_case_t;

    // Casos de prueba
    initial begin
        $display("\n=== Pruebas del Verificador de Condiciones ===");

        // Prueba 1: EQ (Equal, Z=1)
        $display("\nPrueba 1: Condición EQ (Equal)");
        Cond = 4'b0000;  // EQ
        Flags = 4'b0100;  // Z=1
        #10;
        $display("Cond=EQ, Flags[NZCV]=%b, CondEx=%b (Esperado: 1)", Flags, CondEx);

        // Prueba 2: NE (Not Equal, Z=0)
        $display("\nPrueba 2: Condición NE (Not Equal)");
        Cond = 4'b0001;  // NE
        Flags = 4'b0000;  // Z=0
        #10;
        $display("Cond=NE, Flags[NZCV]=%b, CondEx=%b (Esperado: 1)", Flags, CondEx);

        // Prueba 3: GE (Greater or Equal)
        $display("\nPrueba 3: Condición GE (Greater or Equal)");
        Cond = 4'b1010;  // GE
        Flags = 4'b1001;  // N=1, V=1 (N==V)
        #10;
        $display("Cond=GE, Flags[NZCV]=%b, CondEx=%b (Esperado: 1)", Flags, CondEx);

        // Prueba 4: LT (Less Than)
        $display("\nPrueba 4: Condición LT (Less Than)");
        Cond = 4'b1011;  // LT
        Flags = 4'b1000;  // N=1, V=0 (N!=V)
        #10;
        $display("Cond=LT, Flags[NZCV]=%b, CondEx=%b (Esperado: 1)", Flags, CondEx);

        // Prueba 5: GT (Greater Than)
        $display("\nPrueba 5: Condición GT (Greater Than)");
        Cond = 4'b1100;  // GT
        Flags = 4'b0000;  // No flags
        #10;
        $display("Cond=GT, Flags[NZCV]=%b, CondEx=%b (Esperado: 1)", Flags, CondEx);

        // Prueba 6: LE (Less or Equal)
        $display("\nPrueba 6: Condición LE (Less or Equal)");
        Cond = 4'b1101;  // LE
        Flags = 4'b0100;  // Z=1
        #10;
        $display("Cond=LE, Flags[NZCV]=%b, CondEx=%b (Esperado: 1)", Flags, CondEx);

        // Prueba 7: AL (Always)
        $display("\nPrueba 7: Condición AL (Always)");
        Cond = 4'b1110;  // AL
        Flags = 4'b0000;  // Flags no importan
        #10;
        $display("Cond=AL, Flags[NZCV]=%b, CondEx=%b (Esperado: 1)", Flags, CondEx);

        // Prueba 8: Carry Set
        $display("\nPrueba 8: Condición CS (Carry Set)");
        Cond = 4'b0010;  // CS
        Flags = 4'b0010;  // C=1
        #10;
        $display("Cond=CS, Flags[NZCV]=%b, CondEx=%b (Esperado: 1)", Flags, CondEx);

        $display("\n=== Fin de las pruebas ===\n");
        #10 $finish;
    end

    // Monitor de cambios
    initial begin
        $monitor("Time=%0t Cond=%b Flags[NZCV]=%b CondEx=%b",
                 $time, Cond, Flags, CondEx);
    end

endmodule