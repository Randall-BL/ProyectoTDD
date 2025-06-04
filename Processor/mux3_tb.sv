`timescale 1ns/1ps

module mux3_tb();
    // Parámetros del test
    localparam WIDTH = 32;
    
    // Señales de prueba
    logic [WIDTH-1:0] d0, d1, d2;
    logic [1:0]       s;
    logic [WIDTH-1:0] y;
    
    // Instancia del módulo a probar
    mux3 #(WIDTH) dut(
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .s(s),
        .y(y)
    );
    
    // Función de verificación
    function automatic void check_mux(string test_name);
        automatic logic [WIDTH-1:0] expected = s[1] ? d2 : (s[0] ? d1 : d0);
        if (y !== expected) begin
            $display("Error en %s: s=%b", test_name, s);
            $display("  d0=%h, d1=%h, d2=%h", d0, d1, d2);
            $display("  Obtenido: %h", y);
            $display("  Esperado: %h", expected);
        end else begin
            $display("Correcto - %s: s=%b, d0=%h, d1=%h, d2=%h, y=%h",
                     test_name, s, d0, d1, d2, y);
        end
    endfunction
    
    // Estímulos y verificación
    initial begin
        $display("=== Iniciando pruebas del Multiplexor 3:1 ===\n");
        
        // Prueba 1: Selección de d0 (s=00)
        $display("Prueba 1: Selección de d0");
        s  = 2'b00;
        d0 = 32'hAAAA_AAAA;
        d1 = 32'h5555_5555;
        d2 = 32'hFFFF_FFFF;
        #1; check_mux("d0 select");
        
        // Prueba 2: Selección de d1 (s=01)
        $display("\nPrueba 2: Selección de d1");
        s = 2'b01;
        #1; check_mux("d1 select");
        
        // Prueba 3: Selección de d2 (s=10 o s=11)
        $display("\nPrueba 3: Selección de d2");
        s = 2'b10;
        #1; check_mux("d2 select (10)");
        s = 2'b11;
        #1; check_mux("d2 select (11)");
        
        // Prueba 4: Valores especiales
        $display("\nPrueba 4: Valores especiales");
        d0 = 32'h0000_0000;
        d1 = 32'hFFFF_0000;
        d2 = 32'h0000_FFFF;
        for (int i = 0; i < 4; i++) begin
            s = i[1:0];
            #1; check_mux($sformatf("special-%0d", i));
        end
        
        // Prueba 5: Valores aleatorios
        $display("\nPrueba 5: Valores aleatorios");
        for (int i = 0; i < 4; i++) begin
            d0 = $random;
            d1 = $random;
            d2 = $random;
            s  = i[1:0];
            #1; check_mux($sformatf("random-%0d", i));
        end
        
        $display("\n=== Pruebas completadas ===");
        #10 $finish;
    end
    
endmodule