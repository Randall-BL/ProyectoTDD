`timescale 1ns/1ps

module adder_tb();
    // Parámetros del test
    localparam WIDTH = 32;
    
    // Señales de prueba
    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic [WIDTH-1:0] y;
    
    // Instancia del módulo a probar
    adder #(WIDTH) dut(
        .a(a),
        .b(b),
        .y(y)
    );
    
    // Función de verificación
    function automatic void check_sum();
        automatic logic [WIDTH-1:0] expected = a + b;
        if (y !== expected) begin
            $display("Error: %h + %h = %h (esperado: %h)", 
                     a, b, y, expected);
        end else begin
            $display("Correcto: %h + %h = %h", a, b, y);
        end
    endfunction
    
    // Estímulos y verificación
    initial begin
        $display("=== Iniciando pruebas del Sumador ===\n");
        
        // Prueba 1: Suma básica
        $display("Prueba 1: Suma básica");
        a = 32'd5;
        b = 32'd3;
        #1; check_sum();
        
        // Prueba 2: Suma con números grandes
        $display("\nPrueba 2: Suma con números grandes");
        a = 32'h7FFF_FFFF;
        b = 32'h0000_0001;
        #1; check_sum();
        
        // Prueba 3: Suma PC + 4
        $display("\nPrueba 3: Suma PC + 4");
        a = 32'h0000_1000;
        b = 32'd4;
        #1; check_sum();
        
        // Prueba 4: Suma con números negativos
        $display("\nPrueba 4: Suma con números negativos");
        a = -32'd10;
        b = 32'd15;
        #1; check_sum();
        
        // Prueba 5: Suma con overflow
        $display("\nPrueba 5: Suma con overflow");
        a = 32'hFFFF_FFFF;
        b = 32'h0000_0001;
        #1; check_sum();
        
        // Prueba 6: Sumas aleatorias
        $display("\nPrueba 6: Sumas aleatorias");
        for (int i = 0; i < 3; i++) begin
            a = $random;
            b = $random;
            #1; check_sum();
        end
        
        $display("\n=== Pruebas completadas ===");
        #10 $finish;
    end
    
endmodule