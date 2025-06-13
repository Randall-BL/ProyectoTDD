import os

def generate_data_test_suma_dat(file_path):
    """
    Genera el archivo data_test_suma.dat para inicializar la memoria de datos en Verilog.
    
    El archivo contendrá 1024 palabras (4KB).
    Los datos iniciales se colocan en las direcciones de palabra correspondientes
    a las direcciones de byte del programa ARM:
    - 0x0000 (byte) -> 0x000 (word index)
    - 0x0004 (byte) -> 0x001 (word index)
    - 0x0008 (byte) -> 0x002 (word index)
    - 0x000C (byte) -> 0x003 (word index)
    """

    memory_size_words = 1024  # Total de palabras en la RAM (0 a 1023)
    memory_content = [0x00000000] * memory_size_words # Inicializar toda la memoria a 0

    # Definir los valores iniciales y sus direcciones de palabra
    # Estas son las direcciones de palabra (índices en el array RAM de Verilog)
    # que corresponden a las direcciones de byte 0x0000, 0x0004, 0x0008, 0x000C en el ARM
    OP1_ADDR_WORD    = 0x000 # Corresponde a 0x0000 byte address
    OP2_ADDR_WORD    = 0x001 # Corresponde a 0x0004 byte address
    OPERATOR_ADDR_WORD = 0x002 # Corresponde a 0x0008 byte address
    RESULT_ADDR_WORD = 0x003 # Corresponde a 0x000C byte address

    # Valores que tu ARM program leerá inicialmente
    memory_content[OP1_ADDR_WORD]    = 0x0000000A # Operando 1 = 10
    memory_content[OP2_ADDR_WORD]    = 0x00000005 # Operando 2 = 5
    memory_content[OPERATOR_ADDR_WORD] = 0x00000001 # Operador = 1 (Suma)
    memory_content[RESULT_ADDR_WORD] = 0x00000000 # Inicializar Resultado a 0

    # Asegurarse de que el directorio exista
    output_dir = os.path.dirname(file_path)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Directorio creado: {output_dir}")

    # Escribir el contenido de la memoria al archivo .dat
    with open(file_path, 'w') as f:
        for word in memory_content:
            f.write(f"{word:08X}\n") # Formato de 8 dígitos hexadecimales por línea

    print(f"Archivo '{file_path}' generado exitosamente.")
    print(f"  Operando 1 (10) en dirección de palabra 0x{OP1_ADDR_WORD:X} (byte 0x0000)")
    print(f"  Operando 2 (5) en dirección de palabra 0x{OP2_ADDR_WORD:X} (byte 0x0004)")
    print(f"  Operador (1=Suma) en dirección de palabra 0x{OPERATOR_ADDR_WORD:X} (byte 0x0008)")
    print(f"  Espacio para Resultado (0) en dirección de palabra 0x{RESULT_ADDR_WORD:X} (byte 0x000C)")
    print(f"  El resto de la memoria ({memory_size_words - 4} palabras) se inicializa a 0.")

if __name__ == "__main__":
    # Define la ruta completa donde quieres que se guarde el archivo.
    # Asegúrate de que esta ruta coincida exactamente con la que tienes en tu módulo data_memory.
    data_file_path = "C:/Users/YITAN/OneDrive/Escritorio/Nueva carpeta (2)/data_test_suma.dat"
    generate_data_test_suma_dat(data_file_path)