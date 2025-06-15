// processor.sv

module processor(
    input  logic         clk,
    input  logic         reset,
    input  logic         next_state_vga,
    
    // Señales de salida en la VGA
    output logic vgaclk,
    output logic hsync, vsync,
    output logic sync_b, blank_b,
    output logic [7:0] r, g, b
);
    // Señales internas del procesador
    logic [31:0] PC;
    logic [31:0] Instr;
    logic [31:0] ReadData;
    logic [31:0] WriteData;
    logic [31:0] ALUResult;
    logic        MemWrite;
    
    // Estas señales internas se usaban para el monitor en el testbench
    logic        RegWrite;
    logic        MemtoReg;
    logic [3:0]  A3;
    
    // *** SEÑALES INTERNAS PARA REGISTROS QUE ERAN MONITOREADAS ***
    // Estas solo se declaraban internamente, no eran puertos de salida
    logic [31:0] tb_R0_val;
    logic [31:0] tb_R1_val;
    logic [31:0] tb_R2_val;
    logic [31:0] tb_R3_val;
    logic [31:0] tb_R7_val;
    
    // Procesador ARM
    arm arm_inst(
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData),
        
        // Conexiones de las señales de control para el monitor
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .A3(A3),
        
        // Conexiones de los puertos de registro que sí existían
        .R0_val(tb_R0_val),
        .R1_val(tb_R1_val),
        .R2_val(tb_R2_val),
        .R3_val(tb_R3_val),
        .R7_val(tb_R7_val)
    );
    
    // Memoria de Instrucciones
    instruction_memory imem(
        .A(PC),
        .RD(Instr)
    );
    
    // Memoria de Datos
    data_memory dmem(
        .clk(clk),
        .mem_write(MemWrite),
        .address(ALUResult),
        .write_data(WriteData),
        .read_data(ReadData)
    );
    
    // Instanciación de la inicialización de VGA
    vga_initializer vga_inst(
        .clk(clk),
        .nxt(next_state_vga),
        .vgaclk(vgaclk),
        .hsync(hsync),
        .vsync(vsync),
        .sync_b(sync_b),
        .blank_b(blank_b),
        .r(r),
        .g(g),
        .b(b)
    );
endmodule