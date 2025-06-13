`timescale 1ns/1ps

module datapath_tb;
    // Señales de prueba (Inputs para el datapath)
    logic         clk, reset;
    logic [1:0]   RegSrc;
    logic         RegWrite;
    logic [1:0]   ImmSrc;
    logic [1:0]   ALUSrc;
    logic [2:0]   ALUControl;
    logic         MemWrite;
    logic         MemtoReg;
    logic         PCSrc;
    logic         BL;
    logic         ShiftEn;
    logic [31:0]  Instr;
    logic [31:0]  ReadData; // Dato leído de la memoria de datos

    // Señales para capturar las salidas del datapath
    logic [31:0] PC;
    logic [31:0] ALUResult;
    logic [31:0] WriteData; // Dato a escribir en la memoria de datos
    logic [3:0]  ALUFlags;

    // ******* NUEVAS SEÑALES LOCALES PARA CONECTAR LOS REGISTROS EXPORTADOS *******
    logic [31:0] r0_tb_val;
    logic [31:0] r1_tb_val;
    logic [31:0] r2_tb_val;
    logic [31:0] r3_tb_val;

    // Instancia del datapath (¡Usando mapeo de puertos explícito!)
    datapath dut(
        .clk(clk),
        .reset(reset),
        .RegSrc(RegSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc),
        .BL(BL),
        .ShiftEn(ShiftEn),
        .PC(PC),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .Instr(Instr),
        .ALUFlags(ALUFlags),
        // ******* CONECTAR LAS NUEVAS SALIDAS DE REGISTRO DEL DATAPATH ********
        .r0_val(r0_tb_val),
        .r1_val(r1_tb_val),
        .r2_val(r2_tb_val),
        .r3_val(r3_tb_val)
    );

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
        RegWrite = 0; // Asegurarse de que esté en 0 durante el reset
        MemWrite = 0; // Asegurarse de que esté en 0 durante el reset
        // Todas las demás señales de control a un estado "seguro" o 0
        RegSrc = 2'b00;
        ImmSrc = 2'b00;
        ALUSrc = 2'b00;
        ALUControl = 3'b000;
        MemtoReg = 0;
        PCSrc = 0;
        BL = 0;
        ShiftEn = 0;
        ReadData = 32'h0;
        Instr = 32'h0;

        #10; // Mantener reset activo por un ciclo de reloj
        reset = 0;
        #10; // Dejar que el procesador comience (PC=0)

        // Forzar valores iniciales en registros para pruebas
        // Usamos 'force' en las SALIDAS del register_file para simular que los registros ya tienen esos valores.
        // Esto es útil para probar la ALU y la escritura sin simular instrucciones de carga completas.
        force dut.rf.rd1 = 32'h0000000A; // Simula que el registro fuente 1 (ej. R2) tiene 10
        force dut.rf.rd2 = 32'h00000005; // Simula que el registro fuente 2 (ej. R3) tiene 5

        // Prueba 1: ADD R1, R2, R3 (simulando R2=10, R3=5, R1=15)
        $display("\nPrueba 1: ADD R1, R2, R3 (R2=%h, R3=%h)", dut.rf.rd1, dut.rf.rd2);
        Instr = 32'hE0811002; // Instrucción ADD R1, R2, R3 (Rd=R1, Rn=R2, Rm=R3)
        RegSrc = 2'b00;       // Selecciona Rd del campo Instr[15:12] (R1)
        ImmSrc = 2'b00;       // No immediate used
        ALUSrc = 2'b00;       // SrcB viene de PreSrcB (que a su vez viene de RD2, es decir, R3)
        ALUControl = 3'b000;  // ADD operation
        MemtoReg = 0;         // El dato a escribir viene de ALUResult
        MemWrite = 0;         // No se escribe en memoria de datos
        RegWrite = 1;         // ¡HABILITAR ESCRITURA EN EL REGISTRO!
        PCSrc = 0;
        BL = 0;
        ShiftEn = 0;
        #10; // Avanzar un ciclo de reloj para que la operación se realice y se escriba
        RegWrite = 0;         // Deshabilitar RegWrite para el siguiente ciclo
        Instr = 32'h0;        // Limpiar instrucción
        $display("  SrcA = %h", dut.SrcA);
        $display("  SrcB = %h", dut.SrcB);
        $display("  ALUResult = %h", ALUResult);
        $display("  R0=%h R1=%h R2=%h R3=%h (después de escribir R1)", r0_tb_val, r1_tb_val, r2_tb_val, r3_tb_val);

        // Liberar valores forzados y forzar nuevos para siguiente prueba
        release dut.rf.rd1;
        release dut.rf.rd2;
        force dut.rf.rd1 = 32'h0000000F; // Simula que R2 ahora tiene el valor 15 (del resultado anterior, si fuera real)

        // Prueba 2: ADD R1, R2, #100 (simulando R2=15, Inmediato=100, R1=115)
        $display("\nPrueba 2: ADD R1, R2, #100 (R2=%h)", dut.rf.rd1);
        Instr = 32'hE2821064; // Instrucción ADD R1, R2, #100 (Rd=R1, Rn=R2, Imm=100)
        RegSrc = 2'b00;
        ImmSrc = 2'b00;       // Asumiendo que tu ExtImm usa ImmSrc=00 para este tipo de inmediato
        ALUSrc = 2'b01;       // SrcB viene de ExtImm
        ALUControl = 3'b000;  // ADD operation
        MemtoReg = 0;
        MemWrite = 0;
        RegWrite = 1;         // ¡HABILITAR ESCRITURA EN EL REGISTRO!
        PCSrc = 0;
        BL = 0;
        ShiftEn = 0;
        #10;
        RegWrite = 0;
        Instr = 32'h0;
        $display("  SrcA = %h", dut.SrcA);
        $display("  Imm = %h", dut.ExtImm); // Asumiendo que ExtImm es una señal visible en datapath
        $display("  ALUResult = %h", ALUResult);
        $display("  R0=%h R1=%h R2=%h R3=%h (después de escribir R1)", r0_tb_val, r1_tb_val, r2_tb_val, r3_tb_val);

        // Liberar valores y forzar para LDR
        release dut.rf.rd1;
        force dut.rf.rd1 = 32'h00002000; // Simula que R2 tiene una dirección base para LDR

        // Prueba 3: LDR R1, [R2, #4] (simulando R2=0x2000, offset=4, ReadData=0x12345678)
        $display("\nPrueba 3: LDR R1, [R2, #4] (R2=%h)", dut.rf.rd1);
        Instr = 32'hE5921004; // Instrucción LDR R1, [R2, #4] (Rd=R1, Rn=R2, Imm=4)
        RegSrc = 2'b00;
        ImmSrc = 2'b01;       // Immediate offset for LDR
        ALUSrc = 2'b01;       // SrcB viene de ExtImm (offset para calcular dirección)
        ALUControl = 3'b000;  // ADD para cálculo de dirección (Base + Offset)
        MemtoReg = 1;         // ¡El dato a escribir viene de ReadData!
        MemWrite = 0;
        RegWrite = 1;         // ¡HABILITAR ESCRITURA EN EL REGISTRO!
        PCSrc = 0;
        BL = 0;
        ShiftEn = 0;
        ReadData = 32'h12345678; // Simula el dato leído de memoria
        #10;
        RegWrite = 0;
        Instr = 32'h0;
        $display("  Base = %h", dut.SrcA);
        $display("  Offset = %h", dut.ExtImm);
        $display("  Dirección calculada (ALUResult) = %h", ALUResult);
        $display("  ReadData = %h", ReadData);
        $display("  R0=%h R1=%h R2=%h R3=%h (después de escribir R1)", r0_tb_val, r1_tb_val, r2_tb_val, r3_tb_val);


        // Liberar todos los valores forzados
        release dut.rf.rd1;
        release dut.rf.rd2;

        $display("\n=== Pruebas completadas ===\n");
        #10 $finish;
    end

    // Monitor continuo de señales críticas del datapath
    initial begin
        $monitor("Time=%0t | PC=%h | Instr=%h | ALUResult=%h | WriteData=%h | ReadData=%h | R0=%h R1=%h R2=%h R3=%h | Flags: Z=%b N=%b C=%b V=%b",
                 $time,
                 PC,
                 Instr,
                 ALUResult,
                 WriteData,
                 ReadData,
                 r0_tb_val, // Se usan las nuevas señales locales del testbench
                 r1_tb_val,
                 r2_tb_val,
                 r3_tb_val,
                 ALUFlags[2],    // Z flag (bit 2 de ALUFlags)
                 ALUFlags[3],    // N flag (bit 3 de ALUFlags)
                 ALUFlags[1],    // C flag (bit 1 de ALUFlags)
                 ALUFlags[0]     // V flag (bit 0 de ALUFlags)
        );
    end

endmodule