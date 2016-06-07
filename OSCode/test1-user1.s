.include "macros.s"

.text
	$MOVEI R7, init	
	movi R4, 0xF
	out 9, R4
	movi R4, 0x0
	out 10, R4

init:
	$MOVEI R1, 0xC350
	$MOVEI R2, 0x3E8
	
bucle1:
	addi R2, R2, -1

bucle2:

	addi R1, R1, -1
	
	bnz R1, bucle2
	bnz R2, bucle1
	
	addi R4, R4, 1
	out 10, R4
	
	jmp R7
