# save this as bin_to_hex.py
def bin_to_hex_dat(bin_file_path, hex_file_path, instruction_size_bytes=4):
    with open(bin_file_path, 'rb') as f_bin:
        binary_data = f_bin.read()

    with open(hex_file_path, 'w') as f_hex:
        for i in range(0, len(binary_data), instruction_size_bytes):
            # Leer 4 bytes (32 bits) en orden little-endian (típico para ARM binarios)
            # Ojo: Algunas toolchains ARM pueden generar big-endian por defecto
            # Si tu procesador ARM espera little-endian en la memoria, esto es correcto
            instruction_bytes = binary_data[i:i + instruction_size_bytes]
            if len(instruction_bytes) < instruction_size_bytes:
                # Rellenar con ceros si no es una instrucción completa al final
                instruction_bytes += b'\x00' * (instruction_size_bytes - len(instruction_bytes))

            # Convertir los 4 bytes a un entero de 32 bits y luego a hexadecimal
            # Esto asume little-endian, si es big-endian, usa 'big'
            instruction_int = int.from_bytes(instruction_bytes, byteorder='little')
            f_hex.write(f"{instruction_int:08X}\n") # Formato 8 dígitos hexadecimales

# Uso:
bin_to_hex_dat('calculator.bin', 'program.dat')
print("program.dat generado exitosamente.")