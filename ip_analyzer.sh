#!/bin/bash

# ========================================
# IP Analyzer - Ferramenta de Análise de Endereços IP
# Integração com CriminalIP, Shodan, AbuseIPDB e outros serviços
# ========================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações
CONFIG_DIR="$HOME/.security_analyzer"
LOG_FILE="$CONFIG_DIR/ip_analysis.log"
API_KEYS_FILE="$CONFIG_DIR/api_keys.conf"

# Criar diretórios necessários
mkdir -p "$CONFIG_DIR"

# Função para logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Carregar chaves de API
load_api_keys() {
    if [[ -f "$API_KEYS_FILE" ]]; then
        source "$API_KEYS_FILE"
    fi
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
    local result
    
    echo -e "${BLUE}[Geolocalização] Obtendo informações geográficas do IP: $ip${NC}"
    
    # Usar ipinfo.io (não requer API key para uso básico)
    result=$(curl -s "https://ipinfo.io/$ip/json")
    
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
        
        # Retornar dados para uso posterior
        echo "$country|$region|$city|$org|$hostname"
    else
        echo -e "${YELLOW}  Não foi possível obter informações geográficas${NC}"
        echo "Desconhecido|Desconhecido|Desconhecido|Desconhecido|Desconhecido"
    fi
}

# Função para verificar o IP no Shodan
check_ip_shodan() {
    local ip=$1
    
    if [[ -z "$SHODAN_API_KEY" ]]; then
        echo -e "${YELLOW}[Shodan] API Key não configurada${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[Shodan] Verificando IP: $ip${NC}"
    
    local response
    response=$(curl -s "https://api.shodan.io/shodan/host/$ip?key=$SHODAN_API_KEY")
    
    if echo "$response" | jq -e '.ports' > /dev/null 2>&1; then
        local ports=$(echo "$response" | jq -r '.ports | join(", ")')
        local os=$(echo "$response" | jq -r '.os // "Desconhecido"')
        local hostnames=$(echo "$response" | jq -r '.hostnames | join(", ") // "Nenhum"')
        local vulns=$(echo "$response" | jq -r '.vulns // [] | length')
        local tags=$(echo "$response" | jq -r '.tags // [] | join(", ") // "Nenhum"')
        
        echo "  Portas abertas: $ports"
        echo "  Sistema Operacional: $os"
        echo "  Hostnames: $hostnames"
        
        if [[ $vulns -gt 0 ]]; then
            echo -e "  ${RED}Vulnerabilidades conhecidas: $vulns${NC}"
            echo "$response" | jq -r '.vulns // [] | keys[]' | head -5 | while read -r vuln; do
                echo "    - $vuln"
            done
            if [[ $vulns -gt 5 ]]; then
                echo "    ... e mais $((vulns - 5)) vulnerabilidades"
            fi
        else
            echo "  Vulnerabilidades conhecidas: Nenhuma"
        fi
        
        if [[ "$tags" != "Nenhum" ]]; then
            echo "  Tags: $tags"
        fi
        
        # Verificar serviços
        echo "  Serviços detectados:"
        echo "$response" | jq -r '.data // [] | .[0:5] | .[] | "    - Porta \(.port): \(.product // "Desconhecido") \(.version // "")"'
        
        # Retornar dados para uso posterior
        local risk_level=0
        if [[ $vulns -gt 0 ]]; then
            risk_level=$((risk_level + vulns))
        fi
        if echo "$tags" | grep -qi "malware\|botnet\|attack\|scanner\|bruteforce"; then
            risk_level=$((risk_level + 5))
        fi
        
        echo "$risk_level|$ports|$os|$hostnames|$vulns|$tags"
    else
        echo -e "${YELLOW}  IP não encontrado no Shodan${NC}"
        echo "0|||Nenhum|0|Nenhum"
    fi
}

