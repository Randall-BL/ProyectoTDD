module ram (
    input  wire        clk,      // Relo
    input  wire        we,       // Habilitación de escritura
    input  wire [9:0]  addr,     // Dirección (0-1023)
    input  wire [31:0] data_in,  // Dato a escribir
    output reg  [31:0] data_out  // Dato leído
);

reg [31:0] mem [0:1023];  // Memoria de 1024 palabras x 32 bits

// Inicializar memoria desde archivo .dat
initial begin
    $readmemh("D:/TEC/FUNDA/final/v22/data_test_suma.dat", mem);
end

// Escritura síncrona
always @(posedge clk) begin
    if (we) begin
        mem[addr] <= data_in;  // Escribe en memoria
    end
    data_out <= mem[addr];     // Lectura continua
end

endmodule