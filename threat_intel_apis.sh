#!/bin/bash

# ========================================
# Threat Intelligence APIs - Módulo de APIs de Threat Intelligence
# Funções específicas para integração com múltiplas fontes
# ========================================

# Configurações
source "$(dirname "$0")/config.sh" 2>/dev/null || true

# Função para consulta ThreatFox (Abuse.ch)
query_threatfox() {
    local ioc="$1"
    local ioc_type="$2"  # hash, domain, ip, url
    
    echo -e "${BLUE}[ThreatFox] Consultando IOC: $ioc${NC}"
    
    local response
    response=$(curl -s -X POST "https://threatfox-api.abuse.ch/api/v1/" \
        -H "Content-Type: application/json" \
        -d "{\"query\":\"search_ioc\",\"search_term\":\"$ioc\"}")
    
    if echo "$response" | jq -e '.query_status == "ok"' > /dev/null 2>&1; then
        local data
        data=$(echo "$response" | jq -r '.data[]?')
        
        if [[ -n "$data" ]]; then
            echo -e "${RED}[ThreatFox] IOC MALICIOSO ENCONTRADO!${NC}"
            echo "$response" | jq -r '.data[] | "  Malware: \(.malware_printable) | Confiança: \(.confidence_level)% | Tags: \(.tags | join(", "))"'
            return 0
        else
            echo -e "${GREEN}[ThreatFox] IOC não encontrado na base${NC}"
        fi
    else
        echo -e "${YELLOW}[ThreatFox] Erro na consulta${NC}"
    fi
}

# Função para consulta AlienVault OTX
query_alienvault_otx() {
    local indicator="$1"
    local indicator_type="$2"  # IPv4, domain, hostname, url, FileHash-MD5, FileHash-SHA1, FileHash-SHA256
    
    echo -e "${BLUE}[AlienVault OTX] Consultando: $indicator${NC}"
    
    local endpoint
    case "$indicator_type" in
        "IPv4") endpoint="indicators/IPv4/$indicator/general" ;;
        "domain"|"hostname") endpoint="indicators/domain/$indicator/general" ;;
        "url") endpoint="indicators/url/$(echo -n "$indicator" | base64 -w 0)/general" ;;
        "FileHash-"*) endpoint="indicators/file/$indicator/general" ;;
        *) echo -e "${YELLOW}[AlienVault OTX] Tipo de indicador não suportado${NC}"; return 1 ;;
    esac
    
    local response
    response=$(curl -s "https://otx.alienvault.com/api/v1/$endpoint")
    
    if echo "$response" | jq -e '.pulse_info' > /dev/null 2>&1; then
        local pulse_count
        pulse_count=$(echo "$response" | jq -r '.pulse_info.count // 0')
        
        if [[ $pulse_count -gt 0 ]]; then
            echo -e "${RED}[AlienVault OTX] INDICADOR MALICIOSO! ($pulse_count pulses)${NC}"
            echo "$response" | jq -r '.pulse_info.pulses[0:3][] | "  Pulse: \(.name) | Criado: \(.created)"'
            return 0
        else
            echo -e "${GREEN}[AlienVault OTX] Indicador limpo${NC}"
        fi
    else
        echo -e "${YELLOW}[AlienVault OTX] Erro na consulta ou indicador não encontrado${NC}"
    fi
}

# Função para consulta Hybrid Analysis
query_hybrid_analysis() {
    local hash="$1"
    
    if [[ -z "$HYBRID_ANALYSIS_API_KEY" ]]; then
        echo -e "${YELLOW}[Hybrid Analysis] API Key não configurada${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[Hybrid Analysis] Analisando hash: $hash${NC}"
    
    local response
    response=$(curl -s -H "api-key: $HYBRID_ANALYSIS_API_KEY" \
        -H "user-agent: Falcon Sandbox" \
        "https://www.hybrid-analysis.com/api/v2/search/hash" \
        -d "hash=$hash")
    
    if echo "$response" | jq -e '.[0]' > /dev/null 2>&1; then
        local verdict
        verdict=$(echo "$response" | jq -r '.[0].verdict // "unknown"')
        
        case "$verdict" in
            "malicious")
                echo -e "${RED}[Hybrid Analysis] ARQUIVO MALICIOSO!${NC}"
                echo "$response" | jq -r '.[0] | "  Threat Score: \(.threat_score)/100 | Ambiente: \(.environment_description)"'
                return 0
                ;;
            "suspicious")
                echo -e "${YELLOW}[Hybrid Analysis] Arquivo suspeito${NC}"
                echo "$response" | jq -r '.[0] | "  Threat Score: \(.threat_score)/100 | Ambiente: \(.environment_description)"'
                ;;
            *)
                echo -e "${GREEN}[Hybrid Analysis] Arquivo aparenta ser limpo${NC}"
                ;;
        esac
    else
        echo -e "${YELLOW}[Hybrid Analysis] Hash não encontrado na base${NC}"
    fi
}

