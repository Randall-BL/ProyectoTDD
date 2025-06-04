
module shifter_tb;

    // Declaracion de señales de prueba
    logic [4:0] shift_amount;
    logic [1:0] shift_type;
    logic mul;
    logic [31:0] rd2;
    logic [31:0] data;

    // Instancia del DUT (Device Under Test)
    shifter uut (
        .shift_amount(shift_amount),
        .shift_type(shift_type),
        .mul(mul),
        .rd2(rd2),
        .data(data)
    );

    // Procedimiento inicial para ejecutar los casos de prueba
    initial begin
        $display("Iniciando pruebas para el modulo shifter...");
        $display("Formato: shift_type | mul | shift_amount | rd2 | data (resultado)");

        // Caso 1: Desplazamiento logico a la izquierda (SLL)
        shift_amount = 5'd2;
        shift_type = 2'b00;
        mul = 1'b0;
        rd2 = 32'h0000_00FF;
        #10;
        $display("Caso 1: %b | %b | %d | %h | %h", shift_type, mul, shift_amount, rd2, data);

        // Caso 2: Desplazamiento logico a la derecha (SRL)
        shift_amount = 5'd3;
        shift_type = 2'b01;
        mul = 1'b0;
        rd2 = 32'hF000_000F;
        #10;
        $display("Caso 2: %b | %b | %d | %h | %h", shift_type, mul, shift_amount, rd2, data);

        // Caso 3: Desplazamiento aritmetico a la derecha (ASR)
        shift_amount = 5'd4;
        shift_type = 2'b10;
        mul = 1'b0;
        rd2 = 32'h8000_0000; // Caso negativo (bit MSB en 1)
        #10;
        $display("Caso 3: %b | %b | %d | %h | %h", shift_type, mul, shift_amount, rd2, data);

        // Caso 4: Sin desplazamiento (multiplicacion activada)
        shift_amount = 5'd0;
        shift_type = 2'b11; // No importa el tipo en este caso
        mul = 1'b1;
        rd2 = 32'h1234_5678;
        #10;
        $display("Caso 4: %b | %b | %d | %h | %h", shift_type, mul, shift_amount, rd2, data);

        // Caso 5: Tipo de desplazamiento invalido
        shift_amount = 5'd5;
        shift_type = 2'b11; // Tipo invalido
        mul = 1'b0;
        rd2 = 32'hFFFF_0000;
        #10;
        $display("Caso 5: %b | %b | %d | %h | %h", shift_type, mul, shift_amount, rd2, data);

        $display("Pruebas finalizadas.");
        $stop;
    end

endmodule




//`timescale 1ns/1ps
//
//module shifter_tb();
//    // Señales de prueba
//    logic [31:0] a;
//    logic [4:0]  shamt;
//    logic [1:0]  sh_type;
//    logic [31:0] y;
//    
//    // Instancia del módulo a probar
//    shifter dut(
//        .a(a),
//        .shamt(shamt),
//        .sh_type(sh_type),
//        .y(y)
//    );
//    
//    // Función de verificación
//    function automatic void check_shift(string test_name);
//        logic [31:0] expected;
//        
//        case(sh_type)
//            2'b00: expected = a << shamt;
//            2'b01: expected = a >> shamt;
//            2'b10: expected = $signed(a) >>> shamt;
//            2'b11: expected = (a >> shamt) | (a << (32-shamt));
//        endcase
//        
//        if (y !== expected) begin
//            $display("Error en %s:", test_name);
//            $display("  Entrada: %h", a);
//            $display("  Shamt: %d, Tipo: %b", shamt, sh_type);
//            $display("  Resultado: %h", y);
//            $display("  Esperado: %h", expected);
//        end else begin
//            $display("Correcto - %s:", test_name);
//            $display("  Entrada: %h", a);
//            $display("  Shamt: %d, Tipo: %b", shamt, sh_type);
//            $display("  Resultado: %h", y);
//        end
//    endfunction
//    
//    // Estímulos
//    initial begin
//        $display("\n=== Iniciando pruebas del Shifter ===\n");
//        
//        // Prueba 1: LSL básico
//        $display("Prueba 1: LSL ");
//        a = 32'h0000_00FF;
//        shamt = 5'd4;
//        sh_type = 2'b00;
//        #1; check_shift("LSL ");
//        
//        // Prueba 2: LSR básico
//        $display("\nPrueba 2: LSR ");
//        a = 32'hFF00_0000;
//        shamt = 5'd4;
//        sh_type = 2'b01;
//        #1; check_shift("LSR ");
//        
//        // Prueba 3: ASR con número positivo
//        $display("\nPrueba 3: ASR positivo");
//        a = 32'h7F00_0000;
//        shamt = 5'd4;
//        sh_type = 2'b10;
//        #1; check_shift("ASR positivo");
//        
//        // Prueba 4: ASR con número negativo
//        $display("\nPrueba 4: ASR negativo");
//        a = 32'hFF00_0000;
//        shamt = 5'd4;
//        sh_type = 2'b10;
//        #1; check_shift("ASR negativo");
//        
//        // Prueba 5: ROR básico
//        $display("\nPrueba 5: ROR ");
//        a = 32'hF000_000F;
//        shamt = 5'd4;
//        sh_type = 2'b11;
//        #1; check_shift("ROR ");
//        
//        // Prueba 6: Desplazamiento de 0 bits
//        $display("\nPrueba 6: Sin desplazamiento");
//        a = 32'hAAAA_AAAA;
//        shamt = 5'd0;
//        sh_type = 2'b00;
//        #1; check_shift("Sin desplazamiento");
//        
//        // Prueba 7: Desplazamiento máximo
//        $display("\nPrueba 7: Desplazamiento maximo");
//        a = 32'hFFFF_FFFF;
//        shamt = 5'd31;
//        sh_type = 2'b00;
//        #1; check_shift("Desplazamiento maximo");
//        
//        // Prueba 8: Valor aleatorio
//        $display("\nPrueba 8: Valor aleatorio");
//        a = $random;
//        shamt = $random & 5'h1F;
//        sh_type = $random & 2'b11;
//        #1; check_shift("Valor aleatorio");
//        
//        $display("\n=== Pruebas completadas ===");
//        #10 $finish;
//    end
//    
//endmodule