module mux2 #(
    parameter WIDTH = 32
)(
    input  logic [WIDTH-1:0] d0,     // Primera entrada
    input  logic [WIDTH-1:0] d1,     // Segunda entrada
    input  logic             s,      // Señal de selección
    output logic [WIDTH-1:0] y       // Salida
);
    // Si s = 0, selecciona d0
    // Si s = 1, selecciona d1
    assign y = s ? d1 : d0;

endmodule