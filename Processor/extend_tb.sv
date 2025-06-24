`timescale 1ns/1ps

module extend_tb();
    // Señales de prueba
    logic [23:0] Instr;
    logic [1:0]  ImmSrc;
    logic [31:0] ExtImm;
    
    // Instancia del módulo a probar
    extend dut(
        .Instr(Instr),
        .ImmSrc(ImmSrc),
        .ExtImm(ExtImm)
    );
    
    // Función de verificación
    function automatic void check_extend(string test_name);
        logic [31:0] expected;
        case(ImmSrc)
            2'b00: expected = {24'b0, Instr[7:0]};
            2'b01: expected = {20'b0, Instr[11:0]};
            2'b10: expected = {{6{Instr[23]}}, Instr[23:0], 2'b00};
            default: expected = 32'bx;
        endcase
        
        if (ExtImm !== expected) begin
            $display("Error en %s: ImmSrc=%b, Instr=%h", test_name, ImmSrc, Instr);
            $display("  Obtenido: %h", ExtImm);
            $display("  Esperado: %h", expected);
        end else begin
            $display("Correcto - %s: ImmSrc=%b, Instr=%h, ExtImm=%h", 
                     test_name, ImmSrc, Instr, ExtImm);
        end
    endfunction
    
    // Estímulos y verificación
    initial begin
        $display("=== Iniciando pruebas del Extensor ===\n");
        
        // Prueba 1: 8-bit immediate (positivo)
        $display("Prueba 1: 8-bit immediate (positivo)");
        ImmSrc = 2'b00;
        Instr = 24'h0000FF;  // 255
        #1; check_extend("8-bit pos");
        
        // Prueba 2: 8-bit immediate (pequeño)
        $display("\nPrueba 2: 8-bit immediate (pequeño)");
        ImmSrc = 2'b00;
        Instr = 24'h00000A;  // 10
        #1; check_extend("8-bit small");
        
        // Prueba 3: 12-bit immediate
        $display("\nPrueba 3: 12-bit immediate");
        ImmSrc = 2'b01;
        Instr = 24'h000FFF;  // 4095
        #1; check_extend("12-bit");
        
        // Prueba 4: 24-bit branch (positivo)
        $display("\nPrueba 4: 24-bit branch (positivo)");
        ImmSrc = 2'b10;
        Instr = 24'h000100;  // Salto positivo
        #1; check_extend("24-bit pos");
        
        // Prueba 5: 24-bit branch (negativo)
        $display("\nPrueba 5: 24-bit branch (negativo)");
        ImmSrc = 2'b10;
        Instr = 24'hFFFFFF;  // Salto negativo
        #1; check_extend("24-bit neg");
        
        // Prueba 6: Caso default
        $display("\nPrueba 6: Caso default (ImmSrc inválido)");
        ImmSrc = 2'b11;
        Instr = 24'h000000;
        #1; check_extend("default case");
        
        // Prueba 7: Valores aleatorios
        $display("\nPrueba 7: Valores aleatorios");
        for (int i = 0; i < 3; i++) begin
            Instr = $random;
            ImmSrc = i[1:0];  // 00, 01, 10
            #1; check_extend($sformatf("random-%0d", i));
        end
        
        $display("\n=== Pruebas completadas ===");
        #10 $finish;
    end
    
endmodule