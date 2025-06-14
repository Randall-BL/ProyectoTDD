module top (
    input  wire iSTART,     // Botón para iniciar comunicación
    input  wire iRST_n,     // Reset activo bajo
    input  wire iCLK_50,    // Reloj principal de 50 MHz
    inout  wire PS2_CLK,    // Señal de reloj PS/2
    inout  wire PS2_DAT,    // Señal de datos PS/2
    output wire oLEFBUT,    // LED o señal para botón izquierdo
    output wire oRIGBUT,    // LED o señal para botón derecho
    output wire oMIDBUT,    // LED o señal para botón del medio
    output wire [6:0] oX_MOV1, // Display 7 segmentos X bajo
    output wire [6:0] oX_MOV2, // Display 7 segmentos X alto
    output wire [6:0] oY_MOV1, // Display 7 segmentos Y bajo
    output wire [6:0] oY_MOV2  // Display 7 segmentos Y alto
);

    ps2 ps2_inst (
        .iSTART(iSTART),
        .iRST_n(iRST_n),
        .iCLK_50(iCLK_50),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .oLEFBUT(oLEFBUT),
        .oRIGBUT(oRIGBUT),
        .oMIDBUT(oMIDBUT),
        .oX_MOV1(oX_MOV1),
        .oX_MOV2(oX_MOV2),
        .oY_MOV1(oY_MOV1),
        .oY_MOV2(oY_MOV2)
    );

endmodule
