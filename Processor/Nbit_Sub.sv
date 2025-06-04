module Nbit_Sub #(parameter N = 32)(
    input  logic [N-1:0] a,         // Minuendo
    input  logic [N-1:0] b,         // Sustraendo
    output logic [N-1:0] result,    // Resultado
    output logic cry_flag,          // Carry flag (NOT borrow)
    output logic zr_flag,           // Zero flag
    output logic of_flag,           // Overflow flag
    output logic neg_flag           // Negative flag
);
    // Vector de préstamos entre etapas
    wire [N-1:0] carries;
    
    // Generación de restadores completos (mantener igual)
    genvar i;
    generate 
        for(i = 0; i < N; i = i + 1) begin: generate_N_bit_Sub
            if(i == 0) 
                full_subtractor f(
                    .a(a[0]),
                    .b(b[0]),
                    .c_in(1'b0),
                    .result(result[0]),
                    .c_out(carries[0])
                );
            else
                full_subtractor f(
                    .a(a[i]),
                    .b(b[i]),
                    .c_in(carries[i-1]),
                    .result(result[i]),
                    .c_out(carries[i])
                );
        end
    endgenerate

    // Generación de flags (corregida)
    assign zr_flag = (result == 0);                                   // Zero flag
    assign neg_flag = result[N-1];                                    // Negative flag
    assign cry_flag = (a >= b);                                       // Carry flag (NOT borrow)
    assign of_flag = (~a[N-1] & b[N-1] & result[N-1]) |              // Overflow flag
                    (a[N-1] & ~b[N-1] & ~result[N-1]);               // Corregida la lógica
endmodule