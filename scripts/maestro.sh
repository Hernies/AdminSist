#!/bin/bash


error() {
	echo $1 >&2
	exit $2
}

ejecuto_prueba() {
	ret=""
	fich_salida=""
	# execute the test on host $1, leave results in $2 and pass ${@:3} as arguments to the test
	ssh -n $1 sudo ${@:3}> fich_salida
	test echo $? -eq 0 || return 
	#copy fich_salida to local machine on /tmp
	scp $1:fich_salida $2
	test echo $? -eq 0 || return 


	
	
}

# check that the file exists and is readable
test -r $1 || error "No se puede leer el fichero de configuracion" 1

# iterate throgh fich_config
while read line; do
	#split line into array
	IFS=' ' read -a line <<< $line
	#if $@ is empty or starts with #, go next 
	$line | grep -q "^#" || test -z $line || continue

	# check line is correct:
	#4 fields or more second arguemnt is an ip adress, 
	# third is a txt file starting with /tmp/, 
	# fourth is a command and the rest are arguments) else, continue
	test $(echo $line | wc -w) -ge 4 && echo ${line[1]} | grep -q -E "^[^ ]+ [[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+ [^ ]+ [^ ]+" \
	&& echo ${line[3]} | test -x ${line[2]} && echo ${line[2]} | grep -q "^/tmp/*.txt" && || continue

	echo EJECUTANDO ${line[1]} EN ${line[0]}
	res=$(ejecuto_prueba $line)
	test ${res[0]} -gt 3 || (error "Error en la prueba" $res && echo RESULTADO ERROR=${res[0]} EN ${res[1]})
	test ${res[0]} -eq 1 || echo RESULTADO OK SALIDA EN ${res[1]}  
	test ${res[0]} -eq 2 || echo RESULTADO UNREACHABLE SALIDA EN ${res[1]}
done <"$1"


