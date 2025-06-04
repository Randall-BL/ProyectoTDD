module shifter (
    input logic [4:0] shift_amount,
	 input logic [1:0] shift_type,
	 input logic mul,
    input logic [31:0] rd2,        // Operando a desplazar
    output logic [31:0] data       // Resultado del desplazamiento
);


    // Lógica combinacional para el shifter
    always_comb begin
		if(mul) begin
			data = rd2;
		end else begin
			case (shift_type)
				2'b00: data = rd2 << shift_amount;        // SLL: Desplazamiento lógico a la izquierda
				2'b01: data = rd2 >> shift_amount;        // SRL: Desplazamiento lógico a la derecha
				2'b10: data = rd2 >>> shift_amount; 		// Arithmetic shift right (ASR)
				default: data = rd2;                     // Sin desplazamiento o tipo no definido
			endcase
		end
    end

endmodule
