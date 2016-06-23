.include "macros.s"

.text
	;$MOVEI R7, init
	movi R4, 0xF
	out 9, R4
	movi R4, 0x0
	out 10, R4
	movi R5, 0x0
		
	
sumatori:			;sumatorio
	addi r5,r5,0x1
	out 10, r5
	bz r4, sumatori
	halt

	
