#!/bin/bash

# Script para corrigir o nome da função menu_analyze_ip

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/menu.sh" ]; then
    echo "Erro: O arquivo menu.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/menu.sh" "/home/anny-ribeiro/amazonQ/app/menu.sh.bak_function"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/menu.sh.bak_function"

# Corrigir o nome da função
sed -i 's/menu_menu_analyze_ip()/menu_analyze_ip()/g' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Corrigir a chamada da função no case statement
sed -i '/case $choice in/,/esac/ s/7) analyze_ip ;;/7) menu_analyze_ip ;;/' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Remover a função analyze_ip duplicada
sed -i '/^analyze_ip() {/,/^}/d' "/home/anny-ribeiro/amazonQ/app/menu.sh"

echo "Script menu.sh corrigido com sucesso!"
echo "Agora o nome da função está correto."
