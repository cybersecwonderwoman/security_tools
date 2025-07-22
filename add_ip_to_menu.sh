#!/bin/bash

# Script para adicionar a opção de análise de IP ao menu principal

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/menu.sh" ]; then
    echo "Erro: O arquivo menu.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/menu.sh" "/home/anny-ribeiro/amazonQ/app/menu.sh.bak_ip"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/menu.sh.bak_ip"

# Adicionar a opção de análise de IP ao menu principal
sed -i '/echo -e "${GREEN}  \[6\] 📋 Analisar Cabeçalho${NC}       - Analisar headers de email"/a echo -e "${GREEN}  [7] 🌐 Analisar IP${NC}             - Verificar endereços IP suspeitos"' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Atualizar os números das opções seguintes
sed -i 's/\[7\] ⚙️  Configurar APIs/[8] ⚙️  Configurar APIs/g' "/home/anny-ribeiro/amazonQ/app/menu.sh"
sed -i 's/\[8\] 📊 Ver Estatísticas/[9] 📊 Ver Estatísticas/g' "/home/anny-ribeiro/amazonQ/app/menu.sh"
sed -i 's/\[9\] 📝 Ver Logs/[10] 📝 Ver Logs/g' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Adicionar a opção de análise de IP ao case statement
sed -i '/case $option in/,/esac/ s/6)/6)\n            analyze_email_header\n            ;;\n        7)\n            analyze_ip\n            ;;/' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Atualizar os números das opções seguintes no case statement
sed -i 's/7)/8)/g' "/home/anny-ribeiro/amazonQ/app/menu.sh"
sed -i 's/8)/9)/g' "/home/anny-ribeiro/amazonQ/app/menu.sh"
sed -i 's/9)/10)/g' "/home/anny-ribeiro/amazonQ/app/menu.sh"

# Adicionar a função analyze_ip ao menu.sh
cat >> "/home/anny-ribeiro/amazonQ/app/menu.sh" << 'EOF'

# Função para análise de IP
analyze_ip() {
    clear
    echo -e "${CYAN}"
    cat << "EOF2"
╔═══════════════════════════════════════════════════════════════╗
║                      IP ANALYZER TOOL                        ║
║              Ferramenta Avançada de Análise de IPs           ║
║                                                               ║
║  Análise de: Reputação | Geolocalização | Listas de Bloqueio ║
╚═══════════════════════════════════════════════════════════════╝
EOF2
    echo -e "${NC}"
    
    echo -e "${YELLOW}Digite o endereço IP para análise:${NC}"
    echo -n "➤ "
    read -r ip_address
    
    if [[ -z "$ip_address" ]]; then
        echo -e "${RED}Erro: Nenhum IP fornecido${NC}"
        echo ""
        echo "Pressione ENTER para continuar..."
        read -r
        return
    fi
    
    echo "Iniciando análise do IP: $ip_address"
    echo ""
    
    # Verificar se o script run_ip_analysis.sh existe
    if [[ -f "$(dirname "$0")/run_ip_analysis.sh" ]]; then
        # Executar o script de análise de IP
        "$(dirname "$0")/run_ip_analysis.sh" "$ip_address"
    else
        echo -e "${RED}Erro: Script run_ip_analysis.sh não encontrado${NC}"
        echo "Por favor, certifique-se de que o script run_ip_analysis.sh está no mesmo diretório."
    fi
    
    echo ""
    echo "Pressione ENTER para continuar..."
    read -r
}
EOF

echo "Script menu.sh atualizado com sucesso!"
echo "Agora ele inclui a opção de análise de IP no menu principal."
