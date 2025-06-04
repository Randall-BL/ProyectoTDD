 module decoder(input logic [1:0] Op,
	input logic [5:0] Funct,
	input logic [3:0] Rd, 
	input logic [3:0] Mul, movhi,
	output logic [1:0] FlagW,
	output logic PCS,RegW,MemW,NoWrite,
	output logic MemtoReg,ALUSrc,
	output logic [1:0] ImmSrc,RegSrc,
	output logic [2:0]ALUControl);
	
 logic [9:0] controls;
 logic Branch,ALUOp;
 
 //Main Decoder
 always_comb begin
	 case(Op)   // Data-processing immediate
		 2'b00: begin if(Funct[5] & Funct[4:1] == 4'b1010) begin 	// CMP Immediate
					controls= 10'b0000100001;
				end else if(!Funct[5] & Funct[4:1] == 4'b1010) begin 	// CMP Register
					controls = 10'b0000000001; 
				end else if(Funct[5] & Funct[4:1] == 4'b1101) begin	//MOV											
					controls = 10'b0000101001;
				end else if(!Funct[5] & Funct[4:1] == 4'b1101 & movhi == 4'b1000) begin	//MOVHI										
					controls = 10'b0000001001;
				end else if (Funct[5] & Funct[4:1] == 4'b1000) begin  // MOVW 
					controls = 10'b0011101001;  
				end else if (!Funct[5] & Funct[4:1] == 4'b0000 & Mul == 4'b1001) begin  // MUL 
					controls = 10'b0000001001;  
				end  else if (Funct[5] & Funct[4:1] == 4'b0000) begin  // AND 
					controls = 10'b0000101001;
				end else begin 											
					controls = 10'b0000001001; // Data-processing register 
				end
		  end
		 //LDR
		 2'b01: begin if(Funct[0]) begin controls=10'b0001111000; end
		 //STR
			else begin controls=10'b1001110100; end
			end
		 //B
		 2'b10: begin controls=10'b0110100010;
		 end
		 //Unimplemented
		 default: begin controls=10'bx;
		 end
	 endcase
 end
	 
assign{RegSrc,ImmSrc,ALUSrc,MemtoReg,
	 RegW,MemW,Branch,ALUOp}=controls;
	 
 //ALUDecoder
 always_comb begin
	 if(ALUOp)begin //which DP Instr?
	 case(Funct[4:1])
		 4'b0100: begin ALUControl=3'b000; NoWrite = 1'b0; end//ADD
		 4'b0010: begin ALUControl=3'b001; NoWrite = 1'b0; end //SUB
		 4'b0000: begin NoWrite = 1'b0; if(Mul == 4'b1001) begin ALUControl=3'b100; end//MUL
					 else begin ALUControl=3'b010; end //AND
					 end
		 4'b1100: begin ALUControl=3'b011; NoWrite = 1'b0; end //ORR
		 4'b1010: begin ALUControl=3'b001; NoWrite = 1'b1; end //CMP
		 4'b1101: begin NoWrite = 1'b0; if(Funct[5] & movhi == 4'b1110)begin ALUControl = 3'b101; end //MOV
					else if(!Funct[5] & movhi == 4'b1000) begin
									ALUControl = 3'b110; //MOVHI
					end else begin ALUControl = 3'b101; end //Shifter
					end
		 4'b1000: begin NoWrite = 1'b0;  ALUControl = 3'b101; end //MOVW
		 default: begin ALUControl=3'bx;
							 NoWrite = 1'b0;//unimplemented
					 end
	 endcase
		 //update flags if S bit is set(C & V only for arith)
		 FlagW[1] = Funct[0];
		 FlagW[0] = Funct[0] & (ALUControl == 3'b000 | ALUControl == 3'b001);
	 end else begin
		 ALUControl = 3'b000; //add for non-DP instructions
		 FlagW = 2'b00; //don't update Flags
		 NoWrite = 1'b0;
	end
 end
	
 //PCLogic
 assign PCS =((Rd==4'b1111) & RegW) | Branch;
 endmodule 