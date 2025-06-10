// Módulo FIFO
module fifo #(
    parameter B = 8,  // número de bits en una palabra
    parameter W = 2   // número de bits de dirección
)(
    input  logic             clk,
    input  logic             reset,
    input  logic             rd,
    input  logic             wr,
    input  logic [B-1:0]     w_data,
    output logic             empty,
    output logic             full,
    output logic [B-1:0]     r_data
);

    // Declaración de señales
    logic [B-1:0] array_reg [2**W-1:0];
    logic [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
    logic [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
    logic         full_reg, empty_reg, full_next, empty_next;
    logic         wr_op;
    
    // Proceso de registro
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
        end
    end
    
    // Proceso de escritura en el array
    always_ff @(posedge clk) begin
        if (wr_op)
            array_reg[w_ptr_reg] <= w_data;
    end
    
    // Lógica de escritura habilitada
    assign wr_op = wr & ~full_reg;
    
    // Lógica de estado siguiente para punteros
    assign w_ptr_succ = w_ptr_reg + 1;
    assign r_ptr_succ = r_ptr_reg + 1;
    
    always_comb begin
        // Valores por defecto
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next = full_reg;
        empty_next = empty_reg;
        
        case ({wr, rd})
            2'b01: begin // lectura
                if (~empty_reg) begin
                    r_ptr_next = r_ptr_succ;
                    full_next = 1'b0;
                    if (r_ptr_succ == w_ptr_reg)
                        empty_next = 1'b1;
                end
            end
            
            2'b10: begin // escritura
                if (~full_reg) begin
                    w_ptr_next = w_ptr_succ;
                    empty_next = 1'b0;
                    if (w_ptr_succ == r_ptr_reg)
                        full_next = 1'b1;
                end
            end
            
            2'b11: begin // escritura y lectura
                w_ptr_next = w_ptr_succ;
                r_ptr_next = r_ptr_succ;
            end
            
            default: begin // sin operación
                // mantener valores actuales
            end
        endcase
    end
    
    // Salidas
    assign r_data = array_reg[r_ptr_reg];
    assign full = full_reg;
    assign empty = empty_reg;

endmodule