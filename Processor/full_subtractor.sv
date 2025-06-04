module full_subtractor(
    input  logic a,         // Minuendo
    input  logic b,         // Sustraendo
    input  logic c_in,      // Préstamo de entrada (borrow in)
    output logic result,    // Diferencia
    output logic c_out      // Préstamo de salida (borrow out)
);

    // Método 1: Usando asignaciones directas
    assign result = a ^ b ^ c_in;                    // Diferencia
    assign c_out = (~a & b) | (~(a ^ b) & c_in);    // Préstamo de salida

endmodule