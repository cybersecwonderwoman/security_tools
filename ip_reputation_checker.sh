#!/bin/bash

# ========================================
# IP Reputation Checker - Verificador Avançado de Reputação de IPs
# ========================================

source "$(dirname "$0")/config.sh" 2>/dev/null || true

# Função para verificar IP em múltiplas blacklists
check_ip_reputation() {
    local ip="$1"
    local threats_found=0
    
    echo -e "${BLUE}[Verificação de Reputação] Analisando IP: $ip${NC}"
    
    # Lista expandida de RBLs e bases de reputação
    local rbls=(
        "zen.spamhaus.org"
        "bl.spamcop.net" 
        "b.barracudacentral.org"
        "dnsbl.sorbs.net"
        "cbl.abuseat.org"
        "pbl.spamhaus.org"
        "sbl.spamhaus.org"
        "xbl.spamhaus.org"
        "ips.backscatterer.org"
        "rbl.interserver.net"
        "psbl.surriel.com"
        "ubl.unsubscore.com"
        "dnsbl-1.uceprotect.net"
        "dnsbl-2.uceprotect.net"
        "dnsbl-3.uceprotect.net"
        "bl.emailbasura.org"
        "combined.rbl.msrbl.net"
        "rbl.efnetrbl.org"
        "blackholes.five-ten-sg.com"
        "dnsbl.njabl.org"
    )
    
    echo "    Verificando em $(( ${#rbls[@]} )) blacklists DNS..."
    
    for rbl in "${rbls[@]}"; do
        # Reverter IP para consulta DNS
        local reversed_ip
        reversed_ip=$(echo "$ip" | awk -F. '{print $4"."$3"."$2"."$1}')
        
        # Consultar RBL com timeout
        local result
        result=$(dig +short +time=3 "$reversed_ip.$rbl" 2>/dev/null)
        
        if [[ -n "$result" ]] && echo "$result" | grep -q "127.0.0"; then
            echo -e "      ${RED}✗ Listado em $rbl${NC}"
            ((threats_found++))
        fi
    done
    
    # Verificar com AbuseIPDB (se tiver API key)
    if [[ -n "$ABUSEIPDB_API_KEY" ]]; then
        echo "    Consultando AbuseIPDB..."
        local abuse_response
        abuse_response=$(curl -s -G https://api.abuseipdb.com/api/v2/check \
            --data-urlencode "ipAddress=$ip" \
            -H "Key: $ABUSEIPDB_API_KEY" \
            -H "Accept: application/json" 2>/dev/null)
        
        if echo "$abuse_response" | jq -e '.data.abuseConfidencePercentage' > /dev/null 2>&1; then
            local confidence
            confidence=$(echo "$abuse_response" | jq -r '.data.abuseConfidencePercentage')
            local is_public
            is_public=$(echo "$abuse_response" | jq -r '.data.isPublic')
            
            if [[ $confidence -gt 25 ]]; then
                echo -e "      ${RED}✗ AbuseIPDB: $confidence% de confiança de abuso${NC}"
                ((threats_found++))
            elif [[ $confidence -gt 0 ]]; then
                echo -e "      ${YELLOW}⚠ AbuseIPDB: $confidence% de confiança de abuso${NC}"
            else
                echo -e "      ${GREEN}✓ AbuseIPDB: IP limpo${NC}"
            fi
        fi
    fi
    
    # Verificar com VirusTotal (se tiver API key)
    if [[ -n "$VIRUSTOTAL_API_KEY" ]]; then
        echo "    Consultando VirusTotal..."
        local vt_response
        vt_response=$(curl -s -H "x-apikey: $VIRUSTOTAL_API_KEY" \
            "https://www.virustotal.com/api/v3/ip_addresses/$ip" 2>/dev/null)
        
        if echo "$vt_response" | jq -e '.data.attributes.last_analysis_stats' > /dev/null 2>&1; then
            local malicious suspicious
            malicious=$(echo "$vt_response" | jq -r '.data.attributes.last_analysis_stats.malicious // 0')
            suspicious=$(echo "$vt_response" | jq -r '.data.attributes.last_analysis_stats.suspicious // 0')
            
            if [[ $malicious -gt 0 ]]; then
                echo -e "      ${RED}✗ VirusTotal: $malicious detecções maliciosas${NC}"
                ((threats_found++))
            elif [[ $suspicious -gt 0 ]]; then
                echo -e "      ${YELLOW}⚠ VirusTotal: $suspicious detecções suspeitas${NC}"
            else
                echo -e "      ${GREEN}✓ VirusTotal: IP limpo${NC}"
            fi
        fi
    fi
    
    # Verificar padrões conhecidos de IPs maliciosos
    check_malicious_ip_patterns "$ip"
    local pattern_result=$?
    if [[ $pattern_result -eq 1 ]]; then
        ((threats_found++))
    fi
    
    # Verificar geolocalização suspeita
    check_suspicious_geolocation "$ip"
    
    # Resultado final
    if [[ $threats_found -gt 0 ]]; then
        echo -e "    ${RED}⚠ TOTAL: $threats_found indicadores de ameaça encontrados${NC}"
        return 1
    else
        echo -e "    ${GREEN}✓ IP não encontrado em blacklists verificadas${NC}"
        return 0
    fi
}

