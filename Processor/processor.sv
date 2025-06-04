module processor(
    input  logic        clk,
    input  logic        reset,
	 input  logic			next_state_vga,
	 
	 
	 // Señales de entrada en la VGA
    output logic vgaclk, // 25.175 MHz VGA clock
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

    // Procesador ARM
    arm arm(
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData)
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
        .nxt(next_state_vga), // Usando `reset` para la señal `nxt` en este caso
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

// PARA COMPILAR MAS RAPIDO Y PROBAR EL PROCE (TESTBENCH) USAR ESTE
// Y COMENTAR EL OTRO

//module processor(
//    input  logic        clk,
//    input  logic        reset
//);
//    // Señales internas del procesador
//    logic [31:0] PC;
//    logic [31:0] Instr;
//    logic [31:0] ReadData;
//    logic [31:0] WriteData;
//    logic [31:0] ALUResult;
//    logic        MemWrite;
//
//    // Procesador ARM
//    arm arm(
//        .clk(clk),
//        .reset(reset),
//        .PC(PC),
//        .Instr(Instr),
//        .MemWrite(MemWrite),
//        .ALUResult(ALUResult),
//        .WriteData(WriteData),
//        .ReadData(ReadData)
//    );
//
//    // Memoria de Instrucciones
//    instruction_memory imem(
//        .A(PC),
//        .RD(Instr)
//    );
//
//    // Memoria de Datos
//    data_memory dmem(
//        .clk(clk),
//        .mem_write(MemWrite),
//        .address(ALUResult),
//        .write_data(WriteData),
//        .read_data(ReadData)
//    );
//
//endmodule