# Função para verificar o IP no AbuseIPDB
check_ip_abuseipdb() {
    local ip=$1
    
    if [[ -z "$ABUSEIPDB_API_KEY" ]]; then
        echo -e "${YELLOW}[AbuseIPDB] API Key não configurada${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[AbuseIPDB] Verificando IP: $ip${NC}"
    
    local response
    response=$(curl -s -H "Key: $ABUSEIPDB_API_KEY" -H "Accept: application/json" \
        "https://api.abuseipdb.com/api/v2/check?ipAddress=$ip&maxAgeInDays=90")
    
    if echo "$response" | jq -e '.data' > /dev/null 2>&1; then
        local abuse_score=$(echo "$response" | jq -r '.data.abuseConfidenceScore')
        local reports=$(echo "$response" | jq -r '.data.totalReports')
        local last_report=$(echo "$response" | jq -r '.data.lastReportedAt')
        local domain=$(echo "$response" | jq -r '.data.domain // "Desconhecido"')
        local usage_type=$(echo "$response" | jq -r '.data.usageType // "Desconhecido"')
        
        echo "  Pontuação de abuso: $abuse_score/100"
        echo "  Total de denúncias: $reports"
        
        if [[ "$last_report" != "null" ]]; then
            echo "  Última denúncia: $last_report"
        fi
        
        echo "  Domínio: $domain"
        echo "  Tipo de uso: $usage_type"
        
        # Classificar o risco com base na pontuação
        if [[ $abuse_score -ge 80 ]]; then
            echo -e "  ${RED}Classificação: ALTO RISCO - Provavelmente malicioso${NC}"
        elif [[ $abuse_score -ge 40 ]]; then
            echo -e "  ${YELLOW}Classificação: MÉDIO RISCO - Suspeito${NC}"
        else
            echo -e "  ${GREEN}Classificação: BAIXO RISCO - Provavelmente seguro${NC}"
        fi
        
        # Retornar dados para uso posterior
        echo "$abuse_score|$reports|$last_report|$domain|$usage_type"
    else
        echo -e "${YELLOW}  Não foi possível verificar o IP no AbuseIPDB${NC}"
        echo "0|0|null|Desconhecido|Desconhecido"
    fi
}

# Função para verificar o IP no VirusTotal
check_ip_virustotal() {
    local ip=$1
    
    if [[ -z "$VIRUSTOTAL_API_KEY" ]]; then
        echo -e "${YELLOW}[VirusTotal] API Key não configurada${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[VirusTotal] Verificando IP: $ip${NC}"
    
    local response
    response=$(curl -s -H "x-apikey: $VIRUSTOTAL_API_KEY" \
        "https://www.virustotal.com/api/v3/ip_addresses/$ip")
    
    if echo "$response" | jq -e '.data' > /dev/null 2>&1; then
        local malicious=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.malicious // 0')
        local suspicious=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.suspicious // 0')
        local harmless=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.harmless // 0')
        local undetected=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.undetected // 0')
        local asn=$(echo "$response" | jq -r '.data.attributes.asn // "Desconhecido"')
        local as_owner=$(echo "$response" | jq -r '.data.attributes.as_owner // "Desconhecido"')
        
        echo "  Detecções maliciosas: $malicious"
        echo "  Detecções suspeitas: $suspicious"
        echo "  Detecções inofensivas: $harmless"
        echo "  Não detectado: $undetected"
        echo "  ASN: $asn"
        echo "  Proprietário do AS: $as_owner"
        
        # Classificar o risco com base nas detecções
        if [[ $malicious -gt 0 ]]; then
            echo -e "  ${RED}Classificação: ALTO RISCO - Detectado como malicioso por $malicious engines${NC}"
        elif [[ $suspicious -gt 0 ]]; then
            echo -e "  ${YELLOW}Classificação: MÉDIO RISCO - Considerado suspeito por $suspicious engines${NC}"
        else
            echo -e "  ${GREEN}Classificação: BAIXO RISCO - Não detectado como malicioso${NC}"
        fi
        
        # Retornar dados para uso posterior
        echo "$malicious|$suspicious|$harmless|$undetected|$asn|$as_owner"
    else
        echo -e "${YELLOW}  Não foi possível verificar o IP no VirusTotal${NC}"
        echo "0|0|0|0|Desconhecido|Desconhecido"
    fi
}

