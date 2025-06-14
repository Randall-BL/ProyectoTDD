//=======================================================
//  Módulo display 7 segmentos (modificado para mostrar caracteres especiales)
//=======================================================
module SEG7_LUT(oSEG, iDIG);
input  [3:0] iDIG;
output reg [6:0] oSEG;

always @(iDIG) begin
    case (iDIG)
        4'h0: oSEG = 7'b1000000;  // '0'
        4'h1: oSEG = 7'b1111001;  // '1'
        4'h2: oSEG = 7'b0100100;  // '2'
        4'h3: oSEG = 7'b0110000;  // '3'
        4'h4: oSEG = 7'b0011001;  // '4'
        4'h5: oSEG = 7'b0010010;  // '5'
        4'h6: oSEG = 7'b0000010;  // '6'
        4'h7: oSEG = 7'b1111000;  // '7'
        4'h8: oSEG = 7'b0000000;  // '8'
        4'h9: oSEG = 7'b0010000;  // '9'
        4'hA: oSEG = 7'b0001000;  // '+' (A)
        4'hB: oSEG = 7'b1000001;  // '-' (B)
        4'hC: oSEG = 7'b1000110;  // '*' (C)
        4'hD: oSEG = 7'b0100001;  // '/' (D)
        4'hE: oSEG = 7'b0000110;  // 'E' (Enter)
        4'hF: oSEG = 7'b0001110;  // 'F' (Backspace)
        default: oSEG = 7'b1111111;  // Apagado
    endcase
end
endmodule