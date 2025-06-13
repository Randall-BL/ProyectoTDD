`timescale 1ns/1ps

module processor_tb;

    // Declaración de señales
    logic           clk;
    logic           reset;
    logic           next_state_vga;
    
    // Señales de salida de la VGA (no se usarán para la prueba de la calculadora, pero deben estar conectadas)
    logic vgaclk;
    logic hsync, vsync;
    logic sync_b, blank_b;
    logic [7:0] r, g, b;

    // Definir la dirección del resultado en dmem
    parameter RESULT_ADDR = 32'h0000000C;

    // Instancia del DUT (Device Under Test)
    processor dut(
        .clk(clk),
        .reset(reset),
        .next_state_vga(next_state_vga),
        .vgaclk(vgaclk),
        .hsync(hsync),
        .vsync(vsync),
        .sync_b(sync_b),
        .blank_b(blank_b),
        .r(r),
        .g(g),
        .b(b)
    );

    // Generador de reloj (Periodo de 10ns, frecuencia de 100 MHz)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // *** INICIO DEL MONITOR ***
    initial begin
        $monitor("Time=%0t ns | PC=%h | Instr=%h | ALURes=%h | WrtDat=%h | MemWrt=%b | RdDat=%h | R0=%h R1=%h R2=%h R3=%h R7=%h",
                 $time, 
                 dut.PC,        // PC del procesador
                 dut.Instr,     // Instrucción actual
                 dut.ALUResult, // Resultado de la ALU
                 dut.WriteData, // Datos a escribir en memoria
                 dut.MemWrite,  // Señal de escritura en memoria
                 dut.ReadData,  // Datos leídos de memoria
                 dut.arm_inst.R0_val, // <--- CAMBIAR AQUÍ: de dut.arm.R0_val a dut.arm_inst.R0_val
                 dut.arm_inst.R1_val, // <--- CAMBIAR AQUÍ
                 dut.arm_inst.R2_val, // <--- CAMBIAR AQUÍ
                 dut.arm_inst.R3_val, // <--- CAMBIAR AQUÍ
                 dut.arm_inst.R7_val  // <--- CAMBIAR AQUÍ
        );
    end
    // *** FIN DEL MONITOR ***

    // Estímulos y monitoreo
    initial begin
        // Valores iniciales para las señales del testbench
        clk = 0;    
        reset = 1;
        next_state_vga = 0; 

        // Reset inicial del procesador (antes de la primera prueba)
        #1; // Pequeño retardo
        @(posedge clk); // Sincroniza con el flanco positivo del reloj
        reset = 0; // Desactiva el reset

        $display("\n=== Iniciando prueba de la calculadora ARM ===\n");
        
        // --- 1. Caso de prueba: SUMA (10 + 5) ---
        $display("--- Caso de prueba 1: SUMA (10 + 5) ---");
        
        // ¡PREPARA LOS DATOS EN LA MEMORIA *ANTES* DEL RESET Y LA EJECUCIÓN!
        dut.dmem.RAM[32'h0000/4] = 32'd10;  // Operando 1 (en 0x0000)
        dut.dmem.RAM[32'h0004/4] = 32'd5;   // Operando 2 (en 0x0004)
        dut.dmem.RAM[32'h0008/4] = 32'd1;   // Operador = 1 (Suma, en 0x0008)
        dut.dmem.RAM[RESULT_ADDR/4] = 32'd0; // Limpiar el resultado anterior

        // Aplicar un reset para que el PC inicie en 0 y el procesador lea los nuevos datos
        reset = 1; @(posedge clk); // Activa reset, espera un ciclo de reloj
        reset = 0; // Desactiva reset
        
        // Dale suficientes ciclos para que el procesador ejecute el programa y llegue a 'end_program'
        // Un programa de calculadora tiene bastantes instrucciones. 50 ciclos es un punto de partida,
        // pero podrías necesitar más (ej: 100 o 200) dependiendo de las ramas.
        repeat(100) @(posedge clk); 

        $display("Resultado de la Suma (10 + 5) en DMEM[0x000C]: %h (Decimal: %0d)\n", dut.dmem.RAM[RESULT_ADDR/4], dut.dmem.RAM[RESULT_ADDR/4]);
        
        // --- 2. Caso de prueba: MULTIPLICACIÓN (4 * 6 = 24) ---
        $display("--- Caso de prueba 2: MULTIPLICACIÓN (4 * 6) ---");
        
        // ¡PREPARA LOS DATOS PARA LA PRUEBA 2!
        dut.dmem.RAM[32'h0000/4] = 32'd4;   // Operando 1
        dut.dmem.RAM[32'h0004/4] = 32'd6;   // Operando 2
        dut.dmem.RAM[32'h0008/4] = 32'd3;   // Operador = 3 (Multiplicación)
        dut.dmem.RAM[RESULT_ADDR/4] = 32'd0; // Limpiar el resultado anterior

        // Aplicar un reset para que el PC inicie en 0 y el procesador lea los nuevos datos
        reset = 1; @(posedge clk);
        reset = 0;
        
        repeat(100) @(posedge clk); // Dale ciclos al procesador
        
        $display("Resultado de la Multiplicación (4 * 6) en DMEM[0x000C]: %h (Decimal: %0d)\n", dut.dmem.RAM[RESULT_ADDR/4], dut.dmem.RAM[RESULT_ADDR/4]);

        // --- 3. Caso de prueba: DIVISIÓN POR CERO (50 / 0) ---
        $display("--- Caso de prueba 3: DIVISIÓN POR CERO (50 / 0) ---");
        
        // ¡PREPARA LOS DATOS PARA LA PRUEBA 3!
        dut.dmem.RAM[32'h0000/4] = 32'd50;  // Operando 1
        dut.dmem.RAM[32'h0004/4] = 32'd0;   // Operando 2
        dut.dmem.RAM[32'h0008/4] = 32'd4;   // Operador = 4 (División)
        dut.dmem.RAM[RESULT_ADDR/4] = 32'd0; // Limpiar el resultado anterior

        // Aplicar un reset para que el PC inicie en 0 y el procesador lea los nuevos datos
        reset = 1; @(posedge clk);
        reset = 0;
        
        repeat(100) @(posedge clk); 
        
        $display("Resultado de la División por Cero (50 / 0) en DMEM[0x000C]: %h (Decimal: %0d)\n", dut.dmem.RAM[RESULT_ADDR/4], dut.dmem.RAM[RESULT_ADDR/4]);


        $display("\n=== Prueba de la calculadora ARM completada ===\n");
        $finish;    
    end

endmodule