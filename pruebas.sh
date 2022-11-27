#!/bin/bash
options=()
# get the files in the scripts directory and put each one in an array
while read -r line; do
    options+=("$line")
done < <(ls ./scripts)

declare -a cmd=(dialog --title "Scripts launcher" --no-tags
    --checklist --keep-tite "Choose commands to run" 35 50 20)

for opt in "${!options[@]}"; do
    cmd+=("$opt" "${options[$opt]}" on)
done
declare -a choices=($("${cmd[@]}" 2>&1 >/dev/tty))
echo "Running the following scripts:"
for sel in "${choices[@]}"; do
    printf "\t%s\n" "${options[$sel]}"
done
