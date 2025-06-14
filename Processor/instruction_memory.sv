module instruction_memory(
    input  logic [31:0] A,
    output logic [31:0] RD
);
    // Asegúrate de que el tamaño sea de 1024 palabras (0 a 1023)
    logic [31:0] ROM [0:1023]; 

    // El índice debe ser de 10 bits, usando address[11:2]
    logic [9:0] rom_index; 
    assign rom_index = A[11:2]; 

    initial begin
        // Asegúrate de que esta ruta sea ABSOLUTAMENTE CORRECTA
        $readmemh("E:/TEC/Digitales/ProyectoTDD/program.dat", ROM);

        // --- AÑADE ESTOS DISPLAYS DE DEPURACIÓN AQUÍ ---
        $display("--- Depuración de Carga de IMEM ---");
        $display("ROM[0x000] (esperado LDR R7) = %h", ROM[0]);
        $display("ROM[0x001] (esperado MOV R0) = %h", ROM[1]);
        $display("ROM[0x002] (esperado MOV R1) = %h", ROM[2]);
        $display("--- Fin Depuración IMEM ---");
        // --- FIN DE LOS DISPLAYS DE DEPURACIÓN ---
    end

    assign RD = ROM[rom_index];

endmodule