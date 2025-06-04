module data_memory(
    input  logic        clk,
    input  logic        mem_write,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);
    logic [31:0] RAM[9:0];  // 10 palabras de 32 bits (para tus 10 valores)
    logic [31:0] read_reg;  

    // Inicialización de memoria desde archivo
    initial begin
        $readmemh("./image_data.mem", RAM);
        // Verificación de carga (opcional)
        $display("Memoria cargada:");
        for (int i = 0; i < 10; i++) begin
            $display("RAM[%0d] = %h", i, RAM[i]);
        end
    end

    // Lectura en flanco positivo
    always_ff @(posedge clk) begin
        read_reg <= RAM[address[31:2]];
    end

    // Escritura en flanco negativo
    always_ff @(negedge clk) begin
        if (mem_write)
            RAM[address[31:2]] <= write_data;
    end

    assign read_data = read_reg;

endmodule