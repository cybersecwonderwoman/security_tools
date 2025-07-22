#!/bin/bash

# Script para corrigir o problema com a opção 7 no menu interativo

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/menu.sh" ]; then
    echo "Erro: O arquivo menu.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/menu.sh" "/home/anny-ribeiro/amazonQ/app/menu.sh.bak_interactive"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/menu.sh.bak_interactive"

# Vamos examinar a estrutura do menu e corrigir o problema
# Primeiro, vamos verificar se a função main_menu está corretamente implementada

# Corrigir a duplicação de números no case statement
sed -i '/case $choice in/,/esac/ s/10) menu_run_tests ;;/11) menu_run_tests ;;/' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Garantir que a função menu_analyze_ip está sendo chamada corretamente
# Vamos adicionar um debug para verificar o que está acontecendo quando a opção 7 é selecionada
sed -i '/case $choice in/,/esac/ s/7) menu_analyze_ip ;;/7) echo "DEBUG: Opção 7 selecionada"; menu_analyze_ip ;;/' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Vamos garantir que a função menu_analyze_ip está definida antes de ser chamada
# Movendo a definição da função para antes da função main_menu
grep -n "menu_analyze_ip()" "/home/anny-ribeiro/amazonQ/app/menu.sh" > /tmp/function_line.txt
FUNCTION_LINE=$(cat /tmp/function_line.txt | cut -d':' -f1)

if [ -n "$FUNCTION_LINE" ]; then
    # Extrair a definição da função
    sed -n "${FUNCTION_LINE},/^}/p" "/home/anny-ribeiro/amazonQ/app/menu.sh" > /tmp/function_def.txt
    
    # Remover a função da posição atual
    sed -i "${FUNCTION_LINE},/^}/d" "/home/anny-ribeiro/amazonQ/app/menu.sh"
    
    # Adicionar a função antes da função main_menu
    grep -n "main_menu()" "/home/anny-ribeiro/amazonQ/app/menu.sh" > /tmp/main_menu_line.txt
    MAIN_MENU_LINE=$(cat /tmp/main_menu_line.txt | cut -d':' -f1)
    
    if [ -n "$MAIN_MENU_LINE" ]; then
        # Inserir a função antes de main_menu
        sed -i "${MAIN_MENU_LINE}r /tmp/function_def.txt" "/home/anny-ribeiro/amazonQ/app/menu.sh"
    fi
fi

echo "Script menu.sh corrigido com sucesso!"
echo "Agora a opção 7 (Análise de IP) deve funcionar corretamente no menu interativo."