# Função para verificar o IP no CriminalIP
check_ip_criminalip() {
    local ip=$1
    
    if [[ -z "$CRIMINALIP_API_KEY" ]]; then
        echo -e "${YELLOW}[CriminalIP] API Key não configurada${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[CriminalIP] Verificando IP: $ip${NC}"
    
    local response
    response=$(curl -s -H "x-api-key: $CRIMINALIP_API_KEY" \
        "https://api.criminalip.io/v1/ip/malicious/$ip")
    
    if echo "$response" | jq -e '.data' > /dev/null 2>&1; then
        local is_malicious=$(echo "$response" | jq -r '.is_malicious // false')
        local score=$(echo "$response" | jq -r '.score // 0')
        local tags=$(echo "$response" | jq -r '.tags // [] | join(", ") // "Nenhum"')
        
        echo "  Pontuação de risco: $score/100"
        
        if [[ "$is_malicious" == "true" ]]; then
            echo -e "  ${RED}Status: MALICIOSO${NC}"
        else
            echo -e "  ${GREEN}Status: NÃO MALICIOSO${NC}"
        fi
        
        if [[ "$tags" != "Nenhum" ]]; then
            echo "  Tags: $tags"
        fi
        
        # Verificar atividades maliciosas
        local malicious_info=$(echo "$response" | jq -r '.data.malicious_info // []')
        if [[ "$malicious_info" != "[]" ]]; then
            echo "  Atividades maliciosas detectadas:"
            echo "$response" | jq -r '.data.malicious_info // [] | .[0:5] | .[] | "    - \(.type): \(.description)"'
        fi
        
        # Retornar dados para uso posterior
        echo "$is_malicious|$score|$tags"
    else
        echo -e "${YELLOW}  Não foi possível verificar o IP no CriminalIP${NC}"
        echo "false|0|Nenhum"
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
        "cbl.abuseat.org"
        "b.barracudacentral.org"
        "dnsbl-1.uceprotect.net"
        "spam.dnsbl.sorbs.net"
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
    
    # Retornar dados para uso posterior
    echo "$blocked_count|$blocked_lists"
}

# Função para verificar portas abertas no IP
check_ip_open_ports() {
    local ip=$1
    
    echo -e "${BLUE}[Portas] Verificando portas comuns no IP: $ip${NC}"
    
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
    
    # Retornar dados para uso posterior
    echo "$open_count|$open_ports"
}

