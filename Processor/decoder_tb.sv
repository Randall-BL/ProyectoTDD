
module decoder_tb;

    // Señales de prueba
    logic [1:0] Op;
    logic [5:0] Funct;
    logic [3:0] Rd, Mul, movhi;
    logic [1:0] FlagW;
    logic PCS, RegW, MemW, NoWrite;
    logic MemtoReg, ALUSrc;
    logic [1:0] ImmSrc, RegSrc;
    logic [2:0] ALUControl;

    // Instancia del DUT (Device Under Test)
    decoder uut (
        .Op(Op),
        .Funct(Funct),
        .Rd(Rd),
        .Mul(Mul),
        .movhi(movhi),
        .FlagW(FlagW),
        .PCS(PCS),
        .RegW(RegW),
        .MemW(MemW),
        .NoWrite(NoWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl)
    );

    // Procedimiento inicial para pruebas
    initial begin
        // Visualización del encabezado
        $display("Tiempo | Op  | Funct  | Rd    | Mul   | movhi | ALUControl | PCS | RegW | MemW | NoWrite | MemtoReg | ALUSrc | ImmSrc | RegSrc | FlagW");
        $monitor("%0t      | %b | %b | %b | %b | %b |    %b     |  %b  |  %b  |  %b  |    %b    |    %b     |   %b   |   %b   |   %b   |  %b  ", 
                 $time, Op, Funct, Rd, Mul, movhi, ALUControl, PCS, RegW, MemW, NoWrite, MemtoReg, ALUSrc, ImmSrc, RegSrc, FlagW);

        // Prueba 1: Operación ADD
        Op = 2'b00;
        Funct = 6'b000100; // ADD
        Rd = 4'b0000;
        Mul = 4'b0000;
        movhi = 4'b0000;
        #10;

        // Prueba 2: Operación SUB
        Funct = 6'b000010; // SUB
        #10;

        // Prueba 3: Operación MUL
        Funct = 6'b000000;
        Mul = 4'b1001; // Indica multiplicación
        #10;

        // Prueba 4: Operación MOV
        Funct = 6'b011101;
        movhi = 4'b1110; // Indica MOVHI
        #10;

        // Prueba 5: LDR
        Op = 2'b01;
        Funct = 6'bxxxxxx;
        #10;

        // Prueba 6: STR
        Funct = 6'b000000; // No Funct específico
        #10;

        // Prueba 7: Instrucción de Branch (B)
        Op = 2'b10;
        Rd = 4'b1111;
        #10;

        // Prueba 8: Operación no implementada
        Op = 2'b11; // Op no válido
        Funct = 6'bxxxxxx;
        #10;

        $display("Fin de pruebas.");
        $stop;
    end

endmodule




//`timescale 1ns/1ps
//
//module decoder_tb();
//    // Señales de prueba
//    logic [31:0] Instr;
//    logic [3:0]  ALUFlags;
//    logic [1:0]  RegSrc;
//    logic        RegWrite;
//    logic [1:0]  ImmSrc;
//    logic [1:0]  ALUSrc;
//    logic [1:0]  ALUControl;
//    logic        MemWrite;
//    logic        MemtoReg;
//    logic        PCS;
//    logic [1:0]  FlagW;
//	 logic [1:0]  Op;
//    logic        BL;
//
//    // Instancia del decoder
//    decoder dut(.*);
//
//    // Task para mostrar resultados
//    task display_results;
//        input string instruction_type;
//        begin
//            $display("\nTesting %s:", instruction_type);
//            $display("  RegSrc     = %b", RegSrc);
//            $display("  RegWrite   = %b", RegWrite);
//            $display("  ImmSrc     = %b", ImmSrc);
//            $display("  ALUSrc     = %b", ALUSrc);
//            $display("  ALUControl = %b", ALUControl);
//            $display("  MemWrite   = %b", MemWrite);
//            $display("  MemtoReg   = %b", MemtoReg);
//            $display("  PCS        = %b", PCS);
//            $display("  FlagW      = %b", FlagW);
//            $display("  BL         = %b", BL);
//        end
//    endtask
//
//    // Estímulos
//    initial begin
//        $display("=== Starting Decoder Tests ===\n");
//        ALUFlags = 4'b0000;  // Inicializar flags
//
//        // Test 1: ADD R1, R2, R3
//        Instr = 32'hE0821003;  // ADD R1, R2, R3
//        #10;
//        display_results("ADD R1, R2, R3");
//
//        // Test 2: ADDS R1, R2, #100
//        Instr = 32'hE2921064;  // ADDS R1, R2, #100
//        #10;
//        display_results("ADDS R1, R2, #100");
//
//        // Test 3: LDR R1, [R2, #4]
//        Instr = 32'hE5921004;  // LDR R1, [R2, #4]
//        #10;
//        display_results("LDR R1, [R2, #4]");
//
//        // Test 4: STR R1, [R2, #4]
//        Instr = 32'hE5821004;  // STR R1, [R2, #4]
//        #10;
//        display_results("STR R1, [R2, #4]");
//
//        // Test 5: B label (branch)
//        Instr = 32'hEA000100;  // B label
//        #10;
//        display_results("B label");
//
//        // Test 6: BL label (branch with link)
//        Instr = 32'hEB000100;  // BL label
//        #10;
//        display_results("BL label");
//
//        // Test 7: SUB R1, R2, R3
//        Instr = 32'hE0421003;  // SUB R1, R2, R3
//        #10;
//        display_results("SUB R1, R2, R3");
//
//        // Test 8: AND R1, R2, R3
//        Instr = 32'hE0021003;  // AND R1, R2, R3
//        #10;
//        display_results("AND R1, R2, R3");
//
//        // Test 9: ORR R1, R2, R3
//        Instr = 32'hE1821003;  // ORR R1, R2, R3
//        #10;
//        display_results("ORR R1, R2, R3");
//
//        $display("\n=== Decoder Tests Completed ===");
//        #10 $finish;
//    end
//
//    // Monitor para verificar cambios
//    initial begin
//        $monitor("Time=%0t Instr=%h", $time, Instr);
//    end
//
//endmodule