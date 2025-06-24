`timescale 1ns/1ps

module controller_tb;

  // Declaracion de señales
  logic        clk;
  logic        reset;
  logic [31:0] Instr;
  logic [3:0]  ALUFlags;
  logic [1:0]  RegSrc;
  logic        RegWrite;
  logic [1:0]  ImmSrc;
  logic        ALUSrc;
  logic [2:0]  ALUControl;
  logic        MemWrite;
  logic        MemtoReg;
  logic        PCSrc;

  // Instancia del DUT (Device Under Test)
  controller dut (
    .clk(clk),
    .reset(reset),
    .Instr(Instr),
    .ALUFlags(ALUFlags),
    .RegSrc(RegSrc),
    .RegWrite(RegWrite),
    .ImmSrc(ImmSrc),
    .ALUSrc(ALUSrc),
    .ALUControl(ALUControl),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .PCSrc(PCSrc)
  );

  // Generacion de reloj (50 MHz)
  always #10 clk = ~clk;

  // Procedimiento inicial
  initial begin
    // Configuracion inicial
    clk      = 0;
    reset    = 1;
    Instr    = 32'h00000000;
    ALUFlags = 4'b0000;

    // Monitoreo de señales
    $monitor($time, " clk=%b reset=%b Instr=%h ALUFlags=%b | RegSrc=%b RegWrite=%b ImmSrc=%b ALUSrc=%b ALUControl=%b MemWrite=%b MemtoReg=%b PCSrc=%b",
             clk, reset, Instr, ALUFlags, RegSrc, RegWrite, ImmSrc, ALUSrc, ALUControl, MemWrite, MemtoReg, PCSrc);

    // Inicio de la simulacion
    #15 reset = 0;                      // Desactiva reset
    #10 Instr = 32'hE3A00001;           // Instruccion: MOV R0, #1
    #20 Instr = 32'hE2800001;           // Instruccion: ADD R0, R0, #1
    #20 Instr = 32'hE58F0000;           // Instruccion: STR R0, [PC]
    #20 Instr = 32'hE59F0000;           // Instruccion: LDR R0, [PC]
    #20 Instr = 32'hE0030091;           // Instruccion: MUL R0, R1, R2
    #20 ALUFlags = 4'b1010;             // Actualiza las banderas de la ALU
    #20 Instr = 32'h00000000;           // NOP
    #20 Instr = 32'hEA00000A;           // Instruccion: B (branch)
    #50 $finish;                        // Finaliza la simulacion
  end

  // Tareas para visualizar mejor las señales (opcional)
  task display_signals;
    $display("Time: %0t | clk=%b reset=%b Instr=%h ALUFlags=%b", $time, clk, reset, Instr, ALUFlags);
    $display("          | RegSrc=%b RegWrite=%b ImmSrc=%b ALUSrc=%b ALUControl=%b", RegSrc, RegWrite, ImmSrc, ALUSrc, ALUControl);
    $display("          | MemWrite=%b MemtoReg=%b PCSrc=%b", MemWrite, MemtoReg, PCSrc);
  endtask

endmodule
