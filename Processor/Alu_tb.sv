`timescale 1ns/1ps

module alu_tb();
    // Parámetros y señales
    localparam N = 32;
    
    logic [N-1:0] A, B;
    logic [2:0]   ALU_Sel;    
    logic [2*N-1:0] ALU_Result; 
    logic [3:0]   ALU_Flags;
    
    // Instancia de la ALU
    alu #(N) dut(
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .ALU_Result(ALU_Result),
        .ALU_Flags(ALU_Flags)
    );
    
    // Función de verificación
    function automatic void check_alu(string test_name);
        logic [2*N-1:0] expected_result;  // Cambiar a 2*N bits para MUL
        logic [3:0] expected_flags;
        logic N_flag, Z_flag, C_flag, V_flag;
        
        case(ALU_Sel)
            3'b000: begin // ADD
                expected_result = A + B;
                C_flag = (A + B) < A; // Carry si el resultado es menor que A
                V_flag = (~A[N-1] & ~B[N-1] & expected_result[N-1]) | 
                         (A[N-1] & B[N-1] & ~expected_result[N-1]); // Overflow
            end
            3'b001: begin // SUB
                expected_result = A - B;
                C_flag = A >= B; // Carry si A es mayor o igual que B
                V_flag = (~A[N-1] & B[N-1] & expected_result[N-1]) |
                         (A[N-1] & ~B[N-1] & ~expected_result[N-1]); // Overflow
            end
            3'b010: begin // AND
                expected_result = A & B;
                C_flag = 0;
                V_flag = 0;
            end
            3'b011: begin // OR
                expected_result = A | B;
                C_flag = 0;
                V_flag = 0;
            end
            3'b100: begin // MUL
                expected_result = A * B;
                C_flag = 0;  // No aplica carry en MUL
                V_flag = 0;  // No aplica overflow en MUL
            end
            3'b101: begin // MOV
                expected_result = B;
                C_flag = 0;
                V_flag = 0;
            end
        endcase
        
        N_flag = expected_result[N-1];
        Z_flag = (expected_result == 0);
        expected_flags = {N_flag, Z_flag, C_flag, V_flag};
        
        if (ALU_Result !== expected_result || ALU_Flags !== expected_flags) begin
            $display("Error en %s:", test_name);
            $display("  A=%h, B=%h, ALU_Sel=%b", A, B, ALU_Sel);
            $display("  Resultado: %h (esperado: %h)", ALU_Result, expected_result);
            $display("  Flags: NZCV=%b (esperado: %b)", ALU_Flags, expected_flags);
        end else begin
            $display("Correcto - %s:", test_name);
            $display("  A=%h, B=%h, ALU_Sel=%b", A, B, ALU_Sel);
            $display("  Resultado: %h", ALU_Result);
            $display("  Flags: N=%b, Z=%b, C=%b, V=%b", 
                    ALU_Flags[3], ALU_Flags[2], ALU_Flags[1], ALU_Flags[0]);
        end
    endfunction
    
    // Estímulos y verificación
    initial begin
        $display("=== Iniciando pruebas de la ALU ===\n");
        
        // Prueba 1: Suma 
        $display("Prueba 1: SUM");
        ALU_Sel = 3'b000;  
        A = 32'h0000_000A;
        B = 32'h0000_0005;
        #1; check_alu("SUM");
        
        // Prueba 2: Suma con carry
        $display("\nPrueba 2: SUM carry");
        A = 32'h0000_FFFF;
        B = 32'h0000_0001;
        #1; check_alu("suma con carry");
        
        // Prueba 3: Resta 
        $display("\nPrueba 3: SUB");
        ALU_Sel = 3'b001;  
        A = 32'h0000_000A;
        B = 32'h0000_0005;
        #1; check_alu("SUB");
        
        // Prueba 4: Resta con resultado negativo
        $display("\nPrueba 4: SUB NEGATIVE");
        A = 32'h0000_0002;
        B = 32'h0000_0005;
        #1; check_alu("SUB NEGATIVE");
        
        // Prueba 5: AND
        $display("\nPrueba 5: AND");
        ALU_Sel = 3'b010;  
        A = 32'hFFFF_0000;
        B = 32'h0000_FFFF;
        #1; check_alu("AND");
        
        // Prueba 6: OR
        $display("\nPrueba 6: OR");
        ALU_Sel = 3'b011;  
        A = 32'hFFFF_0000;
        B = 32'h0000_FFFF;
        #1; check_alu("OR");
        
        // Prueba 7: Resultado cero
        $display("\nPrueba 7: RESULT ZERO");
        ALU_Sel = 3'b001;  
        A = 32'h0000_0005;
        B = 32'h0000_0005;
        #1; check_alu("RESULT ZERO");
        
        // Prueba 8: Overflow en suma
        $display("\nPrueba 8: SUM OVERFLOW");
        ALU_Sel = 3'b000;  
        A = 32'h700F_FFFF;
        B = 32'h0000_0001;
        #1; check_alu("SUM OVERFLOW");
        
        // Prueba 9: Mult
        $display("\nPrueba 9: MULT");
        ALU_Sel = 3'b100;  
        A = 32'h0000_0006;
        B = 32'h0000_0003;
        #1; check_alu("MULT");
		  
		  //Prueba 10: Mov
		  $display("\nPrueba 10: MOV");
        ALU_Sel = 3'b101;  
        A = 32'h0000_0004;
        B = 32'h0000_0002;
        #1; check_alu("MOV");
        
        $display("\n=== TEST COMPLETE ===");
        #10 $finish;
    end
    
endmodule
