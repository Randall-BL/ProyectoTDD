
module flopr_tb;

    // Parámetros
    parameter WIDTH = 8;

    // Señales de prueba
    logic clk, reset;
    logic [WIDTH-1:0] d;
    logic [WIDTH-1:0] q;

    // Instancia del DUT (Device Under Test)
    flopr #(WIDTH) uut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );

    // Generador de reloj
    initial clk = 0;
    always #5 clk = ~clk; // Reloj con periodo de 10 unidades de tiempo

    // Procedimiento inicial para pruebas
    initial begin
        // Visualización del encabezado
        $display("Tiempo | Reset | Entrada (d) | Salida (q)");
        $monitor("%0t      |   %b    |     %b     |     %b", $time, reset, d, q);

        // Caso 1: Reset activo
        reset = 1;
        d = 8'b00000000; // Valor inicial en la entrada
        #10;

        // Caso 2: Reset desactivado, almacenamiento de datos
        reset = 0;
        d = 8'b10101010; // Nueva entrada
        #10;

        // Caso 3: Cambio de entrada en flanco de reloj
        d = 8'b11110000;
        #10;

        // Caso 4: Reset activado nuevamente
        reset = 1;
        #10;

        // Finaliza la simulación
        $display("Fin de pruebas.");
        $stop;
    end

endmodule



//`timescale 1ns/1ps
//
//module flopr_tb();
//    // Parámetros del test
//    localparam WIDTH = 32;
//    
//    // Señales de prueba
//    logic             clk;
//    logic             reset;
//    logic [WIDTH-1:0] d;
//    logic [WIDTH-1:0] q;
//    
//    // Instancia del módulo a probar
//    flopr #(WIDTH) dut(
//        .clk(clk),
//        .reset(reset),
//        .d(d),
//        .q(q)
//    );
//    
//    // Generador de reloj
//    always begin
//        clk = 0; #5;
//        clk = 1; #5;
//    end
//    
//    // Estímulos y verificación
//    initial begin
//        $display("=== Iniciando pruebas del Flip-Flop con Reset ===\n");
//        
//        // Prueba 1: Reset asíncrono
//        $display("Prueba 1: Reset asíncrono");
//        reset = 1;
//        d = 32'hAAAA_AAAA;
//        #3; // A mitad del ciclo
//        $display("Reset=1, d=0x%h, q=0x%h", d, q);
//        
//        // Prueba 2: Operación normal
//        $display("\nPrueba 2: Operación normal");
//        reset = 0;
//        d = 32'h5555_5555;
//        @(posedge clk);
//        #1; // Pequeño retardo para estabilización
//        $display("Reset=0, d=0x%h, q=0x%h", d, q);
//        
//        // Prueba 3: Cambios consecutivos
//        $display("\nPrueba 3: Cambios consecutivos");
//        for (int i = 0; i < 3; i++) begin
//            d = $random;
//            @(posedge clk);
//            #1;
//            $display("d=0x%h, q=0x%h", d, q);
//        end
//        
//        // Prueba 4: Reset durante operación
//        $display("\nPrueba 4: Reset durante operación");
//        d = 32'hFFFF_FFFF;
//        @(posedge clk);
//        #2;
//        reset = 1;
//        #1;
//        $display("Reset activado: q=0x%h", q);
//        
//        // Prueba 5: Recuperación después del reset
//        $display("\nPrueba 5: Recuperación después del reset");
//        reset = 0;
//        d = 32'h1234_5678;
//        @(posedge clk);
//        #1;
//        $display("Después de reset: d=0x%h, q=0x%h", d, q);
//        
//        $display("\n=== Pruebas completadas ===");
//        #10 $finish;
//    end
//    
//    // Monitor de cambios
//    initial begin
//        $monitor("Time=%0t reset=%b d=0x%h q=0x%h",
//                 $time, reset, d, q);
//    end
//    
//endmodule