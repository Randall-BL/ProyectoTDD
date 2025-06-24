module flopr #(parameter WIDTH = 8) // Ancho parametrizable del registro (por defecto, 8 bits)
    (
        input logic clk,           // Señal de reloj
        input logic reset,         // Señal de reset asíncrono
        input logic [WIDTH-1:0] d, // Entrada de datos al registro
        output logic [WIDTH-1:0] q // Salida del registro (datos almacenados)
    );

    // Bloque siempre_ff para describir lógica secuencial
    always_ff @(posedge clk, posedge reset) begin
        if (reset) 
            q <= 0; // Si reset está activo, el registro se inicializa a 0
        else 
            q <= d; // Si reset no está activo, el registro almacena la entrada 'd' en el flanco positivo del reloj
    end
endmodule
