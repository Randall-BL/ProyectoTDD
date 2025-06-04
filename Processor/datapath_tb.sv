`timescale 1ns/1ps

module datapath_tb();
    // Señales de prueba
    logic        clk, reset;
    logic [1:0]  RegSrc;
    logic        RegWrite;
    logic [1:0]  ImmSrc;
    logic [1:0]  ALUSrc;
    logic [2:0]  ALUControl;
    logic        MemWrite;
    logic        MemtoReg;
    logic        PCSrc;
    logic        BL;
    logic        ShiftEn;
    logic [31:0] PC;
	 logic [1:0]  Op;
    logic [31:0] ALUResult;
    logic [31:0] WriteData;
    logic [31:0] ReadData;
    logic [31:0] Instr;
    logic [3:0]  ALUFlags;

    // Instancia del datapath
    datapath dut(.*);

    // Generación de reloj
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Estímulos
    initial begin
        $display("\n=== Iniciando pruebas del Datapath ===\n");

        // Reset inicial
        reset = 1;
        RegSrc = 2'b00;
        RegWrite = 0;
        ImmSrc = 2'b00;
        ALUSrc = 2'b00;
        ALUControl = 2'b000;
        MemWrite = 0;
        MemtoReg = 0;
        PCSrc = 0;
        BL = 0;
        ShiftEn = 0;
        ReadData = 32'h0;
        Instr = 32'h0;
        #10;
        reset = 0;
        #10;

        // Forzar valores iniciales en registros para pruebas
        force dut.rf.rd1 = 32'h22222222;  // R2
        force dut.rf.rd2 = 32'h33333333;  // R3
        
        // Prueba 1: ADD R1, R2, R3
        $display("\nPrueba 1: ADD R1, R2, R3");
        Instr = 32'hE0821003;
        RegSrc = 2'b00;
        RegWrite = 1;
        ImmSrc = 2'b00;
        ALUSrc = 2'b00;
        ALUControl = 2'b000;
        #10;
        $display("  SrcA = %h", dut.SrcA);
        $display("  SrcB = %h", dut.SrcB);
        $display("  ALUResult = %h", ALUResult);

        // Liberar valores forzados y forzar nuevos para siguiente prueba
        release dut.rf.rd1;
        release dut.rf.rd2;
        force dut.rf.rd1 = 32'h22222222;  // R2

        // Prueba 2: ADD R1, R2, #100
        $display("\nPrueba 2: ADD R1, R2, #100");
        Instr = 32'hE2821064;
        ALUSrc = 2'b000;
        #10;
        $display("  SrcA = %h", dut.SrcA);
        $display("  Imm = %h", dut.ExtImm);
        $display("  ALUResult = %h", ALUResult);

        // Liberar valores y forzar para LDR
        release dut.rf.rd1;
        force dut.rf.rd1 = 32'h22222222;  // R2

        // Prueba 3: LDR R1, [R2, #4]
        $display("\nPrueba 3: LDR R1, [R2, #4]");
        Instr = 32'hE5921004;
        RegSrc = 2'b00;
        RegWrite = 1;
        ImmSrc = 2'b01;
        ALUSrc = 2'b01;
        ALUControl = 2'b111;
        MemtoReg = 1;
        ReadData = 32'h12345678;
        #10;
        $display("  Base = %h", dut.SrcA);
        $display("  Offset = %h", dut.ExtImm);
        $display("  ALUResult = %h", ALUResult);
        $display("  ReadData = %h", ReadData);

        // Liberar todos los valores forzados
        release dut.rf.rd1;
        release dut.rf.rd2;

        $display("\n=== Pruebas completadas ===");
        #10 $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t PC=%h Instr=%h ALUResult=%h Flags=%b",
                 $time, PC, Instr, ALUResult, ALUFlags);
    end

endmodule