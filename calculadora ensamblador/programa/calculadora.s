.global _start
.text

_start:
    LDR R7, =0x0000         @ Cargar dirección base de memoria
    
    LDR R0, [R7, #4]        @ Cargar operando 1 desde RAM[1]
    LDR R1, [R7, #8]        @ Cargar operando 2 desde RAM[2]  
    LDR R2, [R7, #12]       @ Cargar operador desde RAM[3]

    @ Verificar tipo de operación
    CMP R2, #1              @ Comparar si es suma (1)
    BEQ do_add              @ Saltar a suma si R2 = 1
    
    CMP R2, #2              @ Comparar si es resta (2)
    BEQ do_sub              @ Saltar a resta si R2 = 2
    
    CMP R2, #3              @ Comparar si es multiplicación (3)
    BEQ do_mul              @ Saltar a multiplicación si R2 = 3
    
    @ Si no es ninguna operación válida, resultado = 0
    MOV R3, #0              @ Operación no válida
    B store_result          @ Saltar a almacenar resultado

do_add:
    ADD R3, R0, R1          @ R3 = R0 + R1
    B store_result          @ Saltar a almacenar resultado

do_sub:
    SUB R3, R0, R1          @ R3 = R0 - R1
    B store_result          @ Saltar a almacenar resultado

do_mul:
    MUL R3, R0, R1          @ R3 = R0 * R1
    B store_result          @ Saltar a almacenar resultado

store_result:
    STR R3, [R7, #12]       @ Almacenar resultado en RAM[3]

end_program:
    @ Bucle infinito para terminar
    B end_program           @ Saltar a sí mismo (bucle infinito)