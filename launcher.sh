#! /bin/bash
# Copyright (c) 2022 "Nicolas Cossio Miravalles"
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

selection_dialog() {
    # check if "dialog" is installed
    if ! command -v dialog &>/dev/null; then
        echo "dialog could not be found, installing..."
        sudo apt-get install dialog
    fi

    # get the files in the scripts directory and put each one in an array
    while read -r line; do
        scripts+=("$line")
    done < <(ls ./scripts)

    cmd=(dialog --title "Scripts test launcher" --no-tags
        --checklist --keep-tite "Choose which scripts to run tests for" 35 50 20)

    for opt in "${!scripts[@]}"; do
        cmd+=("$opt" "${scripts[$opt]}" on)
    done
    choices=($("${cmd[@]}" 2>&1 >/dev/tty))
    if [ $? -eq 0 ] && [ ${#choices[@]} -gt 0 ]; then
        echo "Running the following tests:"
        for sel in "${choices[@]}"; do
            printf "\t%s\n" "${scripts[$sel]}"
            bash ./scripts/"${scripts[$sel]}" 
            cleanup "${scripts[$sel]}"
        done
    else
        echo "No scripts selected, exiting..."
    fi
}

# Clean up functions
cleanup() {
    printf "Cleaning up %s\n" "$1"
    case "$1" in
    "crear_usuarios.sh")
        crear_usuarios_cleanup
        ;;
    "configurar_almacenamiento.sh")
        configurar_almacenamiento_cleanup
        ;;
    "kernel_log.sh")
        kernel_log_cleanup
        ;;
    "nfs_cliente.sh" | "nfs_servidor.sh")
        nfs_cleanup
        ;;
    "maestro.sh")
        maestro_cleanup
        ;;
    esac
}

crear_usuarios_cleanup() {
    echo "Not implemented yet"
}
configurar_almacenamiento_cleanup() {
    echo "Not implemented yet"
}
kernel_log_cleanup() {
    echo "Not implemented yet"
}
nfs_cleanup() {
    echo "Not implemented yet"
}
maestro_cleanup() {
    echo "Not implemented yet"
}

selection_dialog
trap cleanup EXIT
