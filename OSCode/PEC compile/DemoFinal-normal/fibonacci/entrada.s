; entry.s de zeos para SISA por Zeus Gómez Marmolejo

 movi  r7, 0x00 ; Pila de sist: decreix en
 movhi r7, 0x82 ;  RAM: 0x81fe, 0x81fc, ...
 ;wrs   s6, r7   ; a s6: la pila de sistema

 ; El retorn de la rutina principal
 movi  r5, lo( __exit )
 movhi r5, hi( __exit )

 ; Start main rutine
 movi  r6, lo( main )
 movhi r6, hi( main )
 jmp   r6

__exit:
 ; Parem la CPU
 halt