# Função para consulta Joe Sandbox (versão pública limitada)
query_joe_sandbox() {
    local hash="$1"
    
    echo -e "${BLUE}[Joe Sandbox] Consultando hash: $hash${NC}"
    
    # Joe Sandbox público tem limitações, implementação básica
    local response
    response=$(curl -s "https://jbxcloud.joesecurity.org/api/v2/analysis/search" \
        -F "q=$hash")
    
    if echo "$response" | jq -e '.data' > /dev/null 2>&1; then
        local count
        count=$(echo "$response" | jq -r '.data | length')
        
        if [[ $count -gt 0 ]]; then
            echo "  Encontradas $count análises para este hash"
            echo "$response" | jq -r '.data[0] | "  Score: \(.score) | Detecção: \(.detection)"'
        else
            echo -e "${GREEN}[Joe Sandbox] Hash não encontrado${NC}"
        fi
    else
        echo -e "${YELLOW}[Joe Sandbox] Erro na consulta${NC}"
    fi
}

# Função para consulta MalShare
query_malshare() {
    local hash="$1"
    
    echo -e "${BLUE}[MalShare] Consultando hash: $hash${NC}"
    
    # MalShare API pública (limitada)
    local response
    response=$(curl -s "https://malshare.com/api.php?api_key=public&action=details&hash=$hash")
    
    if [[ "$response" != "Sample not found by hash" ]] && [[ -n "$response" ]]; then
        echo -e "${RED}[MalShare] HASH MALICIOSO ENCONTRADO!${NC}"
        echo "$response" | jq -r '. | "  MD5: \(.MD5) | SHA1: \(.SHA1) | Tipo: \(.F_TYPE)"' 2>/dev/null || echo "  $response"
        return 0
    else
        echo -e "${GREEN}[MalShare] Hash não encontrado${NC}"
    fi
}

# Função para análise completa de hash
analyze_hash_complete() {
    local hash="$1"
    
    echo -e "${PURPLE}=== ANÁLISE COMPLETA DE HASH ===${NC}"
    echo "Hash: $hash"
    
    # Múltiplas consultas
    analyze_hash_virustotal "$hash"
    query_threatfox "$hash" "hash"
    query_alienvault_otx "$hash" "FileHash-SHA256"
    query_hybrid_analysis "$hash"
    query_malshare "$hash"
}

# Função para análise completa de domínio
analyze_domain_complete() {
    local domain="$1"
    
    echo -e "${PURPLE}=== ANÁLISE COMPLETA DE DOMÍNIO ===${NC}"
    echo "Domínio: $domain"
    
    # Análises básicas
    analyze_domain_basic "$domain"
    analyze_domain_shodan "$domain"
    
    # Threat Intelligence
    query_threatfox "$domain" "domain"
    query_alienvault_otx "$domain" "domain"
}

# Função para análise completa de URL
analyze_url_complete() {
    local url="$1"
    
    echo -e "${PURPLE}=== ANÁLISE COMPLETA DE URL ===${NC}"
    echo "URL: $url"
    
    # Extrair domínio
    local domain
    domain=$(echo "$url" | sed -E 's|^https?://([^/]+).*|\1|')
    
    # Análises
    analyze_url_urlscan "$url"
    query_threatfox "$url" "url"
    query_alienvault_otx "$url" "url"
    
    # Analisar domínio também
    analyze_domain_complete "$domain"
}

# Exportar funções
export -f query_threatfox
export -f query_alienvault_otx
export -f query_hybrid_analysis
export -f query_joe_sandbox
export -f query_malshare
export -f analyze_hash_complete
export -f analyze_domain_complete
export -f analyze_url_complete
