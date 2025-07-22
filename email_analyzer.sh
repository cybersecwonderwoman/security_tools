#!/bin/bash

# ========================================
# Email Analyzer - Módulo Especializado em Análise de Emails
# ========================================

source "$(dirname "$0")/config.sh"

# Função para extrair IPs de cabeçalhos
extract_ips_from_headers() {
    local header_file="$1"
    
    echo -e "${BLUE}[Email Analyzer] Extraindo IPs dos cabeçalhos${NC}"
    
    # Extrair IPs dos cabeçalhos Received
    grep -i "^Received:" "$header_file" | \
    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | \
    sort -u | \
    while read -r ip; do
        # Filtrar IPs privados
        if [[ ! "$ip" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
            echo "  IP público encontrado: $ip"
            
            # Consultar Shodan se API key disponível
            if [[ -n "$SHODAN_API_KEY" ]]; then
                local shodan_response
                shodan_response=$(curl -s "https://api.shodan.io/shodan/host/$ip?key=$SHODAN_API_KEY")
                
                if echo "$shodan_response" | jq -e '.country_name' > /dev/null 2>&1; then
                    local country org
                    country=$(echo "$shodan_response" | jq -r '.country_name // "N/A"')
                    org=$(echo "$shodan_response" | jq -r '.org // "N/A"')
                    echo "    País: $country | Organização: $org"
                fi
            fi
            
            # Verificar se IP está em blacklists conhecidas
            check_ip_blacklists "$ip"
        fi
    done
}

# Função para verificar IPs em blacklists
check_ip_blacklists() {
    local ip="$1"
    
    # Lista de RBLs para verificar
    local rbls=(
        "zen.spamhaus.org"
        "bl.spamcop.net"
        "b.barracudacentral.org"
        "dnsbl.sorbs.net"
    )
    
    echo "    Verificando blacklists para $ip:"
    
    for rbl in "${rbls[@]}"; do
        # Reverter IP para consulta DNS
        local reversed_ip
        reversed_ip=$(echo "$ip" | awk -F. '{print $4"."$3"."$2"."$1}')
        
        # Consultar RBL
        if dig +short "$reversed_ip.$rbl" | grep -q "127.0.0"; then
            echo -e "      ${RED}✗ Listado em $rbl${NC}"
        else
            echo -e "      ${GREEN}✓ Limpo em $rbl${NC}"
        fi
    done
}

# Função para analisar SPF, DKIM e DMARC
analyze_email_authentication() {
    local header_file="$1"
    
    echo -e "${BLUE}[Email Analyzer] Verificando autenticação de email${NC}"
    
    # Verificar SPF
    if grep -qi "Received-SPF:" "$header_file"; then
        local spf_result
        spf_result=$(grep -i "Received-SPF:" "$header_file" | head -1 | cut -d' ' -f2)
        case "$spf_result" in
            "pass") echo -e "  SPF: ${GREEN}PASS${NC}" ;;
            "fail") echo -e "  SPF: ${RED}FAIL${NC}" ;;
            "softfail") echo -e "  SPF: ${YELLOW}SOFTFAIL${NC}" ;;
            *) echo -e "  SPF: ${YELLOW}$spf_result${NC}" ;;
        esac
    else
        echo -e "  SPF: ${YELLOW}Não encontrado${NC}"
    fi
    
    # Verificar DKIM
    if grep -qi "DKIM-Signature:" "$header_file"; then
        echo -e "  DKIM: ${GREEN}Presente${NC}"
        
        # Extrair domínio do DKIM
        local dkim_domain
        dkim_domain=$(grep -i "DKIM-Signature:" "$header_file" | grep -o "d=[^;]*" | cut -d'=' -f2)
        if [[ -n "$dkim_domain" ]]; then
            echo "    Domínio DKIM: $dkim_domain"
        fi
    else
        echo -e "  DKIM: ${RED}Ausente${NC}"
    fi
    
    # Verificar DMARC
    if grep -qi "Authentication-Results:" "$header_file"; then
        if grep -qi "dmarc=pass" "$header_file"; then
            echo -e "  DMARC: ${GREEN}PASS${NC}"
        elif grep -qi "dmarc=fail" "$header_file"; then
            echo -e "  DMARC: ${RED}FAIL${NC}"
        else
            echo -e "  DMARC: ${YELLOW}Verificação inconclusiva${NC}"
        fi
    else
        echo -e "  DMARC: ${YELLOW}Não encontrado${NC}"
    fi
}

