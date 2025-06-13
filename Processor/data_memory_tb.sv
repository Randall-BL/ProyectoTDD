`timescale 1ns/1ps

module data_memory_tb();
    // Señales de prueba
    logic clk;
    logic mem_write;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [31:0] read_data;

    // Instancia del módulo
    data_memory dut(
        .clk        (clk),
        .mem_write  (mem_write),
        .address    (address),
        .write_data (write_data),
        .read_data  (read_data)
    );

    // Generación del reloj
    always #5 clk = ~clk; // Clock period = 10ns

    // Estímulos y verificación
    initial begin
        // Inicialización
        clk = 0;
        mem_write = 0;
        address = 32'h0;
        write_data = 32'h0;
        #10; // Esperar a que la memoria se inicialice y el reloj inicie

        $display("\n=== Pruebas de Memoria de Datos ===");
        $display("-----------------------------------");
        
        // --- Prueba 1: Lectura de una dirección inicial (0x00000000) ---
        // Esperamos xxxxxxxx o 0 si el .dat rellena
        address = 32'h00000000; // Dirección de byte 0 -> índice RAM 0
        mem_write = 0;
        #10; // Esperar un ciclo de reloj completo para la lectura síncrona
        $display("Tiempo=%0d: Leido 0x%h de direccion 0x%h (RAM_Index: 0x%h)", $time, read_data, address, address[13:2]);
        
        // --- Prueba 2: Escritura en dirección de byte 0x00000004 (indice RAM 1) ---
        // Escribimos en la dirección de byte 0x00000004, que mapea a RAM[1]
        address = 32'h00000004; // Dirección de byte 0x00000004 -> índice RAM 1
        write_data = 32'hAABBCCDD;
        mem_write = 1;
        #10; // Un ciclo completo para la escritura
        $display("Tiempo=%0d: Escrito 0x%h en direccion 0x%h (RAM_Index: 0x%h)", $time, write_data, address, address[13:2]);
        
        // --- Prueba 3: Lectura del valor escrito en 0x00000004 (indice RAM 1) ---
        mem_write = 0;
        #10; // Un ciclo completo para la lectura
        $display("Tiempo=%0d: Leido 0x%h de direccion 0x%h (RAM_Index: 0x%h)", $time, read_data, address, address[13:2]);
        // ¡Debería ser 0xAABBCCDD!
        
        // --- Prueba 4: Escritura en dirección de byte 0x00001000 (indice RAM 0x400) ---
        // Esta es la dirección que usa tu procesador para Operando 1
        address = 32'h00001000; // Dirección de byte 0x1000 -> índice RAM 0x400
        write_data = 32'hFEEDFACE;
        mem_write = 1;
        #10; // Un ciclo completo para la escritura
        $display("Tiempo=%0d: Escrito 0x%h en direccion 0x%h (RAM_Index: 0x%h)", $time, write_data, address, address[13:2]);

        // --- Prueba 5: Lectura del valor escrito en 0x00001000 (indice RAM 0x400) ---
        mem_write = 0;
        #10; // Un ciclo completo para la lectura
        $display("Tiempo=%0d: Leido 0x%h de direccion 0x%h (RAM_Index: 0x%h)", $time, read_data, address, address[13:2]);
        // ¡Debería ser 0xFEEDFACE!
        
        // --- Prueba 6: Lectura del operando 1 inicial (de data_test_suma.dat) ---
        // Ahora leemos la dirección que debería haber cargado el 0x0000000A de data_test_suma.dat
        address = 32'h00001000; 
        mem_write = 0;
        #10; 
        $display("Tiempo=%0d: Leyendo Op1 cargado: 0x%h de direccion 0x%h (RAM_Index: 0x%h)", $time, read_data, address, address[13:2]);
        // ¡Debería ser 0x0000000A (si la inicialización funcionó)!

        $display("-----------------------------------");
        $display("=== Fin de las pruebas de Memoria de Datos ===\n");
        #10 $finish;
    end

endmodule