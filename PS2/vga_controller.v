module vga_controller(
    input  wire [7:0]  iDATA_R,
    input  wire [7:0]  iDATA_G,
    input  wire [7:0]  iDATA_B,
    input  wire        iPIXEL_CLK,
    input  wire        iHSYNC,
    input  wire        iVSYNC,
    input  wire        iBLANK_N,
    input  wire        iSYNC_N,
    output reg  [7:0]  oVGA_R,
    output reg  [7:0]  oVGA_G,
    output reg  [7:0]  oVGA_B,
    output reg         oVGA_HS,
    output reg         oVGA_VS,
    output reg         oVGA_BLANK_N,
    output reg         oVGA_SYNC_N,
    output reg         oVGA_CLK
);
    always @(posedge iPIXEL_CLK) begin
        oVGA_R       <= iDATA_R;
        oVGA_G       <= iDATA_G;
        oVGA_B       <= iDATA_B;
        oVGA_HS      <= iHSYNC;
        oVGA_VS      <= iVSYNC;
        oVGA_BLANK_N <= iBLANK_N;
        oVGA_SYNC_N  <= iSYNC_N;
        oVGA_CLK     <= iPIXEL_CLK;
    end
endmodule