
module condlogic_tb;

    // Declaracion de señales de prueba
    logic clk, reset;
    logic [3:0] Cond, ALUFlags;
    logic [1:0] FlagW;
    logic PCS, RegW, MemW, NoWrite;
    logic PCSrc, RegWrite, MemWrite;

    // Instancia del DUT (Device Under Test)
    condlogic uut (
        .clk(clk),
        .reset(reset),
        .Cond(Cond),
        .ALUFlags(ALUFlags),
        .FlagW(FlagW),
        .PCS(PCS),
        .RegW(RegW),
        .MemW(MemW),
        .NoWrite(NoWrite),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite)
    );

    // Generador de reloj
    initial clk = 0;
    always #5 clk = ~clk;

    // Procedimiento inicial para las pruebas
    initial begin
        $display("Iniciando pruebas del modulo condlogic...");
        $display("Formato: Cond | ALUFlags | FlagW | PCS | RegW | MemW | NoWrite || PCSrc | RegWrite | MemWrite");

        // Caso 1: Reset activado
        reset = 1;
        Cond = 4'b0000;
        ALUFlags = 4'b0000;
        FlagW = 2'b00;
        PCS = 0;
        RegW = 0;
        MemW = 0;
        NoWrite = 0;
        #10;
        reset = 0;

        // Caso 2: CondEx activado, se permite escritura
        Cond = 4'b1110;  // Siempre verdadero (segun ARM)
        ALUFlags = 4'b0000; 
        FlagW = 2'b11;
        PCS = 1;
        RegW = 1;
        MemW = 1;
        NoWrite = 0;
        #10;
        $display("Caso 2: %b | %b | %b | %b | %b | %b | %b || %b | %b | %b", 
                 Cond, ALUFlags, FlagW, PCS, RegW, MemW, NoWrite, PCSrc, RegWrite, MemWrite);

        // Caso 3: CondEx desactivado, ninguna escritura
        Cond = 4'b0001;  // Z=1 (segun ARM)
        ALUFlags = 4'b0000;  // Ningun flag activo
        FlagW = 2'b11;
        PCS = 1;
        RegW = 1;
        MemW = 1;
        NoWrite = 0;
        #10;
        $display("Caso 3: %b | %b | %b | %b | %b | %b | %b || %b | %b | %b", 
                 Cond, ALUFlags, FlagW, PCS, RegW, MemW, NoWrite, PCSrc, RegWrite, MemWrite);

        // Caso 4: Escritura deshabilitada por NoWrite
        Cond = 4'b1110;  // Siempre verdadero
        ALUFlags = 4'b0000;
        FlagW = 2'b11;
        PCS = 1;
        RegW = 1;
        MemW = 1;
        NoWrite = 1;  // Escritura deshabilitada
        #10;
        $display("Caso 4: %b | %b | %b | %b | %b | %b | %b || %b | %b | %b", 
                 Cond, ALUFlags, FlagW, PCS, RegW, MemW, NoWrite, PCSrc, RegWrite, MemWrite);

        // Caso 5: Verificacion de FlagWrite
        Cond = 4'b1110;  // Siempre verdadero
        ALUFlags = 4'b1010;
        FlagW = 2'b10;  // Solo un flag escrito
        PCS = 0;
        RegW = 0;
        MemW = 0;
        NoWrite = 0;
        #10;
        $display("Caso 5: %b | %b | %b | %b | %b | %b | %b || %b | %b | %b", 
                 Cond, ALUFlags, FlagW, PCS, RegW, MemW, NoWrite, PCSrc, RegWrite, MemWrite);

        $display("Pruebas finalizadas.");
        $stop;
    end

endmodule


//module condlogic_tb();
//    // Señales
//    logic       clk;
//    logic       reset;
//    logic [3:0] Cond;
//    logic [3:0] ALUFlags;
//    logic [1:0] FlagW;
//    logic       PCS, RegW, MemW;
//    logic       PCSrc, RegWrite, MemWrite;
//
//    // Instancia del módulo
//    condlogic dut(.*);
//
//    // Generador de reloj
//    always begin
//        clk = 1; #5;
//        clk = 0; #5;
//    end
//
//    // Test
//    initial begin
//        $display("=== Test Basico de CondLogic ===\n");
//
//        // Reset inicial
//        reset = 1;
//        Cond = 4'b0000;      // EQ
//        ALUFlags = 4'b0000;
//        FlagW = 2'b00;
//        PCS = 0; RegW = 0; MemW = 0;
//        @(posedge clk); #1;
//        reset = 0;
//
//        // Test 1: Condición EQ con Z=1 (igual)
//        $display("Test 1: EQ con Z=1");
//        Cond = 4'b0000;      // EQ
//        ALUFlags = 4'b0100;   // Z=1
//        FlagW = 2'b10;       // Actualizar NZ
//        PCS = 1; RegW = 1; MemW = 1;
//        @(posedge clk); #1;
//        $display("  PCSrc=%b RegWrite=%b MemWrite=%b (Esperado: 1,1,1)", 
//                 PCSrc, RegWrite, MemWrite);
//
//        // Test 2: Condición EQ con Z=0 (no igual)
//        $display("\nTest 2: EQ con Z=0");
//        ALUFlags = 4'b0000;   // Z=0
//        @(posedge clk); #1;
//        $display("  PCSrc=%b RegWrite=%b MemWrite=%b (Esperado: 0,0,0)", 
//                 PCSrc, RegWrite, MemWrite);
//
//        // Test 3: Condición AL (siempre)
//        $display("\nTest 3: AL (siempre)");
//        Cond = 4'b1110;      // AL
//        @(posedge clk); #1;
//        $display("  PCSrc=%b RegWrite=%b MemWrite=%b (Esperado: 1,1,1)", 
//                 PCSrc, RegWrite, MemWrite);
//
//        // Test 4: Actualización de flags
//        $display("\nTest 4: Actualizacion de flags");
//        Cond = 4'b0000;      // EQ
//        ALUFlags = 4'b1100;   // N=1, Z=1
//        FlagW = 2'b11;       // Actualizar todos los flags
//        @(posedge clk); #1;
//        $display("  Flags=%b (Esperado: 1100)", dut.Flags);
//
//        $display("\n=== Fin del Test ===");
//        $finish;
//    end
//
//    // Monitor
//    initial begin
//        $monitor("Time=%0t Cond=%b Flags=%b CondEx=%b", 
//                 $time, Cond, dut.Flags, dut.CondEx);
//    end
//endmodule