//=======================================================
// video_sync_generator.v
//=======================================================
module video_sync_generator(
    input  wire        iCLK_50,
    input  wire        iRST_N,
    output wire        oPIXEL_CLK,
    output wire        oHSYNC,
    output wire        oVSYNC,
    output wire        oBLANK_N,
    output wire        oSYNC_N,
    output wire [9:0]  oX,
    output wire [9:0]  oY
);
    reg toggle;
    always @(posedge iCLK_50 or negedge iRST_N)
        if (!iRST_N) toggle <= 0;
        else toggle <= ~toggle;
    assign oPIXEL_CLK = toggle;

    reg [9:0] x, y;
    localparam HACT=640, HFP=16, HSZ=96, HBP=48;
    localparam VACT=480, VFP=10, VSZ=2,  VBP=33;
    localparam HTOT=HACT+HFP+HSZ+HBP;
    localparam VTOT=VACT+VFP+VSZ+VBP;

    always @(posedge oPIXEL_CLK or negedge iRST_N) begin
        if (!iRST_N) begin x<=0; y<=0; end
        else begin
            if (x<HTOT-1) x<=x+1; else begin x<=0; if (y<VTOT-1) y<=y+1; else y<=0; end
        end
    end
    assign oX = x; assign oY = y;
    assign oHSYNC  = ~((x>=HACT+HFP) && (x<HACT+HFP+HSZ));
    assign oVSYNC  = ~((y>=VACT+VFP) && (y<VACT+VFP+VSZ));
    assign oSYNC_N = oHSYNC & oVSYNC;
    assign oBLANK_N= (x<HACT) && (y<VACT);
endmodule