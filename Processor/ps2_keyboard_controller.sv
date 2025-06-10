module ps2_keyboard_controller (
    input  logic       clk,
    input  logic       reset,
    input  logic       ps2_data,
    input  logic       ps2_clk,
    input  logic       rd_key_code,
    output logic [7:0] key_code,
    output logic       kb_buf_empty,
    output logic       kb_buf_full
);


	// Senales internas
	logic [7:0] scan_data;
	logic scan_done_tick;
	logic rx_en;


// Instanciar receptor PS2
	ps2_rx ps2_reciever(
		.clk(clk),
		.reset(reset),
		.ps2_data(ps2_data),
		.ps2_clk(ps2_clk),
		.rx_en(rx_en),
		.rx_done_tick(scan_done_tick),
		.dout(scan_data)
	);

	// Instanciar el controlador de códigos de tecla
		 kb_code keyboard_code (
			  .clk(clk),
			  .reset(reset),
			  .scan_data(scan_data),
			  .scan_done_tick(scan_done_tick),
			  .rd_key_code(rd_key_code),
			  .key_code(key_code),
			  .kb_buf_empty(kb_buf_empty),
			  .kb_buf_full(kb_buf_full)
		 );
		 
		 // Habilitar siempre la recepción
		 assign rx_en = 1'b1;

endmodule

