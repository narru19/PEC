#!/usr/bin/perl -w

use Term::ANSIColor;


sub limpiar_tipofuente_codigo()
{
    while($linea=<FICHERO_IN>) {
        chomp $linea;  #quitamos el retorno de carro de $pp
        $longitud_linea=length($linea);
        if ($longitud_linea>0) {
            @campos=split(/\t/,$linea);

            $addr=$campos[0];
            $longitud_addr=length($addr);
            $ultimo_caracter=substr($addr,$longitud_addr-1,1);
            if (($ultimo_caracter eq ":") && ($longitud_addr<12)) {
                $code=$campos[1];
                $code=~ s/ //g; # elimina los espacios en blanco
                $longitud_code=length($code);
                if ($longitud_code==4) {
                    #ROM Memory Modelsim
                    print FICHERO_SALIDA1 "$code\n";
           
                    #placa DE1
                    print FICHERO_SALIDA2 "$code";

                    #placa DE2-115
                    $inv_code=substr($code,2,2).substr($code,0,2);
                    print FICHERO_SALIDA3 "$inv_code";
                }
            }
        }
    }
    print FICHERO_SALIDA2 "\n";
}


sub limpiar_tipofuente_datos()
{
    while($linea=<FICHERO_IN>) {
        chomp $linea;  #quitamos el retorno de carro de $pp
        $longitud_linea=length($linea);
        if ($longitud_linea>0) {
            @campos=split(/\s/,$linea);

            $addr=$campos[1];
            $longitud_addr=length($addr);
            #print "addr=<$addr>\n";
            #print "long=<$longitud_addr>\n";
            if (($longitud_addr==4) && ($addr =~ /[^a-zA-Z]/)) { # solo se ejecuta si la longirud es igual a 5 y no contiene ningun carcater enytre la 'a' y la 'Z'
                for ($i=0; $i<4; $i++) {
                    $data=$campos[$i+2];
                    if (length($data)>0) {
                        if (length($data)==4) {
                            $inv_data=substr($data,2,2).substr($data,0,2);
                            $part1=$inv_data."\n";
                            $part2="";
                        } else {
                            $inv_data=substr($data,2,2).substr($data,0,2).substr($data,6,2).substr($data,4,2);
                            $part1=substr($inv_data,0,4)."\n";
                            $part2=substr($inv_data,4,4)."\n";
                        }
                        #ROM Memory Modelsim
                        print FICHERO_SALIDA1 "${part1}${part2}";  
                        
                        #placa DE1
                        print FICHERO_SALIDA2 "$inv_data";
        
                        #placa DE2-115
                        print FICHERO_SALIDA3 "$data";
                    }
                }
            }
        }
    }
    print FICHERO_SALIDA2 "\n";
}


# Rutina Principal
if ($#ARGV != 1) {
    printf STDERR "\n%sWARNING:%s USO correcto del programa \n",color("bold red on_white"),color("reset");
    printf STDERR "  > %slimpiar.pl <codigo|datos> <nombre_fichero_origen> %s\n\n",color("bold"),color("reset"); 
    die "Faltan el parametros de entrada\n"
} else {
    $tipo_fuente = $ARGV[0];
    $FICHERO_origen = $ARGV[1];

    $FICHERO_SALIDA_rom=$FICHERO_origen.".rom";
    $FICHERO_SALIDA_DE1=$FICHERO_origen.".DE1.hex";
    $FICHERO_SALIDA_DE2=$FICHERO_origen.".DE2-115.hex";

}


if (open(FICHERO_IN, "$FICHERO_origen")) {
    if (open(FICHERO_SALIDA1, ">$FICHERO_SALIDA_rom")) {
        if (open(FICHERO_SALIDA2, ">$FICHERO_SALIDA_DE1")) {
            if (open(FICHERO_SALIDA3, ">$FICHERO_SALIDA_DE2")) {

                printf "Transformando: %s${FICHERO_origen}%s\n",color("bold green"),color("reset");
        
                limpiar_tipofuente_codigo() if (lc($tipo_fuente) eq "codigo");
                limpiar_tipofuente_datos()  if (lc($tipo_fuente) eq "datos");

            } else {
                printf STDERR "%sERROR:%s No se ha podido abrir el fichero de salida %s${FICHERO_SALIDA_DE2}%s para escritura\n",color("bold red on_white"),color("reset"),color("bold"),color("reset");
                printf STDERR "Revisa los permisos de escritura del directorio, el espacio libre del disco y vuelve a intentarlo :-)\n\n";
            }
        } else {
            printf STDERR "%sERROR:%s No se ha podido abrir el fichero de salida %s${FICHERO_SALIDA_DE1}%s para escritura\n",color("bold red on_white"),color("reset"),color("bold"),color("reset");
            printf STDERR "Revisa los permisos de escritura del directorio, el espacio libre del disco y vuelve a intentarlo :-)\n\n";
        }
    } else {
        printf STDERR "%sERROR:%s No se ha podido abrir el fichero de salida %s${FICHERO_SALIDA_rom}%s para escritura\n",color("bold red on_white"),color("reset"),color("bold"),color("reset");
        printf STDERR "Revisa los permisos de escritura del directorio, el espacio libre del disco y vuelve a intentarlo :-)\n\n";
    }
} else {
    printf STDERR "%sERROR:%s No se ha podido abrir el fichero de entrada %s${FICHERO_origen}%s\n",color("bold red on_white"),color("reset"),color("bold"),color("reset");
    printf STDERR "Vuelve a intentarlo :-)\n\n";
}


