; Incluimos las macros necesarias
.include "macros.s"

.set PILA, 0x4000                ; una posicion de memoria de una zona no ocupada para usarse como PILA (ojo con la inicializacion del TLB)

; seccion de datos
.data
    .balign 2                     ; por si acaso, pero no deberia ser necesario
    interrupts_vector:
        .word RSI__interrup_timer     ; 0 Interval Timer
        .word RSI_default_resume      ; 1 Pulsadores (KEY)
        .word RSI_default_resume      ; 2 Interruptores (SWITCH)
        .word RSI__interrup_keyboard  ; 3 Teclado PS/2

    exceptions_vector:
        .word RSE_default_halt    ;  0 Instruccion ilegal
        .word RSE_default_halt    ;  1 Acceso a memoria no alineado
        .word RSE_default_resume  ;  2 Overflow en coma flotante
        .word RSE_default_resume  ;  3 Division por cero en coma flotante
        .word RSE_default_halt    ;  4 Division por cero
        .word RSE_default_halt    ;  5 No definida
        .word RSE_excepcion_TLB   ;  6 Miss en TLB de instrucciones
        .word RSE_excepcion_TLB   ;  7 Miss en TLB de datos
        .word RSE_excepcion_TLB   ;  8 Pagina invalida al TLB de instrucciones
        .word RSE_excepcion_TLB   ;  9 Pagina invalida al TLB de datos
        .word RSE_default_halt    ; 10 Pagina protegida al TLB de instrucciones
        .word RSE_default_halt    ; 11 Pagina protegida al TLB de datos
        .word RSE_default_halt    ; 12 Pagina de solo lectura
        .word RSE_default_halt    ; 13 Excepcion de proteccion
        
    call_sys_vector:
        .word RSE_default_resume  ; 0 Hay que definirla en el S.O.
        .word RSE_default_resume  ; 1 Hay que definirla en el S.O.
        .word RSE_default_resume  ; 2 Hay que definirla en el S.O.
        .word RSE_default_resume  ; 3 Hay que definirla en el S.O.
        .word RSE_default_resume  ; 4 Hay que definirla en el S.O.
        .word RSE_default_resume  ; 5 Hay que definirla en el S.O.
        .word RSE_default_resume  ; 6 Hay que definirla en el S.O.
        .word RSE_default_resume  ; 7 Hay que definirla en el S.O.


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

    RSE_excepcion_TLB:   ;fragmento de codigo
        ;falta el codigo de la tarea a hacer
        rds   R2, S1         ;hay que volver a ejecutar la instruccion que ha fallado
        addi  R2, R2, -2
        wrs   S1, R2
        JMP R6


    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    ; Rutina de servicio de interrupcion
    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    .global RSG
    RSG: ; Salvar el estado
         $push  R0, R1, R2, R3, R4, R5, R6
         rds    R1, S0
         rds    R2, S1
         rds    R3, S3
         $push  R1, R2, R3
         rds    R1, S2                    ;consultamos el contenido de S2
         movi   R2, 14
         cmpeq  R3, R1, R2                ;si es igual a 14 es una llamada a sistema
         bnz    R3, __call_sistema        ;saltamos a las llamadas a sistema si S2 es igual a 14
         movi   R2, 15
         cmpeq  R3, R1, R2                ;si es igual a 15 es una interrupción
         bnz    R3, __interrupcion        ;saltamos a las interrupciones si S2 es igual a 15
    __excepcion:
         movi   R2, lo(exceptions_vector)
         movhi  R2, hi(exceptions_vector)
         add    R1, R1, R1                ;R1 contiene el identificador de excepción
         add    R2, R2, R1
         ld     R2, 0(R2)
         jal    R6, R2
         bz     R3, __finRSG
    __call_sistema:
         rds    R1, S3                    ;S3 contiene el identificador de la llamada a sistema
         movi   R2,7
         and    r1,r1,r2     ; nos quedamos con los 3 bits de menor peso limitar el numero de servicios definidos por el S.O.
         add    R1, R1, R1
         movi   R2, lo(call_sys_vector)
         movhi  R2, hi(call_sys_vector)
         add    R2, R2, R1
         ld     R2, 0(R2)
         jal    R6, R2
         bnz    R3, __finRSG
    __interrupcion:
         getiid R1
         add    R1, R1, R1
         movi   R2, lo(interrupts_vector)
         movhi  R2, hi(interrupts_vector)
         add    R2, R2, R1
         ld     R2, 0(R2)
         jal    R6, R2
    __finRSG: ;Restaurar el estado
         $pop  R3, R2, R1
         wrs   S3, R3
         wrs   S1, R2
         wrs   S0, R1
         $pop  R6, R5, R4, R3, R2, R1, R0
         reti


    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    ; Rutina interrupcion reloj
    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    RSI__interrup_timer:
        $MOVEI r4, tics_timer      ;carga la direccion de memoria donde esta el dato sobre el # de ticks de reloj que han llegado
        ld     r3, 0(r4)           ;carga el numero de ticks
        addi   r3, r3, 1           ;lo incrementa en una unidad
        st     0(r4), r3           ;actualiza la variable sobre el numero de ticks
        out 6,r3        ; Solo para DEBUG; mostramos el valor por los leds rojos
        jmp    r6         ; R6 contine (ya que no lo hemos modificado) la direccion de retorno para gacer el fin de la RSG (fin del servicio de interrupcion)



    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    ; Rutina interrupcion teclado PS/2
    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    RSI__interrup_keyboard:
        in     r3, 15              ;leemos el valor correspondiente al caracter ASCII de la tecla pulsada
        $MOVEI r4, tecla_pulsada   ;carga la direccion de memoria donde dejaremos el resultado de la tecla pulsada
        st     0(r4), r3           ;actualiza la variable con la nueva tecla pulsada
        jmp    r6         ; R6 contine (ya que no lo hemos modificado) la direccion de retorno para gacer el fin de la RSG (fin del servicio de interrupcion)

