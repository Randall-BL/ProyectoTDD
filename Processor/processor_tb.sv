module processor_tb();
    logic        clk;
    logic        reset;

    processor dut(
        .clk(clk),
        .reset(reset)
    );

    // Generador de reloj
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Estímulos y monitoreo
    initial begin
        // Reset inicial
        reset = 1;
        @(posedge clk);
        #1;
        reset = 0;

        $display("\n=== Iniciando prueba del procesador ARM ===\n");
        
        // Mostrar contenido inicial de memorias
        $display("Contenido inicial de memoria de instrucciones:");
        for (int i = 0; i < 8; i++) begin
            $display("IMEM[%0d] = %h", i, dut.imem.rom[i]);  // Usando rom
        end

        $display("\nContenido inicial de memoria de datos:");
        for (int i = 0; i < 10; i++) begin
            $display("DMEM[%0d] = %h", i, dut.dmem.RAM[i]);
        end

        // Ejecutar y monitorear cada instrucción
        repeat(8) begin
            @(posedge clk);
            case(dut.Instr)
                32'he3a00001: $display("\nEjecutando MOV R0, #1:");
                32'he3a01002: $display("\nEjecutando MOV R1, #2:");
                32'he0802001: $display("\nEjecutando ADD R2, R0, R1:");
                32'he0803002: $display("\nEjecutando ADD R3, R0, R2:");
                32'he1a00000: $display("\nEjecutando NOP:");
                default: $display("\nEjecutando instrucción: %h", dut.Instr);
            endcase
            
            // Mostrar estado actual
            $display("  PC        = %h", dut.PC);
            $display("  Instr     = %h", dut.Instr);
            $display("  ALUResult = %h", dut.ALUResult);
            $display("  WriteData = %h", dut.WriteData);
            
            // Si hay escritura en memoria
            if (dut.MemWrite)
                $display("  Escribiendo en memoria: dir=%h, dato=%h", 
                        dut.ALUResult, dut.WriteData);
                        
            // Esperar un poco para estabilidad
            #1;
        end

        // Mostrar contenido final de memoria
        $display("\n=== Prueba completada ===");
        $display("Contenido final de memoria de datos:");
        for (int i = 0; i < 10; i++) begin
            $display("DMEM[%0d] = %h", i, dut.dmem.RAM[i]);
        end

        $finish;
    end

    // Monitor continuo de señales críticas
    initial begin
        $monitor("Time=%0t reset=%b PC=%h Instr=%h ALUResult=%h WriteData=%h",
                 $time, reset, dut.PC, dut.Instr, dut.ALUResult, dut.WriteData);
    end

endmodule