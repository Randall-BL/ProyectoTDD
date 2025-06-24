`timescale 1ns/1ps

module arm_tb();
    logic        clk;
    logic        reset;
    logic [31:0] PC;
    logic [31:0] Instr;
    logic        MemWrite;
    logic [31:0] ALUResult;
    logic [31:0] WriteData;
    logic [31:0] ReadData;

    // *** NUEVAS SEÑALES PARA MONITOREAR LOS VALORES DE LOS REGISTROS ***
    logic [31:0] R0_val;
    logic [31:0] R1_val;
    logic [31:0] R2_val;
    logic [31:0] R3_val;
    logic [31:0] R7_val; // Para monitorear R7

    // Instancia del procesador ARM - Conexión explícita para incluir los nuevos puertos
    arm dut(
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData),
        // Conectando los nuevos puertos de salida de arm
        .R0_val(R0_val),
        .R1_val(R1_val),
        .R2_val(R2_val),
        .R3_val(R3_val),
        .R7_val(R7_val) // Conexión de R7
    );

    // Generación de reloj
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Task para mostrar resultados detallados
    task automatic display_results;
        input string instruction_name;
        begin
            $display("\n-------------------------------------------------");
            $display("Ejecutando %s:", instruction_name);
            $display("  PC         = %h", PC);
            $display("  Instr      = %h", Instr);
            $display("  ALUResult  = %h", ALUResult);
            $display("  WriteData  = %h", WriteData);
            if (MemWrite)
                $display("  Escribiendo en memoria: dir=%h, dato=%h", ALUResult, WriteData);
            $display("  Regs: R0=%h R1=%h R2=%h R3=%h R7=%h", R0_val, R1_val, R2_val, R3_val, R7_val);
            $display("-------------------------------------------------");
        end
    endtask

    // Memoria de instrucciones simulada (solo para el módulo 'arm')
    always_comb
        case(PC)
            32'h00: Instr = 32'hE3A07000; // LDR R7, =0x0000 (instrucción real de tu calculadora)
            32'h04: Instr = 32'hE0821003; // ADD R1, R2, R3 (ejemplo)
            32'h08: Instr = 32'hE2112064; // ADDS R1, R2, #100 (ejemplo)
            32'h0C: Instr = 32'hE5921004; // LDR R1, [R2, #4] (ejemplo)
            32'h10: Instr = 32'hE5821004; // STR R1, [R2, #4] (ejemplo)
            32'h14: Instr = 32'hEA000001; // B skip (ejemplo)
            32'h18: Instr = 32'hE0421003; // SUB R1, R2, R3 (ejemplo)
            32'h1C: Instr = 32'hE0021003; // AND R1, R2, R3 (ejemplo)
            default: Instr = 32'h0; // Instrucción NOP o fin
        endcase

    // Memoria de datos simulada (solo para el módulo 'arm')
    // Esto simula lo que dmem leería
    always_comb begin
        // Si MemWrite es alto, la ALUResult es una dirección de escritura
        // Si MemWrite es bajo, ALUResult es una dirección de lectura
        // Aquí solo simulamos los datos leídos
        case(ALUResult)
            // Agrega más direcciones si tus instrucciones de prueba lo necesitan
            32'h00000000: ReadData = 32'hFFFF0000; // Valor para LDR R7, =0x0000 (puede ser cualquiera, el procesador lo usará para inicializar R7)
            32'h00000004: ReadData = 32'hAABBCCDD; // Ejemplo para LDR R1, [R2, #4] si R2+4 = 0x4
            32'h00000006: ReadData = 32'h12345678; // Otro ejemplo de dato
            default:      ReadData = 32'h00000000;
        endcase
    end

    // Test sequence
    initial begin
        $display("\n=== Iniciando prueba de módulo ARM ===\n");
        
        // Reset inicial
        reset = 1;
        #10; // Mantener reset activo por un ciclo
        reset = 0;
        @(posedge clk); // Esperar un ciclo después de liberar reset

        // Puedes configurar valores iniciales para registros aquí (si es necesario para la prueba de tu ARM)
        // Pero idealmente, las instrucciones del ARM deberían manipular los registros
        // dut.dp.rf_inst.rf[2] = 32'h00000002; // NO usar 'force' en el testbench principal, pero aquí para arm_tb aislado es una opción
        // dut.dp.rf_inst.rf[3] = 32'h00000003; // Asegúrate que 'rf_inst' sea el nombre de tu instancia en datapath

        // --- Ejecutar instrucciones ---
        @(posedge clk); // LDR R7, =0x0000 (PC=0x00)
        display_results("LDR R7, =0x0000");

        @(posedge clk); // ADD R1, R2, R3 (PC=0x04)
        display_results("ADD R1, R2, R3");

        @(posedge clk); // ADDS R1, R2, #100 (PC=0x08)
        display_results("ADDS R1, R2, #100");

        @(posedge clk); // LDR R1, [R2, #4] (PC=0x0C)
        display_results("LDR R1, [R2, #4]");

        @(posedge clk); // STR R1, [R2, #4] (PC=0x10)
        display_results("STR R1, [R2, #4]");

        @(posedge clk); // B skip (PC=0x14)
        display_results("B skip"); // PC debería saltar

        @(posedge clk); // AND R1, R2, R3 (PC=0x18 o la dirección del salto)
        display_results("AND R1, R2, R3 (después de B)");

        // Esperar un poco más para ver el estado final
        repeat(5) @(posedge clk);

        $display("\n=== Prueba del módulo ARM completada ===");
        $finish;
    end

    // Monitor continuo para una vista rápida
    initial begin
        $monitor("Time=%0t PC=%h Instr=%h ALUResult=%h R0=%h R1=%h R2=%h R3=%h R7=%h",
                 $time, PC, Instr, ALUResult, R0_val, R1_val, R2_val, R3_val, R7_val);
    end
    
    // Verificación de WriteData (opcional, para depuración de señales X)
    // No es estrictamente necesario aquí si el principal problema es el flujo de datos.
    /*
    always @(posedge clk) begin
        if (ReadData & (Instr[27:25] == 3'b010)) begin // Verifica instrucciones tipo data processing
            assert (WriteData !== 32'hxxxxxxxx)
                else $error("WriteData no está definido en ciclo %0d", $time);
        end
    end
    */

endmodule