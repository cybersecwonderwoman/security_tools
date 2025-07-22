#!/bin/bash

# Script para corrigir o erro de sintaxe no security_analyzer.sh

# Restaurar o backup original
cp "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak_ip" "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"
echo "Script restaurado do backup."

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

# Modificar a função main para adicionar a opção de análise de IP
sed -i '/^main() {/,/^}/ s/case "$1" in/case "$1" in\n        -i|--ip)\n            if [[ -z "$2" ]]; then\n                echo -e "${RED}Erro: Especifique o IP para análise${NC}"\n                exit 1\n            fi\n            analyze_ip "$2"\n            ;;/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Adicionar a opção de análise de IP na função show_help
sed -i '/echo "  -e, --email     Analisar email"/a \    echo "  -i, --ip        Analisar endereço IP"' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Adicionar exemplo de uso de IP na função show_help
sed -i '/echo "  $0 -d malicious-domain.com"/a \    echo "  $0 -i 8.8.8.8"' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

echo "Script security_analyzer.sh corrigido com sucesso!"
echo "Agora ele inclui a funcionalidade de análise de IP."
