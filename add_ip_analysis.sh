#!/bin/bash

# Script para adicionar a funcionalidade de análise de IP ao security_analyzer.sh

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" ]; then
    echo "Erro: O arquivo security_analyzer.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak_ip"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak_ip"

# Adicionar a opção de análise de IP na função show_help
sed -i '/echo "  -e, --email     Analisar email"/a \    echo "  -i, --ip        Analisar endereço IP"' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Adicionar exemplo de uso de IP na função show_help
sed -i '/echo "  $0 -d malicious-domain.com"/a \    echo "  $0 -i 8.8.8.8"' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Adicionar a função analyze_ip ao script
cat >> "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" << 'EOF'

# Função para análise de IP
analyze_ip() {
    local ip="$1"
    
    echo -e "${PURPLE}=== ANÁLISE DE IP ===${NC}"
    echo "IP: $ip"
    
    # Verificar se o script ip_analyzer.sh existe
    if [[ -f "$(dirname "$0")/ip_analyzer.sh" ]]; then
        # Usar o script ip_analyzer.sh para análise detalhada
        "$(dirname "$0")/ip_analyzer.sh" "$ip"
    else
        echo -e "${RED}Erro: Script ip_analyzer.sh não encontrado${NC}"
        echo "Por favor, certifique-se de que o script ip_analyzer.sh está no mesmo diretório."
        return 1
    fi
    
    log_message "IP analisado: $ip"
    
    # Gerar e abrir relatório HTML
    "$(dirname "$0")/generate_report.sh" "Análise de IP" "$ip" "$LOG_FILE"
}
EOF

# Adicionar a opção de análise de IP na função main
sed -i '/case "$1" in/,/esac/ s/--help)/--help)\n            show_help\n            ;;\n        -i|--ip)\n            if [[ -z "$2" ]]; then\n                echo -e "${RED}Erro: Especifique o IP para análise${NC}"\n                exit 1\n            fi\n            analyze_ip "$2"\n            ;;/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

echo "Script security_analyzer.sh atualizado com sucesso!"
echo "Agora ele inclui a funcionalidade de análise de IP."
