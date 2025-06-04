module videoGen(
    input logic [9:0] x, y,
    output logic [7:0] r, g, b
);

    // Memoria RGB de 200x200
    logic [23:0] image_data[0:39999];  // Memoria 200x200, 24 bits por pixel (8 - R, G, B)

    initial begin
        // Cargar datos de la imagen desde el archivo .mem hex
        $readmemh("image_data.mem", image_data);
    end

    // Definir las dimensiones de la imagen
	localparam IMG_WIDTH = 200;
	localparam IMG_HEIGHT = 200;

	// Verificar si las coordenadas actuales están dentro del área de la imagen
	wire in_image_area = (x < IMG_WIDTH) && (y < IMG_HEIGHT);

	// Calcular la dirección de memoria con las coordenadas sin escalado
	wire [15:0] address = (y * IMG_WIDTH) + x;

	// Asignación de colores basados en las coordenadas y datos de imagen
	assign {r, g, b} = in_image_area ? image_data[address] : 24'h000000;

endmodule