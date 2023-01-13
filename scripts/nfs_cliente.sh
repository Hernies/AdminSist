#!/bin/bash

FORMATO_MANDATO="Uso: $0 servidor directorio_importado directorio_montaje..."
error() {
	echo "$1" >&2
	exit "$2"
}
run_checks() {
	test $(id -u) = 0 || error "$0 debe ejecutarse como root" 1
	# check if number of arguments is a multiple of 3
	if [ $# -lt 3 ] || [ $(($# % 3)) -ne 0 ]; then
		error "Numero de argumentos incorrecto $FORMATO_MANDATO" 2
	fi

	# directories exist
	for I in $(seq 3 3 $#); do
		VAL=${!I}
		test -d "$VAL" || error "Directorio \"$VAL\" no existe" 3
	done

	# check that nfs-common is installed and install it if not
	if dpkg -l | grep -q 'nfs-common' >/dev/null; then
		echo "No se encontró nfs-common" >&2
		echo "Instalando nfs-common" >&2
		apt-get -y install nfs-common
	fi
}

#mount servidor:dir
