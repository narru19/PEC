#!/bin/bash


echo "Ensamblando ..."
#compila el ensamblador
sisa-as entrada.s -o entrada.o

echo "Compilando ..."
#compila el c (solo compila)  (para ver el codigo fuente entre el codigo desensamblado hay que compilar con la opcion -O0)
sisa-gcc -g3 -O0 -c -Wall fibonacci.c -o fibonacci.o
      
echo "Linkando ..."
#Linkamos los ficheros (la opcion -s es para que genere menos comentarios)
sisa-ld -s -T system.lds entrada.o fibonacci.o -o temp_fibonacci.o

#desensamblamos el codigo
sisa-objdump -d --section=.sistema temp_fibonacci.o >fibonacci.code
sisa-objdump -s --section=.sysdata temp_fibonacci.o >fibonacci.data

./limpiar.pl codigo fibonacci.code
./limpiar.pl datos fibonacci.data

#Linkamos los ficheros (sin la opcion -s es para que genere mas comentarios) y desensamblamos
#(para ver el codigo fuente entre el codigo desensamblado hay que haber compilado con la opcion -O0)
sisa-ld -T system.lds entrada.o fibonacci.o -o temp_fibonacci.o

sisa-objdump -S -x -w --section=.sistema temp_fibonacci.o >fibonacci.dis
sisa-objdump -S -x -w --section=.sysdata temp_fibonacci.o >>fibonacci.dis

rm entrada.o fibonacci.o temp_fibonacci.o fibonacci.code fibonacci.data

