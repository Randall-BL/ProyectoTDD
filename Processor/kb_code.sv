// Módulo de control de códigos de tecla
module kb_code #(
    parameter W_SIZE = 2  // 2^W_SIZE palabras en FIFO
)(
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] scan_data,
    input  logic       scan_done_tick,
    input  logic       rd_key_code,
    output logic [7:0] key_code,
    output logic       kb_buf_empty,
    output logic       kb_buf_full
);

    // Constante de código de ruptura
    localparam [7:0] BRK = 8'hF0;
    
    // Estados del FSM
    typedef enum logic {
        WAIT_BRK,
        GET_CODE
    } state_type;
    
    state_type state_reg, state_next;
    logic got_code_tick;
    
    // Proceso de registro de estado
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= WAIT_BRK;
        end else begin
            state_reg <= state_next;
        end
    end
    
    // Lógica de estado siguiente
    always_comb begin
        got_code_tick = 1'b0;
        state_next = state_reg;
        
        case (state_reg)
            WAIT_BRK: begin // Esperar F0 del código de ruptura
                if (scan_done_tick & (scan_data == BRK)) begin
                    state_next = GET_CODE;
                end
            end
            
            GET_CODE: begin // Obtener el siguiente código de escaneo
                if (scan_done_tick) begin
                    got_code_tick = 1'b1;
                    state_next = WAIT_BRK;
                end
            end
        endcase
    end
    
    // Instanciar FIFO
    fifo #(.B(8), .W(W_SIZE)) fifo_key_unit (
        .clk(clk),
        .reset(reset),
        .rd(rd_key_code),
        .wr(got_code_tick),
        .w_data(scan_data),
        .empty(kb_buf_empty),
        .full(kb_buf_full),
        .r_data(key_code)
    );

endmodule