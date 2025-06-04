module full_adder(
    input  logic a,      // Primer operando
    input  logic b,      // Segundo operando
    input  logic cin,    // Acarreo de entrada
    output logic sum,    // Resultado de la suma
    output logic cout    // Acarreo de salida
);

    // Método 1: Usando asignaciones directas (más eficiente)
    assign sum = a ^ b ^ cin;                    // Suma
    assign cout = (a & b) | (cin & (a ^ b));     // Acarreo de salida

endmodule