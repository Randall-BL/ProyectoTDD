`timescale 1ns/1ps

module processor_tb;

    // Declaración de señales
    logic           clk;
    logic           reset;
    logic           next_state_vga;
    
    // Señales de salida de la VGA
    logic vgaclk;
    logic hsync, vsync;
    logic sync_b, blank_b;
    logic [7:0] r, g, b;

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
        clk = 1'b0; 
        #5;
        clk = 1'b1; 
        #5;
    end

    // *** MONITOR COMPLETO COMO SOLICITASTE ***
    initial begin
        $monitor("Time=%0t ns | PC=%h | Instr=%h | ALURes=%h | WrtDat=%h | MemWrt=%b | RdDat=%h | RegWrt=%b | MemtoReg=%b | WrtReg=%d | R0=%h R1=%h R2=%h R3=%h R7=%h",
                 $time, 
                 dut.PC,         // PC del procesador
                 dut.Instr,      // Instrucción actual
                 dut.ALUResult,  // Resultado de la ALU
                 dut.WriteData,  // Datos a escribir
                 dut.MemWrite,   // Señal de escritura en memoria
                 dut.ReadData,   // Datos leídos de memoria
                 dut.RegWrite,   // Señal de escritura de registros
                 dut.MemtoReg,   // Selección de fuente de datos
                 dut.A3,         // Registro destino
                 dut.tb_R0_val,  // Valor del registro R0
                 dut.tb_R1_val,  // Valor del registro R1
                 dut.tb_R2_val,  // Valor del registro R2
                 dut.tb_R3_val,  // Valor del registro R3
                 dut.tb_R7_val   // Valor del registro R7
        );
    end

    // Prueba básica para verificar conectividad
    initial begin
        $display("\n=== INICIANDO PRUEBA BÁSICA DEL PROCESADOR ARM ===\n");
        
        // Inicializar señales
        reset = 1'b1;
        next_state_vga = 1'b0;
        
        // Aplicar reset por varios ciclos
        repeat(5) @(posedge clk);
        
        $display("Liberando reset...");
        reset = 1'b0;
        
        // Ejecutar por algunos ciclos para verificar conectividad
        $display("\n--- VERIFICANDO CONECTIVIDAD BÁSICA ---");
        repeat(20) @(posedge clk);
        
        $display("\n=== VERIFICACIÓN BÁSICA COMPLETADA ===");
        $display("Si no hay errores de conectividad, el diseño básico funciona.");
        
        $finish;
    end

    // Timeout de seguridad
    initial begin
        #1000; // 1 microsegundo
        $display("⚠️  TIMEOUT - Terminando simulación");
        $finish;
    end

endmodule