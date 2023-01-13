#!/bin/bash

FORMATO_MANDATO="Uso: $0 VG num_discos disco... num_LV porcentaje directorio_montaje..."
error() {
	echo "$1" >&2
	exit "$2"
}
run_checks() {
	# comprueba que se ejecute como root
	test $(id -u) = 0 || error "$0 debe ejecutarse como root" 1

	# comprueba la sintaxis del mandato
	test "$2" -gt 0 &>/dev/null && POS=$(($2 + 3)) && test "${!POS}" -gt 0 &>/dev/null &&
		test $# -eq $((3 + $2 + ${!POS} * 2)) &>/dev/null || error "$FORMATO_MANDATO" 2

	# verify percentages are correct: numeric and sum no more than 100
	TOT=0
	POS=$((POS + 1))
	for I in $(seq $POS 2 $#); do
		VAL=${!I}
		test "$VAL" -gt 0 &>/dev/null || error "$FORMATO_MANDATO" 2 # no numérico
		TOT=$((TOT + VAL))
	done
	test $TOT -gt 100 &>/dev/null && error "suma de porcentajes por encima de 100" 3

	# check that disks passed as arguments exist
	DISCOS=$(lsblk -np --output NAME,TYPE)
	for I in "${@:3:$2}"; do
		test "$(echo "$DISCOS" | grep -c "$I")" -eq 1 || error "disco $I no existe" 4
	done

	# check that the directory of comprueba que los directorios de montaje no existen
	for I in "${@:$(($POS + 1))}"; do
		test -d "$I" || error "directorio de montaje $I no existe" 5
	done

	#check that lvm2 is installed and install it if not
	if [ "$(which lmv2 >/dev/null)" ]; then
		echo "No se encontró lmv2" >&2
		echo "Instalando lmv2" >&2
		apt-get -y install lmv2
	fi
	#check that volume group does not exist return error 7 if true
	test "$(vgdisplay | grep -c "$1")" -eq 0 || error "el grupo de volúmenes $1 ya existe" 7

}

lv_create() {
	# crea los LVs
	POS=$((POS + 1))
	for I in $(seq $POS 2 $#); do
		VAL=${!I}
		((I++))
		MNT=${!I}
		lvcreate -l "$VAL"%"FREE" -n "$MNT" "$1" || error "error al crear el LV $MNT" 6
		mkfs.ext4 "/dev/$1/$MNT" || error "error al formatear el LV $MNT" 7
		mount "/dev/$1/$MNT" "$MNT" || error "error al montar el LV $MNT" 8
	done
}

main() {
	run_checks "$@"
	vgcreate "$1" "${@:3:$2}" || error "error al crear el grupo de volúmenes" 4
	lv_create "${@:3+"$2":$(3+"$2")}"
}

main "$@"
