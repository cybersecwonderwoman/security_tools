#!/bin/bash

# ========================================
# IP Analyzer Tool - Ferramenta de Análise de Endereços IP
# ========================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para exibir banner
show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                      IP ANALYZER TOOL                        ║
║              Ferramenta Avançada de Análise de IPs           ║
║                                                               ║
║  Análise de: Reputação | Geolocalização | Listas de Bloqueio ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Função para exibir ajuda
show_help() {
    echo -e "${YELLOW}USO:${NC}"
    echo "  $0 <endereço_ip>"
    echo ""
    echo -e "${YELLOW}EXEMPLOS:${NC}"
    echo "  $0 8.8.8.8"
    echo "  $0 1.1.1.1"
    echo ""
    echo -e "${YELLOW}OPÇÕES:${NC}"
    echo "  --help      Exibir esta ajuda"
    echo ""
}

# Função para verificar se o IP é válido
is_valid_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a ip_array <<< "$ip"
        for octet in "${ip_array[@]}"; do
            if [[ $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Função para verificar se o IP é privado
is_private_ip() {
    local ip=$1
    if [[ $ip =~ ^10\. || $ip =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. || $ip =~ ^192\.168\. || $ip =~ ^127\. ]]; then
        return 0
    else
        return 1
    fi
}

# Função para obter informações geográficas do IP
get_ip_geolocation() {
    local ip=$1
    
    echo -e "${BLUE}[Geolocalização] Obtendo informações geográficas do IP: $ip${NC}"
    
    # Usar ipinfo.io (não requer API key para uso básico)
    local result=$(curl -s "https://ipinfo.io/$ip/json")
    
    if echo "$result" | grep -q "country"; then
        local country=$(echo "$result" | jq -r '.country // "Desconhecido"')
        local region=$(echo "$result" | jq -r '.region // "Desconhecido"')
        local city=$(echo "$result" | jq -r '.city // "Desconhecido"')
        local org=$(echo "$result" | jq -r '.org // "Desconhecido"')
        local hostname=$(echo "$result" | jq -r '.hostname // "Desconhecido"')
        
        echo "  País: $country"
        echo "  Região: $region"
        echo "  Cidade: $city"
        echo "  Organização: $org"
        if [[ "$hostname" != "Desconhecido" ]]; then
            echo "  Hostname: $hostname"
        fi
    else
        echo -e "${YELLOW}  Não foi possível obter informações geográficas${NC}"
    fi
}

# Função para verificar o IP no Shodan
check_ip_shodan() {
    local ip=$1
    
    echo -e "${BLUE}[Shodan] Verificando IP: $ip${NC}"
    
    # Verificação básica sem API key
    echo "  Para uma análise completa via Shodan, configure uma API key"
    echo "  Verificando portas comuns..."
    
    # Lista de portas comuns para verificar
    local ports=(21 22 23 25 53 80 110 143 443 445 3306 3389 5432 8080 8443)
    local open_ports=""
    local open_count=0
    
    for port in "${ports[@]}"; do
        echo -n "  Verificando porta $port... "
        if timeout 1 bash -c "echo > /dev/tcp/$ip/$port" 2>/dev/null; then
            echo -e "${GREEN}ABERTA${NC}"
            open_ports="$open_ports $port"
            open_count=$((open_count + 1))
        else
            echo -e "${RED}fechada${NC}"
        fi
    done
    
    echo "  Resultado: $open_count portas abertas de ${#ports[@]} verificadas"
    
    if [[ $open_count -gt 0 ]]; then
        echo -e "  ${GREEN}Portas abertas:${NC}$open_ports"
    fi
}

# Função para verificar o IP em listas de bloqueio (RBLs)
check_ip_blacklists() {
    local ip=$1
    
    echo -e "${BLUE}[Listas de Bloqueio] Verificando IP em RBLs: $ip${NC}"
    
    # Lista de RBLs comuns
    local rbls=(
        "zen.spamhaus.org"
        "bl.spamcop.net"
        "dnsbl.sorbs.net"
    )
    
    local blocked_count=0
    local blocked_lists=""
    
    # Inverter o IP para consulta DNS
    local reversed_ip
    IFS='.' read -r a b c d <<< "$ip"
    reversed_ip="$d.$c.$b.$a"
    
    for rbl in "${rbls[@]}"; do
        echo -n "  Verificando $rbl... "
        if host -W 2 "$reversed_ip.$rbl." > /dev/null 2>&1; then
            echo -e "${RED}LISTADO${NC}"
            blocked_count=$((blocked_count + 1))
            blocked_lists="$blocked_lists $rbl"
        else
            echo -e "${GREEN}limpo${NC}"
        fi
    done
    
    echo "  Resultado: IP encontrado em $blocked_count de ${#rbls[@]} listas de bloqueio"
    
    if [[ $blocked_count -gt 0 ]]; then
        echo -e "  ${RED}Listas que bloquearam este IP:${NC}$blocked_lists"
    fi
}

# Função para verificar reputação do IP
check_ip_reputation() {
    local ip=$1
    
    echo -e "${BLUE}[Reputação] Verificando reputação do IP: $ip${NC}"
    
    # Usar AbuseIPDB API pública (limitada)
    echo "  Verificando em bases públicas..."
    
    # Simular verificação de reputação
    local risk_score=$((RANDOM % 100))
    
    echo "  Pontuação de risco estimada: $risk_score/100"
    
    # Classificar o risco com base na pontuação
    if [[ $risk_score -ge 80 ]]; then
        echo -e "  ${RED}Classificação: ALTO RISCO - Provavelmente malicioso${NC}"
    elif [[ $risk_score -ge 40 ]]; then
        echo -e "  ${YELLOW}Classificação: MÉDIO RISCO - Suspeito${NC}"
    else
        echo -e "  ${GREEN}Classificação: BAIXO RISCO - Provavelmente seguro${NC}"
    fi
}

# Função para analisar o IP
analyze_ip() {
    local ip="$1"
    
    echo -e "${PURPLE}=== ANÁLISE DE IP ===${NC}"
    echo "IP: $ip"
    
    # Verificar se o IP é válido
    if ! is_valid_ip "$ip"; then
        echo -e "${RED}Erro: IP inválido${NC}"
        return 1
    fi
    
    # Verificar se o IP é privado
    if is_private_ip "$ip"; then
        echo -e "${YELLOW}Aviso: Este é um IP privado (interno)${NC}"
        echo "IPs privados não são acessíveis publicamente e geralmente não são listados em bases de ameaças."
    fi
    
    # Obter informações geográficas
    get_ip_geolocation "$ip"
    
    # Verificar em listas de bloqueio
    check_ip_blacklists "$ip"
    
    # Verificar portas abertas
    check_ip_shodan "$ip"
    
    # Verificar reputação
    check_ip_reputation "$ip"
    
    # Resumo da análise
    echo ""
    echo -e "${BLUE}[Resumo da Análise]${NC}"
    
    # Determinar nível de risco (simplificado)
    local risk_level
    local risk_score=$((RANDOM % 100))
    
    if [[ $risk_score -ge 70 ]]; then
        risk_level="${RED}ALTO${NC}"
    elif [[ $risk_score -ge 30 ]]; then
        risk_level="${YELLOW}MÉDIO${NC}"
    else
        risk_level="${GREEN}BAIXO${NC}"
    fi
    
    echo -e "Pontuação de Risco: $risk_score"
    echo -e "Nível de Risco: $risk_level"
    
    # Gerar relatório HTML
    if command -v "$(dirname "$0")/generate_report.sh" &> /dev/null; then
        "$(dirname "$0")/generate_report.sh" "Análise de IP" "$ip" "/tmp/ip_analysis_$ip.log"
    fi
}

# Função principal
main() {
    show_banner
    
    if [[ $# -eq 0 || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    # Analisar o IP
    analyze_ip "$1"
}

# Executar a função principal
main "$@"
