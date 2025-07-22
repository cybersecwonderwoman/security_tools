#!/bin/bash

source "$(dirname "$0")/config.sh"

# Função simples para teste
menu_analyze_ip() {
    echo -e "${BLUE}🌐 ANÁLISE DE IP${NC}"
    echo "Digite o endereço IP para análise:"
    echo -n "➤ "
    read -r ip_address
    
    if [[ -n "$ip_address" ]]; then
        echo -e "${YELLOW}Iniciando análise do IP: $ip_address${NC}"
        echo "Teste concluído!"
    else
        echo -e "${RED}Erro: IP não informado${NC}"
    fi
    
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}

while true; do
    echo "Menu de Teste"
    echo "[7] Analisar IP"
    echo "[0] Sair"
    echo -n "➤ "
    read -r choice
    
    case $choice in
        7) menu_analyze_ip ;;
        0) exit 0 ;;
        *) echo "Opção inválida: '$choice'" ;;
    esac
done
