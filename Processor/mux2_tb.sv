`timescale 1ns/1ps

module mux2_tb();
    // Parámetros del test
    localparam WIDTH = 32;
    
    // Señales de prueba
    logic [WIDTH-1:0] d0;
    logic [WIDTH-1:0] d1;
    logic             s;
    logic [WIDTH-1:0] y;
    
    // Instancia del módulo a probar
    mux2 #(WIDTH) dut(
        .d0(d0),
        .d1(d1),
        .s(s),
        .y(y)
    );
    
    // Función de verificación
    function automatic void check_mux();
        automatic logic [WIDTH-1:0] expected = s ? d1 : d0;
        if (y !== expected) begin
            $display("Error: s=%b, d0=%h, d1=%h, y=%h (esperado: %h)",
                     s, d0, d1, y, expected);
        end else begin
            $display("Correcto: s=%b, d0=%h, d1=%h, y=%h",
                     s, d0, d1, y);
        end
    endfunction
    
    // Estímulos y verificación
    initial begin
        $display("=== Iniciando pruebas del Multiplexor 2:1 ===\n");
        
        // Prueba 1: Selección de d0
        $display("Prueba 1: Selección de d0 (s=0)");
        s  = 0;
        d0 = 32'hAAAA_AAAA;
        d1 = 32'h5555_5555;
        #1; check_mux();
        
        // Prueba 2: Selección de d1
        $display("\nPrueba 2: Selección de d1 (s=1)");
        s = 1;
        #1; check_mux();
        
        // Prueba 3: Cambio rápido de selección
        $display("\nPrueba 3: Cambios rápidos de selección");
        d0 = 32'hFFFF_0000;
        d1 = 32'h0000_FFFF;
        s  = 0;
        #1; check_mux();
        s  = 1;
        #1; check_mux();
        
        // Prueba 4: Valores especiales
        $display("\nPrueba 4: Valores especiales");
        d0 = 32'h0000_0000;
        d1 = 32'hFFFF_FFFF;
        s  = 0;
        #1; check_mux();
        s  = 1;
        #1; check_mux();
        
        // Prueba 5: Valores aleatorios
        $display("\nPrueba 5: Valores aleatorios");
        for (int i = 0; i < 3; i++) begin
            d0 = $random;
            d1 = $random;
            s  = $random % 2;
            #1; check_mux();
        end
        
        $display("\n=== Pruebas completadas ===");
        #10 $finish;
    end
    
endmodule