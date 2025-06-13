module data_memory(
    input  logic         clk,
    input  logic         mem_write,     // Habilita la escritura en memoria
    input  logic [31:0]  address,       // Dirección de 32 bits desde el procesador (ej: ALUResult)
    input  logic [31:0]  write_data,    // Datos a escribir en memoria
    output logic [31:0]  read_data      // Datos leídos de memoria
);
    // RAM declarada como 1024 palabras de 32 bits (4KB de datos)
    // El rango de índices es [0:1023]
    logic [31:0] RAM [0:1023]; 
    logic [31:0] read_reg; // Registro para la salida de lectura síncrona
    
    // ram_index es el índice de 10 bits para la RAM, derivado de la dirección de 32 bits.
    // address[11:2] asume direccionamiento por byte para palabras de 32 bits (4 bytes/palabra).
    // Por ejemplo, 0x00000000 -> índice 0, 0x00000004 -> índice 1, etc.
    logic [9:0] ram_index; 
    assign ram_index = address[11:2]; 

    // Bloque de inicialización: se ejecuta una vez al inicio de la simulación.
    // ESTE BLOQUE 'initial' TAMBIÉN PUEDE CAUSAR ADVERTENCIAS O ERRORES DE SÍNTESIS
    // dependiendo de la herramienta y el contexto. Para hardware real, la RAM
    // generalmente se inicializa con un "reset" o se carga desde una ROM externa.
    initial begin
        // Carga los valores iniciales de la memoria de datos desde un archivo hexadecimal.
        // ¡IMPORTANTE!: Asegúrate de que la ruta del archivo sea ABSOLUTAMENTE CORRECTA.
        $readmemh("C:/Users/YITAN/OneDrive/Escritorio/Nueva carpeta (2)/data_test_suma.dat", RAM); 
        
        $display("\n--- Depuración de Carga de Memoria de Datos (RAM) ---");
        $display("Memoria de datos cargada (RAM[0:1023]):");
        // Muestra las primeras 10 posiciones de la RAM para verificación.
        for (int i = 0; i < 10; i++) begin
            $display("  RAM[0x%03h] (Word Index %0d) = %h", i, i, RAM[i]);
        end
        $display("  Confirmando datos clave para la calculadora (basado en 'data_test_suma.dat'):");
        $display("    RAM[0x000] (Operando 1, Word Index 0) = %h", RAM[10'h000]);
        $display("    RAM[0x001] (Operando 2, Word Index 1) = %h", RAM[10'h001]);
        $display("    RAM[0x002] (Operador, Word Index 2) = %h", RAM[10'h002]);
        $display("    RAM[0x003] (Espacio para Resultado, Word Index 3) = %h", RAM[10'h003]);
        $display("--- Fin Depuración de Carga de Memoria de Datos ---");
    end

    // Lógica de lectura de la RAM (síncrona, en flanco positivo del reloj)
    always_ff @(posedge clk) begin
        // Se asume que 'ram_index' siempre estará definido y dentro de los límites
        // durante la operación normal del hardware.
        if (ram_index < 1024) begin 
            read_reg <= RAM[ram_index]; // Lee el dato si la dirección es válida
        end else begin
            // En hardware, esta rama 'else' podría no ser alcanzable si las direcciones
            // se controlan correctamente, o el comportamiento es indefinido/dependiente del hardware.
            read_reg <= 32'hdeadbeef; // Valor para indicar un posible acceso fuera de rango (solo simulación)
            $display("Time=%0t ns | ERROR: Intento de LECTURA FUERA DE LÍMITES (address=%08h, ram_index=%04h)",
                     $time, address, ram_index);
        end
    end
    
    // Lógica de escritura en la RAM (síncrona, en flanco positivo del reloj)
    always_ff @(posedge clk) begin
        if (mem_write) begin // Solo si la señal de escritura está activa
            // Se asume que 'ram_index' siempre estará definido y dentro de los límites.
            if (ram_index < 1024) begin
                RAM[ram_index] <= write_data; // Escribe el dato si la dirección es válida
                $display("Time=%0t ns | ESCRIBIENDO en RAM[0x%03h] = %08h (Dirección en bus: %08h)",
                         $time, ram_index, write_data, address); 
            end else begin
                // En hardware, esta rama 'else' podría no ser alcanzable o el comportamiento es indefinido.
                $display("Time=%0t ns | ERROR: Intento de ESCRITURA FUERA DE LÍMITES (address=%08h, ram_index=%04h)",
                         $time, address, ram_index);
            end
        end
    end

    // Asignación continua de la salida de lectura
    assign read_data = read_reg;

endmodule