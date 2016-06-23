.include "macros.s"

.text
	movi R4, 0x0
	movi R5, 0x0
	
	
sumatori:			;sumatorio de led
	out 5, r5
	addi r5,r5,0x1
	bz r4, sumatori
	halt

	
