// Módulo receptor PS2
module ps2_rx (
    input  logic       clk,
    input  logic       reset,
    input  logic       ps2_data,
    input  logic       ps2_clk,
    input  logic       rx_en,
    output logic       rx_done_tick,
    output logic [7:0] dout
);

    // Estados del receptor
    typedef enum logic [1:0] {
        IDLE,
        DPS,
        LOAD
    } state_type;
    
    state_type state_reg, state_next;
    
    // Registros de filtrado
    logic [7:0] filter_reg, filter_next;
    logic       f_ps2c_reg, f_ps2c_next;
    logic       fall_edge;
    
    // Contador y buffer de bits
    logic [3:0] n_reg, n_next;
    logic [10:0] b_reg, b_next;
    
    // Proceso de registro
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            filter_reg <= 8'b0;
            f_ps2c_reg <= 1'b0;
            state_reg <= IDLE;
            n_reg <= 4'b0;
            b_reg <= 11'b0;
        end else begin
            filter_reg <= filter_next;
            f_ps2c_reg <= f_ps2c_next;
            state_reg <= state_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end
    
    // Lógica de filtrado y detección de flanco descendente
    assign filter_next = {ps2_clk, filter_reg[7:1]};
    
    always_comb begin
        if (filter_reg == 8'b11111111)
            f_ps2c_next = 1'b1;
        else if (filter_reg == 8'b00000000)
            f_ps2c_next = 1'b0;
        else
            f_ps2c_next = f_ps2c_reg;
    end
    
    assign fall_edge = f_ps2c_reg & (~f_ps2c_next);
    
    // Lógica de estado siguiente
    always_comb begin
        rx_done_tick = 1'b0;
        state_next = state_reg;
        n_next = n_reg;
        b_next = b_reg;
        
        case (state_reg)
            IDLE: begin
                if (fall_edge & rx_en) begin
                    // Desplazar en el bit de inicio
                    b_next = {ps2_data, b_reg[10:1]};
                    n_next = 4'd9;
                    state_next = DPS;
                end
            end
            
            DPS: begin // 8 datos + 1 paridad + 1 parada
                if (fall_edge) begin
                    b_next = {ps2_data, b_reg[10:1]};
                    if (n_reg == 0) begin
                        state_next = LOAD;
                    end else begin
                        n_next = n_reg - 1;
                    end
                end
            end
            
            LOAD: begin
                // 1 ciclo extra para completar el último desplazamiento
                state_next = IDLE;
                rx_done_tick = 1'b1;
            end
        endcase
    end
    
    // Salida de datos (bits 8:1 contienen los datos)
    assign dout = b_reg[8:1];

endmodule