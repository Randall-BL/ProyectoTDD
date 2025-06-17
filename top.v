module top(
    input  wire        CLOCK_50,      // 50 MHz
    input  wire        KEY0,          // Reset (activo alto)
    inout  wire        PS2_CLK,       // PS/2 reloj
    inout  wire        PS2_DAT,       // PS/2 datos
    output wire [6:0]  HEX0,          // Display 7 segmentos
    output wire [7:0]  VGA_R, VGA_G, VGA_B,
    output wire        VGA_HS, VGA_VS,
    output wire        VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
);

    // Reset activo bajo
    wire reset_n = KEY0;

    // VGA señales internas
    wire        vga_clk;
    wire        hsync, vsync, blank_n, sync_n;
    wire [9:0]  x, y;
    wire [7:0]  txt_r, txt_g, txt_b;

    // Código de carácter y validez
    wire [3:0] char_code;
    wire char_valid;

    //---------------------------------------------------
    // 1) Generador de sincronía VGA
    //---------------------------------------------------
    video_sync_generator syncgen (
        .iCLK_50    (CLOCK_50),
        .iRST_N     (reset_n),
        .oPIXEL_CLK (vga_clk),
        .oHSYNC     (hsync),
        .oVSYNC     (vsync),
        .oBLANK_N   (blank_n),
        .oSYNC_N    (sync_n),
        .oX         (x),
        .oY         (y)
    );
    assign VGA_CLK = vga_clk;

    //---------------------------------------------------
    // 2) Receptor PS/2 con validez
    //---------------------------------------------------
    ps2 u_ps2 (
        .iRST_n   (reset_n),
        .iCLK_50  (CLOCK_50),
        .PS2_CLK  (PS2_CLK),
        .PS2_DAT  (PS2_DAT),
        .char_code(char_code),
        .char_valid(char_valid)
    );

    //---------------------------------------------------
    // 3) Lógica de almacenamiento en memoria RAM
    //---------------------------------------------------
    wire        we;
    reg  [9:0]  waddr;
    reg  [31:0] wdata;
    reg  [1:0]  state;
    reg  [31:0] op1_reg, op2_reg;
    reg  [31:0] operator_reg;

    // Estados de la FSM
    localparam IDLE       = 2'b00;
    localparam OP1        = 2'b01;
    localparam OP2        = 2'b10;
    localparam WRITE_MEM  = 2'b11;

    // Direcciones de memoria (índices de palabra)
    localparam OP1_ADDR     = 10'd0;  // 0x0000
    localparam OP2_ADDR     = 10'd1;  // 0x0004
    localparam OPERATOR_ADDR= 10'd2;  // 0x0008
    localparam RESULT_ADDR  = 10'd3;  // 0x000C

    // Instancia de memoria RAM
    ram u_ram (
        .clk      (CLOCK_50),
        .we       (we),
        .addr     (waddr),
        .data_in  (wdata),
        .data_out ()  // No se usa
    );
    assign we = (state == WRITE_MEM);  // Habilitar escritura solo en WRITE_MEM

    // Máquina de estados y acumuladores
    always @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            op1_reg <= 0;
            op2_reg <= 0;
            operator_reg <= 0;
            waddr <= 0;
            wdata <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (char_valid && char_code <= 9) begin
                        op1_reg <= char_code;  // Primer dígito de OP1
                        state <= OP1;
                    end
                end

                OP1: begin
                    if (char_valid) begin
                        if (char_code <= 9) begin
                            op1_reg <= op1_reg * 10 + char_code;  // Acumula OP1
                        end else if (char_code >= 4'hA && char_code <= 4'hD) begin
                            operator_reg <= char_code;  // Guarda operador
                            state <= OP2;               // Cambia a OP2
                        end
                    end
                end

                OP2: begin
                    if (char_valid) begin
                        if (char_code <= 9) begin
                            op2_reg <= op2_reg * 10 + char_code;  // Acumula OP2
                        end else if (char_code == 4'hE) begin     // ENTER
                            state <= WRITE_MEM;  // Inicia escritura en memoria
                        end
                    end
                end

                WRITE_MEM: begin
                    // Secuencia de escritura en 3 ciclos
                    case (waddr)
                        OP1_ADDR: begin
                            waddr <= OP2_ADDR;
                            wdata <= op2_reg;
                        end
                        OP2_ADDR: begin
                            waddr <= OPERATOR_ADDR;
                            wdata <= operator_reg;
                        end
                        OPERATOR_ADDR: begin
                            waddr <= RESULT_ADDR;
                            wdata <= 0;  // Inicializa resultado
                            state <= IDLE;  // Vuelve a IDLE
                        end
                    endcase
                end
            endcase
        end
    end

    //---------------------------------------------------
    // 4) Overlay de texto (muestra último dígito)
    //---------------------------------------------------
    videoText #(
        .CHAR_X_POS(100),
        .CHAR_Y_POS(100)
    ) u_text (
        .vgaclk     (vga_clk),
        .x          (x),
        .y          (y),
        .char_code  (char_code),
        .bg_r       (8'd0),
        .bg_g       (8'd0),
        .bg_b       (8'd0),
        .r_out      (txt_r),
        .g_out      (txt_g),
        .b_out      (txt_b)
    );

    //---------------------------------------------------
    // 5) Display 7 segmentos (muestra último dígito)
    //---------------------------------------------------
    SEG7_LUT u_seg7 (
        .iDIG(char_code),
        .oSEG(HEX0)
    );

    //---------------------------------------------------
    // 6) Controlador VGA
    //---------------------------------------------------
    vga_controller u_vga (
        .iDATA_R    (txt_r),
        .iDATA_G    (txt_g),
        .iDATA_B    (txt_b),
        .iPIXEL_CLK (vga_clk),
        .iHSYNC     (hsync),
        .iVSYNC     (vsync),
        .iBLANK_N   (blank_n),
        .iSYNC_N    (sync_n),
        .oVGA_R     (VGA_R),
        .oVGA_G     (VGA_G),
        .oVGA_B     (VGA_B),
        .oVGA_HS    (VGA_HS),
        .oVGA_VS    (VGA_VS),
        .oVGA_BLANK_N (VGA_BLANK_N),
        .oVGA_SYNC_N  (VGA_SYNC_N)
    );

endmodule