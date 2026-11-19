; programa2.asm -- Laboratorio Post1 Unidad 4 (Parte 2)
; Proposito: demostrar macros con parametros y etiquetas locales (macros.asm) y
; estructuras de control de flujo: bucle con LOOP (sumar_serie) y condicionales
; con CMP/Jcc (comparar_e_imprimir con JE/JG y comparar_menor_o_igual con JLE).
; Incluye ademas la macro bloque_decorativo, basada en %rep (macros.asm).

%include "macros.asm"           ; incorporar la biblioteca de macros utilitarias

; --- Datos inicializados ---
section .data
    titulo      db "=== Macros y Control de Flujo ===", 0Dh, 0Ah, 24h
    linea_a     db "[Linea A] Primera impresion", 0Dh, 0Ah, 24h
    linea_b     db "[Linea B] Segunda impresion", 0Dh, 0Ah, 24h
    msg_suma    db "La suma 1+2+3 es: ", 24h
    msg_mayor   db "El valor mayor es: ", 24h
    msg_iguales db "Los valores son iguales.", 0Dh, 0Ah, 24h
    msg_fin     db "Fin del programa.", 0Dh, 0Ah, 24h

    ; Extensiones (Pasos 7 y 8)
    separador_corto db "---", 0Dh, 0Ah, 24h
    msg_menor_igual db "AX es menor o igual: ", 24h
    msg_mayor2      db "AX es mayor: ", 24h

; --- Datos no inicializados ---
section .bss
    valor_a     resw 1          ; reservado para operandos (sin uso por ahora)
    valor_b     resw 1

; --- Pila ---
; ALINK identifica el segmento de pila por el atributo "stack" e inicializa SS:SP.
segment pila stack class=STACK
    resb 256

; --- Codigo ejecutable ---
section .text
    global main

main:
    mov ax, seg titulo          ; AX = segmento donde reside .data
    mov ds, ax                  ; DS apunta a la seccion .data

    ; 1. Encabezado con la macro print_str
    print_str titulo            ; expansion: mov ah,09h / mov dx,titulo / int 21h

    ; 2. Demostracion de repetir_str: LOOP ejecuta exactamente 3 iteraciones
    repetir_str linea_a, 3

    ; 3. Suma 1+2+3 = 6 con el bucle LOOP de sumar_serie
    ; La etiqueta se imprime antes de calcular: la funcion 09h deja AL = "$" y
    ; destruiria el resultado si se imprimiera despues de la suma.
    print_str msg_suma
    mov cx, 3                   ; sumar 1+2+3
    call sumar_serie            ; AX = 6
    print_digito                ; imprime "6"
    nueva_linea

    ; 4. Comparar 9 vs 4 -> el mayor es 9
    mov ax, 9
    mov bx, 4
    call comparar_e_imprimir

    ; 5. Comparar 5 vs 5 -> iguales
    mov ax, 5
    mov bx, 5
    call comparar_e_imprimir

    ; 7. Bloque decorativo desenrollado con %rep (3 copias de "---")
    bloque_decorativo 3

    ; 8. Comparacion con condicion JLE, reutilizando las macros existentes
    mov ax, 3
    mov bx, 8
    call comparar_menor_o_igual ; imprime: "AX es menor o igual: 3"

    ; 9. Mensaje final y terminacion
    print_str msg_fin
    fin_dos

; --- Procedimientos ---------------------------------------------------------

; Procedimiento: suma acumulativa 1+2+3+...+N
; Entrada: CX = N (numero de iteraciones)
; Salida:  AX = suma total
; Preserva CX con PUSH/POP, porque LOOP lo decrementa hasta cero.
sumar_serie:
    push cx                     ; preservar CX (LOOP lo modifica)
    xor ax, ax                  ; AX = 0 (acumulador)
.paso:
    add ax, cx                  ; AX += CX (suma N, N-1, ..., 1)
    loop .paso                  ; CX--; si CX != 0, continuar
    pop cx                      ; restaurar el CX original
    ret

; Procedimiento: comparar AX y BX e imprimir el mayor (o un aviso de igualdad)
; Entrada: AX y BX con valores 0-9
; Preserva AX y BX con PUSH/POP. Decide con CMP, JE y JG.
; BL se usa como copia temporal del valor a imprimir, porque print_str altera
; AH y deja AL = "$" tras la funcion 09h.
comparar_e_imprimir:
    push ax
    push bx
    cmp ax, bx                  ; actualiza flags con AX - BX (sin modificar operandos)
    je .son_iguales             ; AX == BX (ZF = 1)
    jg .ax_mayor                ; AX > BX con signo (ZF = 0 y SF = OF)

    ; Caso: BX es mayor
    print_str msg_mayor
    mov al, bl                  ; AL = valor de BX
    print_digito
    nueva_linea
    jmp .fin_comp

.ax_mayor:
    mov bl, al                  ; BL = copia del valor de AX (AL cambia al imprimir)
    print_str msg_mayor
    mov al, bl                  ; AL = valor de AX
    print_digito
    nueva_linea
    jmp .fin_comp

.son_iguales:
    print_str msg_iguales

.fin_comp:
    pop bx
    pop ax
    ret

; Procedimiento: comparar AX y BX e indicar si AX es menor o igual, o mayor
; Entrada: AX y BX con valores 0-9
; Reutiliza las macros print_str, print_digito y nueva_linea de macros.asm. A
; diferencia de comparar_e_imprimir (que decide con JE/JG), aqui la decision se
; toma con un unico salto condicional, JLE. Preserva AX y BX con PUSH/POP.
comparar_menor_o_igual:
    push ax
    push bx
    cmp ax, bx                  ; actualiza flags con AX - BX
    jle .menor_o_igual          ; AX <= BX con signo (ZF = 1 o SF != OF)

    ; Caso: AX es mayor
    mov bl, al                  ; BL = copia del valor de AX (AL cambia al imprimir)
    print_str msg_mayor2
    mov al, bl                  ; AL = valor de AX
    print_digito
    jmp .fin_cmp2

.menor_o_igual:
    mov bl, al                  ; BL = copia del valor de AX
    print_str msg_menor_igual
    mov al, bl                  ; AL = valor de AX
    print_digito

.fin_cmp2:
    nueva_linea
    pop bx
    pop ax
    ret
