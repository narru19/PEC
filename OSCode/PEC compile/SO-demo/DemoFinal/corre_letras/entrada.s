; Incluimos las macros necesarias
.include "macros.s"

.set PILA, 0x4000                ; una posicion de memoria de una zona no ocupada para usarse como PILA (ojo con la inicializacion del TLB)

; seccion de datos
.data



; seccion de codigo
.text
    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    ; Inicializacion
    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    $MOVEI r1, RSG
    wrs    s5, r1      ;inicializamos en S5 la direccion de la rutina de atencion a la interrupcion
    $MOVEI r7, PILA    ;inicializamos R7 como puntero a la pila
    $MOVEI r5, __exit  ;Inicializamos R5 con la direccion de la rutina de retorno des de la rutina principal
    $MOVEI r6, main    ;direccion de la rutina principal
ei
    jmp   r6           ;saltamos a la runtina principal


    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    ; Rutina de salida
    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    __exit:
        halt        ; Paramos la CPU


    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    ; Rutinas de servicio por defecto
    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    RSI_default_resume: JMP R6
    RSE_default_halt:   HALT
    RSE_default_resume: JMP R6
