
//`timescale 1ns/1ps
//
//module arm_tb;
//
//  // Señales para el DUT (Device Under Test)
//  logic clk;
//  logic reset;
//  logic [31:0] Instr;
//  logic [31:0] ReadData;
//  logic [31:0] PC;
//  logic MemWrite;
//  logic [31:0] ALUResult;
//  logic [31:0] WriteData;
//
//  // Instancia del módulo bajo prueba
//  arm dut (
//    .clk(clk),
//    .reset(reset),
//    .PC(PC),
//    .Instr(Instr),
//    .MemWrite(MemWrite),
//    .ALUResult(ALUResult),
//    .WriteData(WriteData),
//    .ReadData(ReadData)
//  );
//
//  // Generador de reloj
//  initial begin
//    clk = 0;
//    forever #5 clk = ~clk; // Periodo de 10ns
//  end
//
//  // Procedimiento de prueba
//  initial begin
//    // Inicialización de señales
//    reset = 1;
//    Instr = 32'b0;
//    ReadData = 32'b0;
//
//    // Liberar reset después de unos ciclos
//    #15 reset = 0;
//
//    // Caso de prueba 1: Inicialización
//    #10 Instr = 32'hE3A00001; // Instrucción ficticia: MOV R0, #1
//    #10 Instr = 32'hE2800001; // Instrucción ficticia: ADD R0, R0, #1
//    ReadData = 32'hA5A5A5A5; // Datos ficticios para lectura de memoria
//
//    // Caso de prueba 2: Escritura en memoria
//    #20 Instr = 32'hE58F0000; // Instrucción ficticia: STR R0, [PC, #0]
//    #20 Instr = 32'hE59F0000; // Instrucción ficticia: LDR R0, [PC, #0]
//
//    // Caso de prueba 3: Verificación de la ALU
//    #30 Instr = 32'hE0030091; // Instrucción ficticia: MUL R3, R1, R0
//
//    // Fin de la simulación
//    #100 $finish;
//  end
//
//  // Monitor para observar señales clave
//    initial begin
//    // Monitor más detallado
//    $monitor($time, " clk=%b reset=%b PC=%h Instr=%h MemWrite=%b ALUResult=%h WriteData=%h ReadData=%h",
//             clk, reset, PC, Instr, MemWrite, ALUResult, WriteData, ReadData);
//             
//    // Depuración de señales internas del datapath
//    $monitor("ALUControl=%b ALUSrc=%b RegWrite=%b RegSrc=%b ALUFlags=%b",
//             dut.dp.ALUControl, dut.dp.ALUSrc, dut.dp.RegWrite, dut.dp.RegSrc, dut.dp.ALUFlags);
//  end
//
//
//endmodule



`timescale 1ns/1ps

module arm_tb();
    logic        clk;
    logic        reset;
    logic [31:0] PC;
    logic [31:0] Instr;
    logic        MemWrite;
    logic [31:0] ALUResult;
    logic [31:0] WriteData;
    logic [31:0] ReadData;

    // Instancia del procesador ARM
    arm dut(.*);

    // Generación de reloj
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Task para mostrar resultados detallados
    task automatic display_results;
        input string instruction_name;
        begin
            $display("\nEjecutando %s:", instruction_name);
            $display("  PC        = %h", PC);
            $display("  ALUResult = %h", ALUResult);
            $display("  WriteData = %h", WriteData);
            if (MemWrite)
                $display("  Escribiendo en memoria: dir=%h, dato=%h", ALUResult, WriteData);
        end
    endtask

    // Memoria de instrucciones simulada
    always_comb
        case(PC)
            32'h00: Instr = 32'hE0821003;  // ADD R1, R2, R3
            32'h04: Instr = 32'hE2112064;  // ADDS R1, R2, #100
            32'h08: Instr = 32'hE5921004;  // LDR R1, [R2, #4]
            32'h0C: Instr = 32'hE5821004;  // STR R1, [R2, #4]
            32'h10: Instr = 32'hEA000001;  // B skip
            32'h14: Instr = 32'hE0421003;  // SUB R1, R2, R3
            32'h18: Instr = 32'hE0021003;  // AND R1, R2, R3
            default: Instr = 32'h0;
        endcase

    // Memoria de datos simulada
    always_comb begin
        if (MemWrite) begin
            // Solo mostramos la escritura
        end else begin
            // Datos de prueba para LDR
            case(ALUResult)
                32'h00000006: ReadData = 32'h12345678;
                32'h00000004: ReadData = 32'hAABBCCDD;
                default:      ReadData = 32'h00000000;
            endcase
        end
    end

    // Test
    initial begin
        $display("\n=== Iniciando prueba del procesador ARM ===\n");
        
        // Reset inicial
        reset = 1;
        
        // Forzar valores iniciales en registros
        force dut.dp.rf.rf[2] = 32'h00000002;  // R2 = 2
        force dut.dp.rf.rf[3] = 32'h00000003;  // R3 = 3
        #10;
        
        // Liberar reset y registros forzados
        reset = 0;
        release dut.dp.rf.rf[2];
        release dut.dp.rf.rf[3];

        // Esperar y verificar cada instrucción
        @(posedge clk); 
        display_results("ADD R1, R2, R3");

        @(posedge clk); 
        display_results("ADDS R1, R2, #100");

        @(posedge clk); 
        display_results("LDR R1, [R2, #4]");

        @(posedge clk); 
        display_results("STR R1, [R2, #4]");

        @(posedge clk); 
        display_results("B skip");

        @(posedge clk); 
        display_results("AND R1, R2, R3");

        // Esperar un poco más
        #10;

        $display("\n=== Prueba completada ===");
        $finish;
    end

    // Monitor continuo
    initial begin
        $monitor("Time=%0t PC=%h Instr=%h ALUResult=%h",
                 $time, PC, Instr, ALUResult);
    end
	 
	 // Verificación de WriteData
    always @(posedge clk) begin
        if (ReadData & (Instr[27:25] == 3'b010)) begin // Verifica instrucciones tipo data processing
            assert (WriteData !== 32'hxxxxxxxx)
                else $error("WriteData no está definido en ciclo %0d", $time);
        end
	end

endmodule