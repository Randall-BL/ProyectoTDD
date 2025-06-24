module Nbit_Mult #(
    parameter N = 2
)(
    input logic [N-1:0] a,        // Primer operando de N bits
    input logic [N-1:0] b,        // Segundo operando de N bits
    output logic [2*N-1:0] product, // Resultado de la multiplicación de 2*N bits
    output logic zero_flag,       // Flag de cero
    output logic negative_flag     // Flag negativo
);

    logic [2*N-1:0] temp_product; // Producto temporal

    // Inicializar el producto temporal en cero
    always_ff @(a, b) begin
        temp_product = 0;

        for (int i = 0; i < N; i++) begin
            if (b[i]) begin
                temp_product = temp_product + (a << i); // Desplazamiento y suma
            end
        end
    end

    assign product = temp_product;

    // Flags
    assign zero_flag = (product == 0); // Flag de cero
    assign negative_flag = product[2*N-1]; // El bit más significativo indica el signo

endmodule 