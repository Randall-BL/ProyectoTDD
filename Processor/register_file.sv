module register_file(
    input logic clk,
    input logic reset, // Input port for synchronous reset
    input logic we3,
    input logic [3:0] ra1,ra2,wa3,
    input logic [31:0] wd3,r15,
    output logic [31:0] rd1,rd2,
    // ******* NUEVOS PUERTOS DE SALIDA PARA MONITOREO *******
    output logic [31:0] r0_out,
    output logic [31:0] r1_out,
    output logic [31:0] r2_out,
    output logic [31:0] r3_out,
    output logic [31:0] r7_out
);
    // Tu array interno de registros
    logic [31:0] rf[14:0]; // Registros R0 a R14. R15 se maneja aparte.

    // Bloque principal para la actualización de registros y el reset
    // NOTA CLAVE: La lista de sensibilidad incluye 'posedge reset'
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin // Si el reset está activo (asumiendo reset activo en alto)
            for (int i = 0; i < 15; i = i + 1) begin
                rf[i] <= 32'h00000000; // Limpia todos los registros a 0
            end
        end else if(we3) begin // Si no hay reset y la escritura está habilitada
            // Asegúrate de que wa3 no sea 15 (4'b1111), ya que R15 es de solo lectura por software
            if (wa3 != 4'b1111) begin 
                rf[wa3] <= wd3; // Escribe el dato en el registro
            end
        end
    end

    // Lectura de puertos de forma combinacional
    // R15 (PC) se lee del puerto 'r15' (que viene de PCPlus8 del datapath)
    assign rd1 = (ra1 == 4'b1111) ? r15 : rf[ra1];
    assign rd2 = (ra2 == 4'b1111) ? r15 : rf[ra2];

    // Asignaciones para los puertos de salida de monitoreo
    assign r0_out = rf[0];
    assign r1_out = rf[1];
    assign r2_out = rf[2];
    assign r3_out = rf[3];
    assign r7_out = rf[7];

endmodule