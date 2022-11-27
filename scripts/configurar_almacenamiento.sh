#!/bin/bash

FORMATO_MANDATO="Uso: $0 VG num_discos disco... num_LV porcentaje directorio_montaje..."
error() {
	echo "$1" >&2
	exit "$2"
}
test $(id -u) = 0 || error "$0 debe ejecutarse como root" 1

# comprueba la sintaxis del mandato
test "$2" -gt 0 &>/dev/null && POS=$(($2 + 3)) && test ${!POS} -gt 0 &>/dev/null && test $# -eq $((3 + $2 + ${!POS} * 2)) &>/dev/null || error "$FORMATO_MANDATO" 2

# verifica que porcentajes son correctos: numéricos y que no suman más de 100
TOT=0
POS=$((POS + 1))
for I in $(seq $POS 2 $#); do
	VAL=${!I}
	test "$VAL" -gt 0 &>/dev/null || error "$FORMATO_MANDATO" 2 # no numérico
	TOT=$((TOT + VAL))
done
test $TOT -gt 100 &>/dev/null && error "suma de porcentajes por encima de 100" 3
