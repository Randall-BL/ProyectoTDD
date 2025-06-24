
module videoText #(
    parameter CHAR_X_POS = 0,
    parameter CHAR_Y_POS = 0
)(
    input  wire        vgaclk,
    input  wire [9:0]  x,
    input  wire [9:0]  y,
    input  wire [3:0]  char_code,
    input  wire [7:0]  bg_r,
    input  wire [7:0]  bg_g,
    input  wire [7:0]  bg_b,
    output reg  [7:0]  r_out,
    output reg  [7:0]  g_out,
    output reg  [7:0]  b_out
);
    wire in_char = (x>=CHAR_X_POS && x<CHAR_X_POS+8 && y>=CHAR_Y_POS && y<CHAR_Y_POS+16);
    wire [3:0] fx = x - CHAR_X_POS;
    wire [3:0] fy = y - CHAR_Y_POS;

    reg [7:0] font_rom [0:15][0:15];
    initial begin
        integer i,j;
        for(i=0;i<16;i=i+1)
            for(j=0;j<16;j=j+1)
                font_rom[i][j] = 8'b00000000;
        // Patrón de '0'
        font_rom[4'h0][0]=8'b00111100;
        font_rom[4'h0][1]=8'b01000010;
        font_rom[4'h0][2]=8'b01000010;
        font_rom[4'h0][3]=8'b01000010;
        font_rom[4'h0][4]=8'b01000010;
        font_rom[4'h0][5]=8'b01000010;
        font_rom[4'h0][6]=8'b01000010;
        font_rom[4'h0][7]=8'b00111100;
        
        // Patrón de '1'
        font_rom[4'h1][0]=8'b00001000;
        font_rom[4'h1][1]=8'b00011000;
        font_rom[4'h1][2]=8'b00101000;
        font_rom[4'h1][3]=8'b00001000;
        font_rom[4'h1][4]=8'b00001000;
        font_rom[4'h1][5]=8'b00001000;
        font_rom[4'h1][6]=8'b00001000;
        font_rom[4'h1][7]=8'b00111110;
        
        // Patrón de '2'
        font_rom[4'h2][0]=8'b00111100;
        font_rom[4'h2][1]=8'b01000010;
        font_rom[4'h2][2]=8'b00000010;
        font_rom[4'h2][3]=8'b00001100;
        font_rom[4'h2][4]=8'b00110000;
        font_rom[4'h2][5]=8'b01000000;
        font_rom[4'h2][6]=8'b01000000;
        font_rom[4'h2][7]=8'b01111110;
        
        // Patrón de '3' (ya existente)
        font_rom[4'h3][0]=8'b00111100;
        font_rom[4'h3][1]=8'b01000010;
        font_rom[4'h3][2]=8'b00000110;
        font_rom[4'h3][3]=8'b00011100;
        font_rom[4'h3][4]=8'b00000110;
        font_rom[4'h3][5]=8'b01000010;
        font_rom[4'h3][6]=8'b00111100;
        
        // Patrón de '4'
        font_rom[4'h4][0]=8'b00000100;
        font_rom[4'h4][1]=8'b00001100;
        font_rom[4'h4][2]=8'b00010100;
        font_rom[4'h4][3]=8'b00100100;
        font_rom[4'h4][4]=8'b01000100;
        font_rom[4'h4][5]=8'b01111110;
        font_rom[4'h4][6]=8'b00000100;
        font_rom[4'h4][7]=8'b00000100;
        
        // Patrón de '5'
        font_rom[4'h5][0]=8'b01111110;
        font_rom[4'h5][1]=8'b01000000;
        font_rom[4'h5][2]=8'b01000000;
        font_rom[4'h5][3]=8'b01111100;
        font_rom[4'h5][4]=8'b00000010;
        font_rom[4'h5][5]=8'b00000010;
        font_rom[4'h5][6]=8'b01000010;
        font_rom[4'h5][7]=8'b00111100;
        
        // Patrón de '6'
        font_rom[4'h6][0]=8'b00111100;
        font_rom[4'h6][1]=8'b01000010;
        font_rom[4'h6][2]=8'b01000000;
        font_rom[4'h6][3]=8'b01111100;
        font_rom[4'h6][4]=8'b01000010;
        font_rom[4'h6][5]=8'b01000010;
        font_rom[4'h6][6]=8'b01000010;
        font_rom[4'h6][7]=8'b00111100;
        
        // Patrón de '7'
        font_rom[4'h7][0]=8'b01111110;
        font_rom[4'h7][1]=8'b00000010;
        font_rom[4'h7][2]=8'b00000100;
        font_rom[4'h7][3]=8'b00001000;
        font_rom[4'h7][4]=8'b00010000;
        font_rom[4'h7][5]=8'b00100000;
        font_rom[4'h7][6]=8'b01000000;
        font_rom[4'h7][7]=8'b01000000;
        
        // Patrón de '8'
        font_rom[4'h8][0]=8'b00111100;
        font_rom[4'h8][1]=8'b01000010;
        font_rom[4'h8][2]=8'b01000010;
        font_rom[4'h8][3]=8'b00111100;
        font_rom[4'h8][4]=8'b01000010;
        font_rom[4'h8][5]=8'b01000010;
        font_rom[4'h8][6]=8'b01000010;
        font_rom[4'h8][7]=8'b00111100;
        
        // Patrón de '9'
        font_rom[4'h9][0]=8'b00111100;
        font_rom[4'h9][1]=8'b01000010;
        font_rom[4'h9][2]=8'b01000010;
        font_rom[4'h9][3]=8'b01000010;
        font_rom[4'h9][4]=8'b00111110;
        font_rom[4'h9][5]=8'b00000010;
        font_rom[4'h9][6]=8'b01000010;
        font_rom[4'h9][7]=8'b00111100;
    end

    wire pixel = font_rom[char_code][fy][7-fx];
    always @(posedge vgaclk) begin
        if(in_char && pixel) begin r_out<=8'hFF; g_out<=8'hFF; b_out<=8'hFF; end
        else begin r_out<=bg_r; g_out<=bg_g; b_out<=bg_b; end
    end
endmodule