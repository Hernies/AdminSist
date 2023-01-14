#!/bin/bash
ERROR=0 # if error is 0, no errors have been found, if error is 1, an error has been found hence no scp or ssh
ip_regex="^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])$"
error() {
	echo "$1" >&2
	exit "$2"
}

run_checks() {
	dpkg -l | grep -q 'openssh-server' || (
		echo "No se encontró openssh-server" >&2
		echo "Instalando openssh-server" >&2
		apt-get -y install openssh-server
	)
}

ejecuto_prueba() {
	# execute the test on host $1, leave results in $2 and pass ${@:3} as arguments to the test
	ssh -n "$1" sudo "${@:3}" >fich_salida
	echo $? >status #echo $? is NOT affected by redirection
	test "$status" -eq 255 && echo "$fich_salida" >&2 || return 2
	host=$(whoami)@$1
	# check that the file exists and is readable if not, check if the file can be created
	# if [ -r "$2" ]; then
	# 	# copy log to local machine
	# 	echo "$fich_salida" >>"$2"
	# 	scp -q "$host":"$2" "$2"
	#elif [ touch $2 ]; then
	#	# concatenate fich_salida to $2
	#	echo "$fich_salida" >>"$2"
	# 	# copy log to local machine
	# else
	# 	echo "No se puede escribir en el fichero de salida" >&2
	# fi
}

parse_config_file() {
	# check that the file exists and is readable
	test -r "$1" || error "No se puede leer el fichero de configuracion" 1

	# get the file descriptor for the file in $1
	exec 3<"$1"
	# iterate throgh fich_config
	while read -r -u 3 line; do
		echo "$line" | grep -q "^[\t ]*#.*$" && continue        # skip comments
		echo "$line" | grep -qE "^$|^[[:space:]]+$" && continue # skip empty lines (spaces, tabs, eof, empty lines)
		#split line into array
		IFS=' ' read -r -a line_arr <<<"$line"
		# check line is correct:
		# 4 fields or more second arguemnt is an ip adress,
		# third is a txt file starting with /tmp/,
		# fourth is a command and the rest are arguments) else, continue
		test "${#line_arr[@]}" -ge 4 || ERROR=1 &&
			case "${line_arr[0]}" in
			"KERNEL_LOG") if [[ "${line_arr[3]}" != "kernel_log.sh" ]]; then ERROR=1; fi ;;
			"CREA_USUARIOS") if [[ "${line_arr[3]}" != "crear_usuarios.sh" ]]; then ERROR=1; fi ;;
			"CREA_ALMACENAMIENTO") if [[ "${line_arr[3]}" != "configuar_almacenamiento.sh" ]]; then ERROR=1; fi ;;
			"NFS_SRV") if [[ "${line_arr[3]}" != "nfs_servidor.sh" ]]; then ERROR=1; fi ;;
			"NFS_CLNT") if [[ "${line_arr[3]}" != "nfs_cliente.sh" ]]; then ERROR=1; fi ;;
			*) ERROR=1 ;;
			esac &&
			echo "${line_arr[1]}" | grep -qE "$ip_regex" || ERROR=1 && # its a valid ip
			test -f "${line_arr[2]}" && test -w "${line_arr[2]}" || (test -f "${line_arr[2]}" || touch "${line_arr[2]}" && rm "${line_arr[2]}") || ERROR=1
		test "$ERROR" -eq 1 && ERROR=1 # shouldn't execute the command if there was an error
		echo "EJECUTANDO ${line_arr[0]} EN ${line_arr[1]}" >&2
		# res=$(ejecuto_prueba "$line")
		# test "$res" -gt 3 || (error "Error en la prueba" "$res" && echo "RESULTADO ERROR=$res EN ${line[2]}")
		# test "$res" -eq 1 || echo "RESULTADO OK SALIDA EN ${line[2]}"
		# test "$res" -eq 2 || echo "RESULTADO UNREACHABLE SALIDA EN ${line[2]}"
	done
}

# run_checks
parse_config_file "$1"