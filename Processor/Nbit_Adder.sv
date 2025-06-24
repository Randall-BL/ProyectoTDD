module Nbit_Adder #(parameter N = 32)(
    input  logic [N-1:0] a,         // Primer operando (32 bits)
    input  logic [N-1:0] b,         // Segundo operando (32 bits)
    output logic [N-1:0] result,    // Resultado de la suma (32 bits)
    output logic zr_flag,           // Flag de cero
    output logic cry_flag,          // Flag de acarreo
    output logic of_flag,           // Flag de overflow
    output logic neg_flag           // Flag de negativo
);
    
    // Vector de acarreos entre etapas
    wire [N-1:0] carries;
    
    // Generación de sumadores completos
    genvar i;
    generate 
        for(i = 0; i < N; i = i + 1) begin: generate_N_bit_Adder
            if(i == 0) 
                // Primer sumador (no tiene acarreo de entrada)
                full_adder f(
                    .a(a[0]),
                    .b(b[0]),
                    .cin(1'b0),
                    .sum(result[0]),
                    .cout(carries[0])
                );
            else
                // Sumadores subsiguientes
                full_adder f(
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carries[i-1]),
                    .sum(result[i]),
                    .cout(carries[i])
                );
        end
    endgenerate
    
    // Generación de flags
    assign zr_flag = (result == 0);                                   // Zero flag
    assign neg_flag = result[N-1];                                    // Negative flag
    assign cry_flag = carries[N-1];                                   // Carry flag
    assign of_flag = ((a[N-1] == b[N-1]) && (a[N-1] != result[N-1])); // Overflow flag

endmodule