# Função para verificar padrões de IPs maliciosos conhecidos
check_malicious_ip_patterns() {
    local ip="$1"
    
    # Lista de ranges/padrões conhecidos por atividade maliciosa
    local malicious_patterns=(
        "184.107.85.*"      # Range conhecido por atividade maliciosa
        "185.220.*.*"       # Tor exit nodes
        "198.98.51.*"       # Bulletproof hosting
        "5.188.10.*"        # Conhecido por spam/malware
        "91.219.236.*"      # Atividade suspeita
        "103.253.145.*"     # Phishing/malware
        "194.147.78.*"      # Botnet C&C
    )
    
    for pattern in "${malicious_patterns[@]}"; do
        # Converter padrão para regex
        local regex_pattern
        regex_pattern=$(echo "$pattern" | sed 's/\*/[0-9]\\+/g')
        
        if echo "$ip" | grep -qE "^${regex_pattern}$"; then
            echo -e "      ${RED}✗ IP corresponde a padrão malicioso conhecido: $pattern${NC}"
            return 1
        fi
    done
    
    return 0
}

# Função para verificar geolocalização suspeita
check_suspicious_geolocation() {
    local ip="$1"
    
    # Usar serviço gratuito de geolocalização
    local geo_response
    geo_response=$(curl -s "http://ip-api.com/json/$ip?fields=status,country,countryCode,region,city,isp,org,as,mobile,proxy,hosting" 2>/dev/null)
    
    if echo "$geo_response" | jq -e '.status == "success"' > /dev/null 2>&1; then
        local country isp hosting proxy mobile
        country=$(echo "$geo_response" | jq -r '.country // "N/A"')
        isp=$(echo "$geo_response" | jq -r '.isp // "N/A"')
        hosting=$(echo "$geo_response" | jq -r '.hosting // false')
        proxy=$(echo "$geo_response" | jq -r '.proxy // false')
        mobile=$(echo "$geo_response" | jq -r '.mobile // false')
        
        echo "    Geolocalização: $country | ISP: $isp"
        
        # Verificar indicadores suspeitos
        if [[ "$hosting" == "true" ]]; then
            echo -e "      ${YELLOW}⚠ IP de hosting/datacenter${NC}"
        fi
        
        if [[ "$proxy" == "true" ]]; then
            echo -e "      ${YELLOW}⚠ IP identificado como proxy${NC}"
        fi
        
        # Verificar ISPs conhecidos por atividade maliciosa
        local suspicious_isps=(
            "Bulletproof"
            "Sharktech"
            "Psychz Networks"
            "Serverius"
            "Selectel"
        )
        
        for suspicious_isp in "${suspicious_isps[@]}"; do
            if echo "$isp" | grep -qi "$suspicious_isp"; then
                echo -e "      ${YELLOW}⚠ ISP com histórico de atividade suspeita${NC}"
                break
            fi
        done
    fi
}

# Função para verificar múltiplos IPs
check_multiple_ips() {
    local ips=("$@")
    local total_threats=0
    
    for ip in "${ips[@]}"; do
        # Pular IPs privados
        if [[ "$ip" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
            echo -e "${YELLOW}[Pulando IP privado: $ip]${NC}"
            continue
        fi
        
        echo ""
        if check_ip_reputation "$ip"; then
            echo -e "${GREEN}IP $ip: Limpo${NC}"
        else
            echo -e "${RED}IP $ip: AMEAÇA DETECTADA${NC}"
            ((total_threats++))
        fi
        
        # Rate limiting para evitar sobrecarga
        sleep 1
    done
    
    echo ""
    echo -e "${BLUE}=== RESUMO DA ANÁLISE ===${NC}"
    echo "Total de IPs analisados: ${#ips[@]}"
    echo "Ameaças detectadas: $total_threats"
    
    if [[ $total_threats -gt 0 ]]; then
        echo -e "${RED}⚠ ATENÇÃO: Ameaças encontradas!${NC}"
        return 1
    else
        echo -e "${GREEN}✓ Todos os IPs estão limpos${NC}"
        return 0
    fi
}

# Função principal para uso standalone
main() {
    if [[ $# -eq 0 ]]; then
        echo "Uso: $0 <IP1> [IP2] [IP3] ..."
        echo ""
        echo "Exemplos:"
        echo "  $0 184.107.85.10"
        echo "  $0 8.8.8.8 1.1.1.1"
        echo "  $0 \$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' arquivo.txt)"
        exit 1
    fi
    
    echo -e "${CYAN}=== IP REPUTATION CHECKER ===${NC}"
    echo -e "${PURPLE}Verificador Avançado de Reputação de IPs${NC}"
    echo ""
    
    check_multiple_ips "$@"
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# Exportar funções para uso em outros scripts
export -f check_ip_reputation
export -f check_malicious_ip_patterns
export -f check_suspicious_geolocation
export -f check_multiple_ips
