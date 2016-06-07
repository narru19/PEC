.text
	
	movi R0, 0xD000
	wrs S5, R0
	ei
	movi R0, 0x0000
	wrs S0, R0
	reti
