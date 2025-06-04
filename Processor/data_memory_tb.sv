
module data_memory_tb();
    // Señales de prueba
    logic        clk;
    logic        mem_write;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [31:0] read_data;

    // Instancia del modulo a probar
    data_memory dut(.*);

    // Generador de reloj
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // Estimulos
    initial begin
        // Inicializacion
        mem_write = 0;
        address = 0;
        write_data = 0;
        
        #10;
        
        // Test 1: Leer direccion 0 (flanco positivo)
        $display("\nTest 1: Lectura direccion 0");
        address = 0;
        @(posedge clk);
        #1;
        $display("Tiempo=%0t: Leido %h de direccion %0d", $time, read_data, address);

        // Test 2: Escribir nuevo valor (flanco negativo)
        $display("\nTest 2: Escritura direccion 1");
        address = 4;  // Direccion 1 (word-aligned)
        write_data = 32'hAABBCCDD;
        mem_write = 1;
        @(negedge clk);
        #1;
        $display("Tiempo=%0t: Escrito %h en direccion %0d", $time, write_data, address>>2);

        // Test 3: Leer el valor escrito
        $display("\nTest 3: Lectura del valor escrito");
        mem_write = 0;
        @(posedge clk);
        #1;
        $display("Tiempo=%0t: Leido %h de direccion %0d", $time, read_data, address>>2);

        // Test 4: Escribir y leer en direcciones diferentes
        $display("\nTest 4: Escritura y lectura en diferentes direcciones");
        address = 8;  // Direccion 2
        write_data = 32'h11223344;
        mem_write = 1;
        @(negedge clk);
        #1;
        $display("Tiempo=%0t: Escrito %h en direccion %0d", $time, write_data, address>>2);
        
        mem_write = 0;
        address = 0;
        @(posedge clk);
        #1;
        $display("Tiempo=%0t: Leido %h de direccion %0d", $time, read_data, address>>2);

        #10;
        $finish;
    end

    // Monitor de cambios
    initial begin
        $monitor("Tiempo=%0t clk=%b mem_write=%b address=%0d write_data=%h read_data=%h",
                 $time, clk, mem_write, address>>2, write_data, read_data);
    end

endmodule