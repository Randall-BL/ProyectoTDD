
//ALU PARAMETRIZABLE
// MUX
// 000 SUM
// 001 SUB
// 010 AND
// 011 OR
// 100 MULT
// 101 MOV

module alu 
#(parameter N = 32)
(
  input logic [N-1:0] A, B,             // Entrada de la ALU
  input logic [2:0] ALU_Sel,            // Selector de la ALU
  output logic [2*N-1:0] ALU_Result,    // Salida de la ALU 
  output [3:0] ALU_Flags
);

  // Flags intermedios
  logic add_CFlag, add_VFlag, add_ZFlag, add_NFlag;
  logic sub_CFlag, sub_VFlag, sub_ZFlag, sub_NFlag;
  logic mul_NFlag, mul_ZFlag;
  logic Neg, Z, C, V;

  // Resultados intermedios
  wire [N-1:0] add_result;
  wire [N-1:0] sub_result;
  wire [2*N-1:0] mul_result;

  
  Nbit_Sub #(.N(N)) sub_op(A, B, sub_result[N-1:0], sub_CFlag, sub_ZFlag, sub_VFlag, sub_NFlag);
  Nbit_Adder #(.N(N)) adder_op(A, B, add_result[N-1:0], add_ZFlag, add_CFlag, add_VFlag, add_NFlag);
  Nbit_Mult #(.N(N)) mult_op(A, B, mul_result[2*N-1:0], mul_ZFlag, mul_NFlag);
  
  always_comb begin
    // Inicializar flags
    Neg = 0;
	 Z = 0;
	 C = 0;
	 V = 0;
    ALU_Result = '0; // Inicializar ALU_Result por defecto

    // ALU OP
    case(ALU_Sel)
      3'b000: begin // OPERACION ADD
        ALU_Result = add_result;
        Neg = add_NFlag;
        Z = add_ZFlag;
        C = add_CFlag;
        V = add_VFlag;
      end

      3'b001: begin // OPERACION SUB
        ALU_Result = sub_result;
        Neg = sub_NFlag;
        Z = sub_ZFlag;
        C = sub_CFlag;
        V = sub_VFlag;
      end

      3'b010: begin // OPERACION AND
        ALU_Result = A & B;
        Neg = ALU_Result[N-1:0];
        Z = (ALU_Result == '0);
        C = 1'b0; // No aplica para AND
        V = 1'b0; // No aplica para AND
      end

      3'b011: begin // OPERACION OR
        ALU_Result = A | B;
        Neg = ALU_Result[N-1:0];
        Z = (ALU_Result == '0);
        C = 1'b0; // No aplica para OR
        V = 1'b0; // No aplica para OR
      end
		3'b100: begin // OPERACION MUL
		  ALU_Result = mul_result;
        Z = mul_ZFlag;
        C = 1'b0;
        Neg = mul_NFlag; 
        V= 1'b0; 
		end
		3'b101: begin //OPERACION MOV
			ALU_Result = B;
			Z = (ALU_Result == '0);
			C = 1'b0;
			Neg = ALU_Result[N-1];
			V = 1'b0;
		end
      default: begin 
        ALU_Result = '0; 
      end
    endcase
  end
  
  assign ALU_Flags = {Neg,Z,C,V}; // Empaquetado de las Flags
  
endmodule
