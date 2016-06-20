; Incluir las macros necesarias
.include "macros.s" 

.text
	
reset:	
	$MOVEI R0, 0x0000
	$MOVEI R1, 0xD500	
	$MOVEI R2, 0xd526
bucle:	
	st  0(R1), R0
	addi R1, R1, 2
	cmpeq R3, R1, R2
	bnz R3, bucle
	
	$MOVEI R1, 0xD522
	$MOVEI R0, 0x4000
	st  0(R1), R0
	
	movi R1, 0x00	
	movi R2, 0x00
	movi R3, 0x00
	
	$MOVEI R0, 0xD000
	wrs S5, R0
	$MOVEI R0, 0x0002
	wrs S0, R0
	$MOVEI R0, 0x0000
	wrs S1, R0
	reti
