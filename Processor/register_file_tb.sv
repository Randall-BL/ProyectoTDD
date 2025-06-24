`timescale 1ns/1ps

module register_file_tb();
    // Señales de prueba
    logic        clk;
    logic        we3;
    logic [3:0]  ra1, ra2;
    logic [3:0]  wa3;
    logic [31:0] wd3, r15;
    logic [31:0] rd1, rd2;

    // Instancia del módulo
    register_file dut(
        .clk(clk),
        .we3(we3),
        .ra1(ra1),
        .ra2(ra2),
        .wa3(wa3),
        .wd3(wd3),
        .r15(r15),    // Añadido r15
        .rd1(rd1),
        .rd2(rd2)
    );

    // Generador de reloj
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // Estímulos y verificación
    initial begin
        $display("\n=== Pruebas del Banco de Registros ===");

        // Inicialización
        we3 = 0;
        ra1 = 4'b0;
        ra2 = 4'b0;
        wa3 = 4'b0;
        wd3 = 32'b0;
        r15 = 32'hF0F0_F0F0;  // Valor de prueba para R15
        @(negedge clk);  // Cambiado a negedge para escritura

        // Prueba 1: Escribir en R1
        $display("\nPrueba 1: Escribir 0xAAAAAAAA en R1");
        we3 = 1;
        wa3 = 4'd1;
        wd3 = 32'hAAAA_AAAA;
        @(negedge clk);  // Cambiado a negedge
        we3 = 0;
        ra1 = 4'd1;
        #1;
        $display("Escribió: 0x%h, Leyó: 0x%h", wd3, rd1);

        // Prueba 2: Escribir en R2 y leer ambos
        $display("\nPrueba 2: Escribir 0x55555555 en R2");
        we3 = 1;
        wa3 = 4'd2;
        wd3 = 32'h5555_5555;
        @(negedge clk);  // Cambiado a negedge
        we3 = 0;
        ra1 = 4'd1;
        ra2 = 4'd2;
        #1;
        $display("R1 = 0x%h, R2 = 0x%h", rd1, rd2);

        // Prueba 3: Leer R15 (debe ser F0F0_F0F0)
        $display("\nPrueba 3: Leer R15");
        ra1 = 4'd15;
        #1;
        $display("R15 = 0x%h", rd1);

        // Prueba 4: Escrituras consecutivas
        $display("\nPrueba 4: Escrituras consecutivas");
        for (int i = 3; i < 6; i++) begin
            we3 = 1;
            wa3 = i[3:0];
            wd3 = i * 32'h1111_1111;
            @(negedge clk);  // Cambiado a negedge
            we3 = 0;
            ra1 = i[3:0];
            #1;
            $display("R%0d = 0x%h", i, rd1);
        end

        // Prueba 5: Lectura dual
        $display("\nPrueba 5: Lectura dual de registros");
        ra1 = 4'd1;
        ra2 = 4'd2;
        #1;
        $display("R1 = 0x%h, R2 = 0x%h", rd1, rd2);

        $display("\n=== Fin de las pruebas ===\n");
        #10 $finish;
    end

    // Monitor de escrituras
    initial begin
        $monitor("Time=%0t we3=%b wa3=%d wd3=0x%h ra1=%d rd1=0x%h ra2=%d rd2=0x%h",
                 $time, we3, wa3, wd3, ra1, rd1, ra2, rd2);
    end

endmodule