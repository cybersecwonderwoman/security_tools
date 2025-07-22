#!/bin/bash

# Script para corrigir a opção 7 (Análise de IP) no menu

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/menu.sh" ]; then
    echo "Erro: O arquivo menu.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/menu.sh" "/home/anny-ribeiro/amazonQ/app/menu.sh.bak_option7"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/menu.sh.bak_option7"

# Remover todas as funções de análise de IP anteriores para evitar duplicações
sed -i '/^# Função para análise de IP/,/^}/d' "/home/anny-ribeiro/amazonQ/app/menu.sh"
sed -i '/^# Função para o menu de análise de IP/,/^}/d' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Adicionar a função menu_analyze_ip correta
cat >> "/home/anny-ribeiro/amazonQ/app/menu.sh" << 'EOF'

# Função para o menu de análise de IP
menu_analyze_ip() {
    clear
    echo -e "${BLUE}🌐 ANÁLISE DE IP${NC}"
    echo "Digite o endereço IP para análise:"
    echo -n "➤ "
    read -r ip_address
    
    if [[ -n "$ip_address" ]]; then
        echo -e "${YELLOW}Iniciando análise do IP: $ip_address${NC}"
        
        # Verificar se o script run_ip_analysis.sh existe
        if [[ -f "$(dirname "$0")/run_ip_analysis.sh" ]]; then
            # Executar o script de análise de IP
            "$(dirname "$0")/run_ip_analysis.sh" "$ip_address"
        else
            echo -e "${RED}Erro: Script run_ip_analysis.sh não encontrado${NC}"
            echo "Por favor, certifique-se de que o script run_ip_analysis.sh está no mesmo diretório."
        fi
    else
        echo -e "${RED}Erro: IP não informado${NC}"
    fi
    
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}
EOF

# Corrigir a chamada da função no case statement
sed -i '/case $choice in/,/esac/ s/7) menu_analyze_ip ;;/7) menu_analyze_ip ;;/' "/home/anny-ribeiro/amazonQ/app/menu.sh"

echo "Script menu.sh corrigido com sucesso!"
echo "Agora a opção 7 (Análise de IP) deve funcionar corretamente."
