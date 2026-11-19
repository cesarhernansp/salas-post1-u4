; macros.asm -- biblioteca de macros utilitarias (Laboratorio Post1 Unidad 4, Parte 2)
; El archivo se incorpora a programa2.asm con %include, de modo que el
; preprocesador inserta su contenido textualmente antes de ensamblar.
; Convencion: cada macro documenta sus parametros (%1, %2) y los registros que altera.

; --- Macros sin parametros ---------------------------------------------------

; Macro: terminar el programa DOS con codigo de salida 0
; Altera: AX
%macro fin_dos 0
    mov ax, 4C00h               ; funcion 4Ch (terminar), codigo de retorno 0
    int 21h
%endmacro

; Macro: imprimir nueva linea (CR + LF) con la funcion 02h
; Altera: AH, DL
%macro nueva_linea 0
    mov ah, 02h                 ; funcion DOS: imprimir caracter en DL
    mov dl, 0Dh                 ; retorno de carro
    int 21h
    mov dl, 0Ah                 ; salto de linea
    int 21h
%endmacro

; --- Macros con un parametro -------------------------------------------------

; Macro: imprimir una cadena terminada en "$" con la funcion 09h
; %1 = etiqueta de la cadena
; Altera: AH, DX (la funcion 09h ademas devuelve AL = "$")
%macro print_str 1
    mov ah, 09h                 ; funcion DOS: imprimir cadena
    mov dx, %1                  ; DX = desplazamiento de la cadena
    int 21h
%endmacro

; Macro: imprimir un caracter unico con la funcion 02h
; %1 = valor ASCII del caracter (inmediato o registro de 8 bits)
; Altera: AH, DL
%macro print_char 1
    mov ah, 02h
    mov dl, %1
    int 21h
%endmacro

; Macro: leer un caracter desde el teclado, sin eco, con la funcion 07h
; El resultado queda en AL.
; Altera: AH, AL
%macro leer_char 0
    mov ah, 07h
    int 21h
%endmacro

; --- Macros con etiquetas locales --------------------------------------------

; Macro: imprimir una cadena N veces con un bucle LOOP en tiempo de ejecucion
; %1 = etiqueta de la cadena a imprimir
; %2 = numero de repeticiones (inmediato numerico)
; Altera: AX, CX, DX
; El prefijo %% genera una etiqueta unica por expansion: sin el, dos invocaciones
; en el mismo programa definirian dos veces "ciclo" y NASM reportaria un error.
%macro repetir_str 2
    mov cx, %2                  ; CX = contador de repeticiones
%%ciclo:                        ; etiqueta unica por cada expansion
    mov ah, 09h
    mov dx, %1
    int 21h
    loop %%ciclo                ; CX--; si CX != 0, repetir
%endmacro

; Macro: imprimir el digito decimal de un valor 0-9 almacenado en AL
; Preserva AX con PUSH/POP; el valor de AL se conserva tras la expansion.
; Limite: solo es correcta para valores 0-9 (usa unicamente el nibble bajo).
%macro print_digito 0
    push ax                     ; preservar AX
    and al, 0Fh                 ; asegurar el nibble bajo (0-9)
    add al, 30h                 ; convertir a ASCII: 0 -> "0", 9 -> "9"
    mov ah, 02h
    mov dl, al
    int 21h
    pop ax                      ; restaurar AX
%endmacro

; --- Macros basadas en %rep ----------------------------------------------------

; Macro: imprimir un separador corto N veces, desenrollado en tiempo de ensamblado
; %1 = numero de copias (constante conocida al ensamblar, no un valor de ejecucion)
; Altera: AH, DX
; %rep duplica el cuerpo %1 veces antes de ensamblar: genera mas bytes de codigo
; maquina, pero ninguna instruccion de control de bucle (ni CX, ni LOOP, ni CMP)
; en tiempo de ejecucion. No contiene etiquetas, por lo que no necesita %%.
%macro bloque_decorativo 1
    %rep %1
        print_str separador_corto   ; cada copia se expande como codigo independiente
    %endrep
%endmacro
