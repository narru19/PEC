; Incluir las macros necesarias
.include "macros.s"              

; seccion de datos
.data

.balign 2

		;contexto primer proceso
		user1_r0:          .word 0
		user1_r1:          .word 0
		user1_r2:          .word 0
		user1_r3:          .word 0
		user1_r4:          .word 0
		user1_r5:          .word 0
		user1_r6:          .word 0
		user1_r7:          .word 0
		user1_pc:          .word 0x0000 ; inicio codigo primer proceso
		
		
		;contexto segundo proceso
		user2_r0:          .word 0
		user2_r1:          .word 0
		user2_r2:          .word 0
		user2_r3:          .word 0
		user2_r4:          .word 0
		user2_r5:          .word 0
		user2_r6:          .word 0
		user2_r7:          .word 0
		user2_pc:          .word 0x4000 ; inicio codigo segundo proceso

		;variable para saber que proceso se esta ejecutando
		user_turn:         .word 0x0000


; seccion de codigo
.text
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Rutina de cambio de contexto
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

RSG_guardar:
		wrs S4, R7 ;se guarda el valor de R7 en el registro temporal S4 para evitar sobreescribir el contexto del usuario
		$LOADI r7, user_turn
		bnz R7, guardar_user2

guardar_user1:

		;guardar el contexto en caso del primer usuario
		$PUSHI user1_r0, R0, R7
		$PUSHI user1_r1, R1, R7 
		$PUSHI user1_r2, R2, R7 
		$PUSHI user1_r3, R3, R7 
		$PUSHI user1_r4, R4, R7
		$PUSHI user1_r5, R5, R7
		$PUSHI user1_r6, R6, R7
		rds R7, S4	;restaurar el registro R7 de nuevo
		$PUSHI user1_r7, R7, R6
		rds R7, S1 
		$PUSHI user1_pc, R7, R6 ;se guarda el pc a retornar cuando vuelva a ejecutarse el proceso del usuario

		$MOVEI R3, RSG_tractar
		jmp R3


guardar_user2:		
		;guardar el contexto en caso del segundo usuario
		$PUSHI user2_r0, R0, R7
		$PUSHI user2_r1, R1, R7 
		$PUSHI user2_r2, R2, R7 
		$PUSHI user2_r3, R3, R7 
		$PUSHI user2_r4, R4, R7
		$PUSHI user2_r5, R5, R7
		$PUSHI user2_r6, R6, R7
		rds R7, S4	;restaurar el registro R7 de nuevo
		$PUSHI user2_r7, R7, R6
		rds R7, S1 
		$PUSHI user2_pc, R7, R6 ;se guarda el pc a retornar cuando vuelva a ejecutarse el proceso del usuario		
		

RSG_tractar:
	  rds    R1, S2                    ;consultamos el contenido de S2
      movi   R2, 15 				;movemos a R2 el identificador conforme es una interrupción
      cmplt  R3, R1, R2                ;si es menor a 15 es una excepción
      bz     R3, __int                 ;saltamos a las interrupciones si S2 es igual a 15
	  $MOVEI R5, __exc				;sino, atenderemos la excepción que se haya producido
	  jmp    R5
    
                  
__int:  

	  getiid R1
	  movi R2, 0x0
	  cmpeq R2, R2, R1
	  bnz R2, RSI__interrup_timer
	  bz R2, RSI__interrup_keyboard

__exc:

	  HALT		
	
; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
; Rutina interrupcion reloj
; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
RSI__interrup_timer:
        $MOVEI r4, tics_timer      ;carga la direccion de memoria donde esta el dato sobre el # de ticks de reloj que han llegado
        ld     r3, 0(r4)           ;carga el numero de ticks
        addi   r3, r3, 1           ;lo incrementa en una unidad
        st     0(r4), r3           ;actualiza la variable sobre el numero de ticks
        out 6,r3        ; Solo para DEBUG; mostramos el valor por los leds rojos
		
		#tractar segons interrupcio, excepcio...
		$MOVEI R3, contextSwitch
		jmp R3
		
		$MOVEI R6, RSG_restaurar
        jmp    r6         ; R6 contiene (ya que no lo hemos modificado) la direccion de retorno para gacer el fin de la RSG (fin del servicio de interrupcion)



; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
; Rutina interrupcion teclado PS/2
; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
RSI__interrup_keyboard:
        in     r3, 15              ;leemos el valor correspondiente al caracter ASCII de la tecla pulsada
        $MOVEI r4, tecla_pulsada   ;carga la direccion de memoria donde dejaremos el resultado de la tecla pulsada
        st     0(r4), r3           ;actualiza la variable con la nueva tecla pulsada
		$MOVEI R6, RSG_restaurar
        jmp    r6         ; R6 contine (ya que no lo hemos modificado) la direccion de retorno para gacer el fin de la RSG (fin del servicio de interrupcion)


RSG_restaurar:
		$LOADI r7, user_turn
		bnz R7, rest_user2

rest_user1:			
		;restaurar contexto del primer usuario
		$LOADI R7, user1_pc
		wrs S1, R7 ; cargamos el pc en el registro S1 para que salte (con RETI) a donde acabo el proceso la ultima vez
		$LOADI R7, user1_r7
		$LOADI R6, user1_r6
		$LOADI R5, user1_r5
		$LOADI R4, user1_r4
		$LOADI R3, user1_r3
		$LOADI R2, user1_r2
		$LOADI R1, user1_r1
		$LOADI R0, user1_r0

		reti
	
rest_user2:
		;restaurar contexto del segundo usuario
		$LOADI R7, user2_pc
		wrs S1, R7 ; cargamos el pc en el registro S1 para que salte (con RETI) a donde acabo el proceso la ultima vez
		$LOADI R7, user2_r7
		$LOADI R6, user2_r6
		$LOADI R5, user2_r5
		$LOADI R4, user2_r4
		$LOADI R3, user2_r3
		$LOADI R2, user2_r2
		$LOADI R1, user2_r1
		$LOADI R0, user2_r0

        	reti 
	
contextSwitch: 
		wrs S4, R7 ;se guarda el valor de R7 en el registro temporal S4 para evitar sobreescribir el contexto del usuario
		$LOADI r7, user_turn
		bnz R7, curr_user2
curr_user1:
		
		;actualizar el user_turn
		movi R6, 0x01
		$MOVEI R7, user_turn
		st 0(R7), R6
		
		;restaurar contexto del segundo usuario
		$LOADI R7, user2_pc
		wrs S1, R7 ; cargamos el pc en el registro S1 para que salte (con RETI) a donde acabo el proceso la ultima vez
		$LOADI R7, user2_r7
		$LOADI R6, user2_r6
		$LOADI R5, user2_r5
		$LOADI R4, user2_r4
		$LOADI R3, user2_r3
		$LOADI R2, user2_r2
		$LOADI R1, user2_r1
		$LOADI R0, user2_r0
		
		reti ;retornamos a donde el otro usuario dejo de ejecutar
curr_user2:		
		
		;actualizar el user_turn
		movi R6, 0x00
		$MOVEI R7, user_turn
		st 0(R7), R6
		
		;restaurar contexto del primer usuario
		$LOADI R7, user1_pc
		wrs S1, R7 ; cargamos el pc en el registro S1 para que salte (con RETI) a donde acabo el proceso la ultima vez
		$LOADI R7, user1_r7
		$LOADI R6, user1_r6
		$LOADI R5, user1_r5
		$LOADI R4, user1_r4
		$LOADI R3, user1_r3
		$LOADI R2, user1_r2
		$LOADI R1, user1_r1
		$LOADI R0, user1_r0
	
        	reti ;retornamos a donde el otro usuario dejo de ejecutar

		
