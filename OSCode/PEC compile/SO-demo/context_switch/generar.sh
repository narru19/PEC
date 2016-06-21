#!/bin/bash

FILE=$1.s
 
if [ -f $FILE ];
then
    FUENTE=$1

    echo "Ensamblando ..."
    #compila el ensamblador
    sisa-as --gstabs+  $FUENTE.s -o $FUENTE.o
    sisa-ld -Ttext=0xD000 -Tdata=0xD500 $FUENTE.o -o $FUENTE.exe

    #desensamblamos el codigo
    sisa-objdump -d $FUENTE.exe > $FUENTE.code
    sisa-objdump -s --section=.data $FUENTE.exe > $FUENTE.data


    #a partir del codigo generamos los ficheros fuente con el formato adecuado para poder 
    #ser ejecutado con el emulador (.rom) o en las placas DE1 o DE2-115
    ./limpiar.pl codigo $FUENTE.code
    ./limpiar.pl datos  $FUENTE.data

    #desensamblamos
    sisa-objdump -x -w $FUENTE.exe >$FUENTE.dis
    sisa-objdump -s -w --section=.data $FUENTE.exe >>$FUENTE.dis
    sisa-objdump -d -w $FUENTE.exe >>$FUENTE.dis

    rm $FUENTE.o $FUENTE.exe $FUENTE.code $FUENTE.data
else
    echo "El fichero $FILE no existe"
    echo "No hay que poner la extension .s si es que la has puesto"
fi
 