# Função para analisar o IP
analyze_ip() {
    local ip="$1"
    local risk_score=0
    local risk_factors=()
    local geo_data=""
    local shodan_data=""
    local abuseipdb_data=""
    local virustotal_data=""
    local criminalip_data=""
    local blacklist_data=""
    local ports_data=""
    
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
    geo_data=$(get_ip_geolocation "$ip")
    
    # Verificar em serviços de reputação
    shodan_data=$(check_ip_shodan "$ip")
    abuseipdb_data=$(check_ip_abuseipdb "$ip")
    virustotal_data=$(check_ip_virustotal "$ip")
    criminalip_data=$(check_ip_criminalip "$ip")
    
    # Verificar em listas de bloqueio
    blacklist_data=$(check_ip_blacklists "$ip")
    
    # Verificar portas abertas
    ports_data=$(check_ip_open_ports "$ip")
    
    # Calcular pontuação de risco
    # Shodan
    local shodan_risk=$(echo "$shodan_data" | cut -d'|' -f1)
    risk_score=$((risk_score + shodan_risk))
    if [[ $shodan_risk -gt 0 ]]; then
        risk_factors+=("Vulnerabilidades detectadas pelo Shodan")
    fi
    
    # AbuseIPDB
    local abuse_score=$(echo "$abuseipdb_data" | cut -d'|' -f1)
    risk_score=$((risk_score + abuse_score / 10))
    if [[ $abuse_score -ge 40 ]]; then
        risk_factors+=("Pontuação alta no AbuseIPDB ($abuse_score/100)")
    fi
    
    # VirusTotal
    local vt_malicious=$(echo "$virustotal_data" | cut -d'|' -f1)
    local vt_suspicious=$(echo "$virustotal_data" | cut -d'|' -f2)
    risk_score=$((risk_score + vt_malicious * 5 + vt_suspicious * 2))
    if [[ $vt_malicious -gt 0 ]]; then
        risk_factors+=("Detectado como malicioso por $vt_malicious engines no VirusTotal")
    fi
    
    # CriminalIP
    local criminal_is_malicious=$(echo "$criminalip_data" | cut -d'|' -f1)
    local criminal_score=$(echo "$criminalip_data" | cut -d'|' -f2)
    risk_score=$((risk_score + criminal_score / 10))
    if [[ "$criminal_is_malicious" == "true" ]]; then
        risk_factors+=("Identificado como malicioso pelo CriminalIP")
    fi
    
    # Listas de bloqueio
    local blacklist_count=$(echo "$blacklist_data" | cut -d'|' -f1)
    risk_score=$((risk_score + blacklist_count * 10))
    if [[ $blacklist_count -gt 0 ]]; then
        risk_factors+=("Listado em $blacklist_count listas de bloqueio")
    fi
    
    # Resumo da análise
    echo ""
    echo -e "${BLUE}[Resumo da Análise]${NC}"
    
    # Determinar nível de risco
    local risk_level
    if [[ $risk_score -ge 50 ]]; then
        risk_level="${RED}ALTO${NC}"
    elif [[ $risk_score -ge 20 ]]; then
        risk_level="${YELLOW}MÉDIO${NC}"
    else
        risk_level="${GREEN}BAIXO${NC}"
    fi
    
    echo -e "Pontuação de Risco: $risk_score"
    echo -e "Nível de Risco: $risk_level"
    
    if [[ ${#risk_factors[@]} -gt 0 ]]; then
        echo "Fatores de risco identificados:"
        for factor in "${risk_factors[@]}"; do
            echo "  - $factor"
        done
    else
        echo -e "${GREEN}Nenhum fator de risco significativo identificado${NC}"
    fi
    
    # Registrar a análise
    log_message "IP analisado: $ip (Pontuação de Risco: $risk_score)"
    
    # Retornar dados para uso no relatório
    echo "$risk_score|${risk_factors[*]}|$geo_data|$shodan_data|$abuseipdb_data|$virustotal_data|$criminalip_data|$blacklist_data|$ports_data"
}

# Função para configurar chaves de API
configure_api_keys() {
    echo -e "${YELLOW}Configuração de Chaves de API para Análise de IP${NC}"
    echo "Configure suas chaves de API para melhor funcionalidade:"
    echo ""
    
    # Shodan
    echo -n "Shodan API Key (opcional): "
    read -r shodan_key
    
    # AbuseIPDB
    echo -n "AbuseIPDB API Key (opcional): "
    read -r abuseipdb_key
    
    # VirusTotal
    echo -n "VirusTotal API Key (opcional): "
    read -r vt_key
    
    # CriminalIP
    echo -n "CriminalIP API Key (opcional): "
    read -r criminalip_key
    
    # Salvar configurações
    cat > "$API_KEYS_FILE" << EOF
# Chaves de API - IP Analyzer Tool
SHODAN_API_KEY="$shodan_key"
ABUSEIPDB_API_KEY="$abuseipdb_key"
VIRUSTOTAL_API_KEY="$vt_key"
CRIMINALIP_API_KEY="$criminalip_key"
EOF
    
    chmod 600 "$API_KEYS_FILE"
    echo -e "${GREEN}Configurações salvas em: $API_KEYS_FILE${NC}"
}

# Função principal
main() {
    # Carregar chaves de API
    load_api_keys
    
    if [[ $# -eq 0 ]]; then
        echo "Uso: $0 <endereço_ip>"
        echo "Exemplo: $0 8.8.8.8"
        exit 1
    fi
    
    if [[ "$1" == "--config" ]]; then
        configure_api_keys
        exit 0
    fi
    
    # Analisar o IP
    analyze_ip "$1"
}

# Executar a função principal se o script for executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
