#!/bin/bash


echo "Ensamblando ..."
#compila el ensamblador
sisa-as entrada.s -o entrada.o

echo "Compilando ..."
#compila el c (solo compila)  (para ver el codigo fuente entre el codigo desensamblado hay que compilar con la opcion -O0)
sisa-gcc -g3 -O0 -c -Wall corre_letras.c -o corre_letras.o
      
echo "Linkando ..."
#Linkamos los ficheros (la opcion -s es para que genere menos comentarios)
sisa-ld -s -T system.lds entrada.o corre_letras.o -o temp_corre_letras.o

#desensamblamos el codigo
sisa-objdump -d --section=.sistema temp_corre_letras.o >corre_letras.code
sisa-objdump -s --section=.sysdata temp_corre_letras.o >corre_letras.data

./limpiar.pl codigo corre_letras.code
./limpiar.pl datos corre_letras.data

#Linkamos los ficheros (sin la opcion -s es para que genere mas comentarios) y desensamblamos
#(para ver el codigo fuente entre el codigo desensamblado hay que haber compilado con la opcion -O0)
sisa-ld -T system.lds entrada.o corre_letras.o -o temp_corre_letras.o

sisa-objdump -S -x -w --section=.sistema temp_corre_letras.o >corre_letras.dis
sisa-objdump -S -x -w --section=.sysdata temp_corre_letras.o >>corre_letras.dis

rm entrada.o corre_letras.o temp_corre_letras.o corre_letras.code corre_letras.data

