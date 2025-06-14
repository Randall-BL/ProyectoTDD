module ps2_keyboard (
    input        clk,
    input        rst,
    inout        ps2_clk,
    inout        ps2_data,
    output [7:0] keycode,
    output       keycode_valid
);

    reg [10:0] shift_reg;
    reg [3:0]  bit_count;
    reg        ps2_clk_prev;
    reg [7:0]  last_key;
    reg        valid;
    reg        skip_next;

    wire ps2_clk_i;
    wire ps2_data_i;

    assign ps2_clk_i  = ps2_clk;
    assign ps2_data_i = ps2_data;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bit_count   <= 0;
            shift_reg   <= 0;
            ps2_clk_prev <= 1;
            last_key    <= 8'd0;
            valid       <= 0;
            skip_next   <= 0;
        end else begin
            ps2_clk_prev <= ps2_clk_i;

            if (ps2_clk_prev && ~ps2_clk_i) begin // flanco de bajada
                shift_reg <= {ps2_data_i, shift_reg[10:1]};
                bit_count <= bit_count + 1;

                if (bit_count == 10) begin
                    bit_count <= 0;
                    // shift_reg[8:1] contiene el byte (sin bit de start/paridad/stop)
                    if (shift_reg[8:1] == 8'hF0) begin
                        skip_next <= 1;
                        valid <= 0;
                    end else if (skip_next) begin
                        skip_next <= 0;
                        valid <= 0;
                    end else begin
                        last_key <= shift_reg[8:1];
                        valid <= 1;
                    end
                end else begin
                    valid <= 0;
                end
            end else begin
                valid <= 0;
            end
        end
    end

    assign keycode = last_key;
    assign keycode_valid = valid;

endmodule
