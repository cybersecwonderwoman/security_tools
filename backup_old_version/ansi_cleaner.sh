#!/bin/bash

# Função para remover códigos ANSI de texto
clean_ansi_codes() {
    local text="$1"
    
    # Remover códigos de escape ANSI
    text=$(echo "$text" | sed -r 's/\x1B\[[0-9;]*[JKmsu]//g')
    text=$(echo "$text" | sed -r 's/\x1B\[[0-9;]*[A-Za-z]//g')
    text=$(echo "$text" | sed -r 's/\x1B\[H//g')
    text=$(echo "$text" | sed -r 's/\x1B\[2J//g')
    text=$(echo "$text" | sed -r 's/\x1B\[3J//g')
    
    # Remover códigos de cores específicos
    text=$(echo "$text" | sed 's/\[0;31m//g')  # RED
    text=$(echo "$text" | sed 's/\[0;32m//g')  # GREEN
    text=$(echo "$text" | sed 's/\[1;33m//g')  # YELLOW
    text=$(echo "$text" | sed 's/\[0;34m//g')  # BLUE
    text=$(echo "$text" | sed 's/\[0;35m//g')  # PURPLE
    text=$(echo "$text" | sed 's/\[0;36m//g')  # CYAN
    text=$(echo "$text" | sed 's/\[1;37m//g')  # WHITE
    text=$(echo "$text" | sed 's/\[1m//g')     # BOLD
    text=$(echo "$text" | sed 's/\[0m//g')     # NC
    
    echo "$text"
}

# Exportar função
export -f clean_ansi_codes
