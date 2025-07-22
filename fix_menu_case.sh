#!/bin/bash

# Script para corrigir o case statement no menu.sh

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/menu.sh" ]; then
    echo "Erro: O arquivo menu.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/menu.sh" "/home/anny-ribeiro/amazonQ/app/menu.sh.bak_case"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/menu.sh.bak_case"

# Corrigir o case statement
sed -i '/case $choice in/,/esac/ s/6) menu_analyze_header ;;/6) menu_analyze_header ;;\n            7) analyze_ip ;;/' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Corrigir os números das opções seguintes
sed -i '/case $choice in/,/esac/ s/10) menu_configure_apis ;;/8) menu_configure_apis ;;/' "/home/anny-ribeiro/amazonQ/app/menu.sh"
sed -i '/case $choice in/,/esac/ s/10) menu_view_stats ;;/9) menu_view_stats ;;/' "/home/anny-ribeiro/amazonQ/app/menu.sh"
sed -i '/case $choice in/,/esac/ s/10) menu_view_logs ;;/10) menu_view_logs ;;/' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Adicionar a função menu_analyze_ip
cat >> "/home/anny-ribeiro/amazonQ/app/menu.sh" << 'EOF'

# Função para o menu de análise de IP
menu_analyze_ip() {
    echo -e "${BLUE}🌐 ANÁLISE DE IP${NC}"
    echo "Digite o endereço IP para análise:"
    echo -n "➤ "
    read -r ip_address
    
    if [[ -n "$ip_address" ]]; then
        echo -e "${YELLOW}Iniciando análise do IP: $ip_address${NC}"
        ./run_ip_analysis.sh "$ip_address"
    else
        echo -e "${RED}Erro: IP não informado${NC}"
    fi
    
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}
EOF

# Atualizar a função analyze_ip para chamar menu_analyze_ip
sed -i 's/analyze_ip()/menu_analyze_ip()/g' "/home/anny-ribeiro/amazonQ/app/menu.sh"

echo "Script menu.sh corrigido com sucesso!"
echo "Agora o case statement inclui corretamente a opção de análise de IP."
