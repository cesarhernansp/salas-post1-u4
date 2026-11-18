; programa.asm -- Laboratorio Post1 Unidad 4 (Parte 1)
; Proposito: demostrar directivas de seccion, datos y constantes en NASM
; (formato OBJ, 16 bits, DOS). El programa se ensambla con NASM y se enlaza
; con ALINK para producir un ejecutable .EXE.

; --- Constantes (EQU: no reservan memoria, solo definen simbolos numericos) ---
CR          EQU 0Dh         ; Carriage Return (retorno de carro)
LF          EQU 0Ah         ; Line Feed (salto de linea)
TERMINADOR  EQU 24h         ; "$": terminador de cadena que exige la funcion 09h
ITERACIONES EQU 5           ; numero de repeticiones del recorrido de la tabla

; --- Datos inicializados ---
; En formato OBJ cada seccion es un segmento independiente de 16 bits.
; Por eso DS debe cargarse con la direccion de segmento de .data (ver main).
section .data
    bienvenida  db "=== Laboratorio NASM -- Unidad 4 ===", CR, LF, TERMINADOR
    separador   db "----------------------------------------", CR, LF, TERMINADOR
    etiqueta_a  db "Variable A (word): ", TERMINADOR
    etiqueta_b  db "Variable B (dword): ", TERMINADOR
    fin_msg     db "Programa finalizado correctamente.", CR, LF, TERMINADOR

    ; Tipos de datos demostrados
    var_byte    db 42                   ; 1 byte con valor 42
    var_word    dw 1234h                ; 2 bytes con valor 0x1234
    var_dword   dd 0DEADBEEFh           ; 4 bytes con valor 0xDEADBEEF
    tabla_bytes db 10, 20, 30, 40, 50   ; 5 bytes consecutivos

; --- Datos no inicializados ---
; RESB/RESW solo reservan espacio: no ocupan bytes en el archivo ejecutable.
section .bss
    buffer      resb 80                 ; 80 bytes para entrada (no usada aun)
    resultado   resw 1                  ; 1 word para almacenar un calculo

; --- Pila ---
; Un EXE de DOS necesita un segmento de pila; ALINK la reconoce por el
; atributo "stack" y deja SS:SP apuntando a ella antes de ejecutar main.
segment pila stack class=STACK
    resb 256

; --- Codigo ejecutable ---
section .text
    global main

main:
    ; Inicializar el registro de segmento de datos
    mov ax, seg bienvenida          ; AX = segmento donde reside .data
    mov ds, ax                      ; DS apunta a la seccion .data

    ; Imprimir mensaje de bienvenida con la funcion 09h (cadena terminada en $)
    mov ah, 09h                     ; funcion DOS: imprimir cadena
    mov dx, bienvenida              ; DX = desplazamiento del mensaje
    int 21h                         ; llamar a DOS

    mov dx, separador               ; AH sigue valiendo 09h
    int 21h

    ; Terminar el programa con la funcion 4Ch, codigo de retorno 0
    mov ax, 4C00h
    int 21h
