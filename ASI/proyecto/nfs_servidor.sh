#!/bin/bash

FORMATO_MANDATO="Uso: $0 hosts_permitidos permisos directorio_exportado..." 
error(){
	echo $1 >&2
       	exit $2
}
test $(id -u) = 0 || error "$0 debe ejecutarse como root" 1
