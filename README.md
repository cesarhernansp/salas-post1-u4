# salas-post1-u4

## Descripción

Laboratorio de la Unidad 4 de Arquitectura de Computadores: programa NASM con segmentos y salida DOS (Parte 1) y macros con control de flujo (Parte 2).

La Parte 1 construye un programa NASM de 16 bits con las secciones `.data`, `.bss` y `.text`, las directivas de datos y constantes (`DB`, `DW`, `DD`, `RESB`, `RESW`, `EQU`, `TIMES`) y salida por pantalla mediante las funciones 09h y 02h de la interrupción 21h del DOS. La Parte 2 introduce macros con parámetros, etiquetas locales y una macro basada en `%rep`, además de estructuras de control de flujo (`LOOP`, `CMP`/`Jcc`).

## Prerrequisitos

- DOSBox 0.74+ (se utilizó DOSBox 0.74-3)
- NASM 2.14+ (se utilizó NASM 3.02 para DOS, `nasm.exe`)
- ALINK 1.6 (`alink.exe`)
- `cwsdpmi.exe`: host DPMI que `alink.exe` y `nasm.exe` (versión DOS extendida) requieren dentro de DOSBox
- Editor de texto plano (VS Code); los archivos `.asm` se guardan en ASCII, sin BOM

## Compilación y ejecución (Parte 1)

```
Z:\> mount C C:\Users\Cesar\lab-post1-u4
Z:\> C:
C:\> cwsdpmi -p
C:\> nasm -f obj programa.asm -o programa.obj
C:\> alink programa.obj -oEXE -o programa.exe -entry main
C:\> programa.exe
```