# Função para detectar possíveis indicadores de phishing
detect_phishing_indicators() {
    local header_file="$1"
    
    echo -e "${BLUE}[Email Analyzer] Detectando indicadores de phishing${NC}"
    
    local indicators_found=0
    
    # Verificar discrepâncias no From
    local from_header display_name email_addr
    from_header=$(grep -i "^From:" "$header_file" | head -1)
    
    if [[ "$from_header" =~ \<([^>]+)\> ]]; then
        email_addr="${BASH_REMATCH[1]}"
        display_name=$(echo "$from_header" | sed 's/<[^>]*>//' | sed 's/From: *//')
        
        # Verificar se o nome de exibição contém domínios suspeitos
        if echo "$display_name" | grep -qiE "(paypal|amazon|microsoft|google|apple|bank)" && \
           ! echo "$email_addr" | grep -qiE "(paypal\.com|amazon\.com|microsoft\.com|google\.com|apple\.com)"; then
            echo -e "  ${RED}⚠ Possível spoofing de marca conhecida${NC}"
            echo "    Display Name: $display_name"
            echo "    Email Real: $email_addr"
            ((indicators_found++))
        fi
    fi
    
    # Verificar Return-Path vs From
    local return_path from_domain return_domain
    return_path=$(grep -i "^Return-Path:" "$header_file" | head -1 | grep -o "<[^>]*>" | tr -d '<>')
    from_domain=$(echo "$email_addr" | cut -d'@' -f2)
    return_domain=$(echo "$return_path" | cut -d'@' -f2)
    
    if [[ -n "$return_domain" && -n "$from_domain" && "$return_domain" != "$from_domain" ]]; then
        echo -e "  ${YELLOW}⚠ Return-Path difere do From${NC}"
        echo "    From: $from_domain"
        echo "    Return-Path: $return_domain"
        ((indicators_found++))
    fi
    
    # Verificar múltiplos redirecionamentos
    local received_count
    received_count=$(grep -c "^Received:" "$header_file")
    
    if [[ $received_count -gt 8 ]]; then
        echo -e "  ${YELLOW}⚠ Muitos hops de email ($received_count)${NC}"
        ((indicators_found++))
    fi
    
    # Verificar cabeçalhos suspeitos
    if grep -qi "X-Mailer.*mass" "$header_file" || grep -qi "X-Mailer.*bulk" "$header_file"; then
        echo -e "  ${RED}⚠ Possível email em massa detectado${NC}"
        ((indicators_found++))
    fi
    
    if [[ $indicators_found -eq 0 ]]; then
        echo -e "  ${GREEN}Nenhum indicador óbvio de phishing encontrado${NC}"
    else
        echo -e "  ${RED}Total de indicadores suspeitos: $indicators_found${NC}"
    fi
}

# Função para análise completa de cabeçalho
analyze_email_header_complete() {
    local header_file="$1"
    
    if [[ ! -f "$header_file" ]]; then
        echo -e "${RED}Arquivo de cabeçalho não encontrado: $header_file${NC}"
        return 1
    fi
    
    echo -e "${PURPLE}=== ANÁLISE COMPLETA DE CABEÇALHO DE EMAIL ===${NC}"
    echo "Arquivo: $header_file"
    echo ""
    
    # Informações básicas
    echo -e "${BLUE}[Informações Básicas]${NC}"
    echo "From: $(grep -i "^From:" "$header_file" | head -1 | cut -d' ' -f2-)"
    echo "To: $(grep -i "^To:" "$header_file" | head -1 | cut -d' ' -f2-)"
    echo "Subject: $(grep -i "^Subject:" "$header_file" | head -1 | cut -d' ' -f2-)"
    echo "Date: $(grep -i "^Date:" "$header_file" | head -1 | cut -d' ' -f2-)"
    echo ""
    
    # Análise de autenticação
    analyze_email_authentication "$header_file"
    echo ""
    
    # Extrair e analisar IPs
    extract_ips_from_headers "$header_file"
    echo ""
    
    # Detectar indicadores de phishing
    detect_phishing_indicators "$header_file"
    echo ""
    
    # Caminho do email
    echo -e "${BLUE}[Caminho do Email]${NC}"
    grep -i "^Received:" "$header_file" | nl -v0 | while read -r num line; do
        echo "  $num: $(echo "$line" | cut -c1-80)..."
    done
    
    log_message "Cabeçalho de email analisado: $header_file"
}

# Exportar funções
export -f extract_ips_from_headers
export -f check_ip_blacklists
export -f analyze_email_authentication
export -f detect_phishing_indicators
export -f analyze_email_header_complete
