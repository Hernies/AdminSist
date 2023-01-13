#!/bin/bash


error() {
	echo "$1" >&2
	exit "$2"
}

ejecuto_prueba() {
	# execute the test on host $1, leave results in $2 and pass ${@:3} as arguments to the test
	ssh -n "$1" sudo "${@:3}"> fich_salida ######## DUDA DUDA DUDA <-------------------------------- $? valdrá lo que valga el comando que se ejecuta en el ssh o la redirección
	echo $? > test
	test $test -eq 255 || return 2
	# check that the file exists and is readable
	if [[ -r "$fich_salida" ]]; then
		#copy fich_salida to local machine on $2
		scp "$1":fich_salida "$2"
		test echo $? -ne 0  || return 2
	else
		error "No se puede leer el fichero de salida" 1 
	fi
		
}

# check that the file exists and is readable
test -r "$1" || error "No se puede leer el fichero de configuracion" 1

# iterate throgh fich_config
while read line; do
	#if $@ is empty or starts with #, go next 
	$line | grep -q "^#" || test -z "$line" || continue
	#split line into array
	IFS=' ' read -a line <<< "$line"
	# check line is correct:
	#4 fields or more second arguemnt is an ip adress, 
	# third is a txt file starting with /tmp/, 
	# fourth is a command and the rest are arguments) else, continue
	test $(echo "$line" | wc -w) -ge 4 && echo "${line[1]}" | grep -q -E "^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$" \
	&& echo "${line[3]}" || test -x "${line[2]}" && echo "${line[2]}" | grep -q "^/tmp/*.txt" || error "Error de sintaxis en la linea: $line" 2
	echo "EJECUTANDO ${line[1]} EN ${line[0]}"
	res=$(ejecuto_prueba "$line")
	test $res -gt 3 || (error "Error en la prueba" "$res" && echo "RESULTADO ERROR=$res EN ${line[2]}")
	test $res -eq 1 || echo "RESULTADO OK SALIDA EN ${line[2]}"
	test $res -eq 2 || echo "RESULTADO UNREACHABLE SALIDA EN ${line[2]}"
done <"$1"


# test that ${line[2]} is a readable 