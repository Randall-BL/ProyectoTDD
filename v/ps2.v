module ps2(
    // Entradas
    input wire iSTART,   // Botón de inicio (no usado en teclado)
    input wire iRST_n,   // Reset (activo bajo)
    input wire iCLK_50,  // Reloj 50MHz
    
    // Bidireccionales (PS/2)
    inout wire PS2_CLK,  // Señal PS2_CLK
    inout wire PS2_DAT,  // Señal PS2_DAT
    
    // Salidas
    output wire oLEFBUT, // No usado (0)
    output wire oRIGBUT, // No usado (0)
    output wire oMIDBUT, // No usado (0)
    output wire [6:0] oX_MOV1, // Dígito bajo del carácter
    output wire [6:0] oX_MOV2, // Dígito alto (siempre 0)
    output wire [6:0] oY_MOV1, // No usado (0)
    output wire [6:0] oY_MOV2  // No usado (0)
);

//=======================================================
//  PARÁMETROS Y CONSTANTES
//=======================================================
// Scancodes para teclas relevantes (hex)
parameter SCANCODE_0 = 8'h45;
parameter SCANCODE_1 = 8'h16;
parameter SCANCODE_2 = 8'h1E;
parameter SCANCODE_3 = 8'h26;
parameter SCANCODE_4 = 8'h25;
parameter SCANCODE_5 = 8'h2E;
parameter SCANCODE_6 = 8'h36;
parameter SCANCODE_7 = 8'h3D;
parameter SCANCODE_8 = 8'h3E;
parameter SCANCODE_9 = 8'h46;
parameter SCANCODE_PLUS  = 8'h79;  // Tecla '+'
parameter SCANCODE_MINUS = 8'h7B;  // Tecla '-'
parameter SCANCODE_MUL   = 8'h7C;  // Tecla '*'
parameter SCANCODE_DIV   = 8'h4A;  // Tecla '/'
parameter SCANCODE_ENTER = 8'h5A;
parameter SCANCODE_BACKSPACE = 8'h66;

//=======================================================
//  REGISTROS Y CABLES
//=======================================================
reg [7:0] char_reg;  // Registro para el carácter actual
reg [8:0] clk_div;
reg [5:0] ct;
reg [7:0] cnt;
reg ps2_clk_in, ps2_clk_syn1, ps2_dat_in, ps2_dat_syn1;
reg [10:0] shift_reg;  // Registro de desplazamiento (11 bits)

wire clk;
wire ps2_dat_syn0, ps2_clk_syn0;

//=======================================================
//  DISPLAYS (7 segmentos)
//=======================================================
SEG7_LUT U1(.oSEG(oX_MOV1), .iDIG(char_reg[3:0])); // Muestra el carácter
SEG7_LUT U2(.oSEG(oX_MOV2), .iDIG(4'b0));         // Siempre 0
SEG7_LUT U3(.oSEG(oY_MOV1), .iDIG(4'b0));         // Siempre 0
SEG7_LUT U4(.oSEG(oY_MOV2), .iDIG(4'b0));         // Siempre 0

//=======================================================
//  ASIGNACIONES
//=======================================================
assign PS2_CLK = 1'bZ;  // Siempre en alta impedancia
assign PS2_DAT = 1'bZ;  // Siempre en alta impedancia
assign ps2_clk_syn0 = PS2_CLK;
assign ps2_dat_syn0 = PS2_DAT;
assign clk = clk_div[8];  // Reloj de 97.65625 KHz

// LEDs no usados
assign oLEFBUT = 1'b0;
assign oRIGBUT = 1'b0;
assign oMIDBUT = 1'b0;

//=======================================================
//  Sincronización de señales PS/2
//=======================================================
always @(posedge clk) begin
    ps2_clk_syn1 <= ps2_clk_syn0;
    ps2_clk_in   <= ps2_clk_syn1;
    ps2_dat_syn1 <= ps2_dat_syn0;
    ps2_dat_in   <= ps2_dat_syn1;
end

//=======================================================
//  Divisor de reloj (50MHz -> 97.65625KHz)
//=======================================================
always @(posedge iCLK_50) begin
    clk_div <= clk_div + 1;
end

//=======================================================
//  Contador de reposo (detecta estado inactivo)
//=======================================================
always @(posedge clk) begin
    if ({ps2_clk_in, ps2_dat_in} == 2'b11)
        cnt <= cnt + 1;
    else
        cnt <= 8'd0;
end

//=======================================================
//  Contador de bits recibidos
//=======================================================
always @(negedge ps2_clk_in, posedge cnt[7]) begin
    if (cnt[7])  // Reset cuando cnt llega a 128
        ct <= 6'b000000;
    else
        ct <= ct + 1;
end

//=======================================================
//  Registro de desplazamiento
//=======================================================
always @(negedge ps2_clk_in) begin
    shift_reg <= {ps2_dat_in, shift_reg[10:1]};
end

//=======================================================
//  Decodificador de scancode a carácter
//=======================================================
always @(posedge clk, negedge iRST_n) begin
    if (!iRST_n) begin
        char_reg <= 8'd0;  // Reset: muestra 0
    end
    else if (ct == 6'd11) begin  // Paquete completo (11 bits)
        case (shift_reg[8:1])  // Byte de datos (bits 1-8)
            SCANCODE_0: char_reg <= 4'h0;  // '0'
            SCANCODE_1: char_reg <= 4'h1;  // '1'
            SCANCODE_2: char_reg <= 4'h2;  // '2'
            SCANCODE_3: char_reg <= 4'h3;  // '3'
            SCANCODE_4: char_reg <= 4'h4;  // '4'
            SCANCODE_5: char_reg <= 4'h5;  // '5'
            SCANCODE_6: char_reg <= 4'h6;  // '6'
            SCANCODE_7: char_reg <= 4'h7;  // '7'
            SCANCODE_8: char_reg <= 4'h8;  // '8'
            SCANCODE_9: char_reg <= 4'h9;  // '9'
            SCANCODE_PLUS:  char_reg <= 4'hA;  // '+'
            SCANCODE_MINUS: char_reg <= 4'hB;  // '-'
            SCANCODE_MUL:   char_reg <= 4'hC;  // '*'
            SCANCODE_DIV:   char_reg <= 4'hD;  // '/'
            SCANCODE_ENTER: char_reg <= 4'hE;  // 'Enter' (mostrado como 'E')
            SCANCODE_BACKSPACE: char_reg <= 4'hF;  // 'Backspace' (mostrado como 'F')
            default: char_reg <= char_reg;  // Mantener valor anterior
        endcase
    end
end

endmodule


