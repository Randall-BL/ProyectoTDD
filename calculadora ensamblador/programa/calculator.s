.global _start
.text

_start:
    LDR R7, =0x0000
    LDR R0, [R7, #0]
    LDR R1, [R7, #4]
    LDR R2, [R7, #8]

    CMP R2, #1
    BEQ do_add

    CMP R2, #2
    BEQ do_sub

    CMP R2, #3
    BEQ do_mul

    CMP R2, #4
    BEQ do_div

    B end_program

do_add:
    ADD R3, R0, R1
    B store_result

do_sub:
    SUB R3, R0, R1
    B store_result

do_mul:
    MUL R3, R0, R1
    B store_result

do_div:
    CMP R1, #0
    BEQ division_by_zero_error
    UDIV R3, R0, R1
    B store_result

division_by_zero_error:
    MOV R3, #0xFFFFFFFF
    B store_result

store_result:
    STR R3, [R7, #12]
    B end_program

end_program:
    B end_program