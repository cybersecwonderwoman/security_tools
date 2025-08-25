#!/bin/bash

# ========================================
# Advanced URL Analyzer
# Análise completa de URLs com verificação de segurança
# ========================================

# Carregar dependências
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.conf"
source "$SCRIPT_DIR/../utils/security.sh"
source "$SCRIPT_DIR/../utils/logger.sh"
source "$SCRIPT_DIR/../modules/api_manager.sh"

# Domínios maliciosos conhecidos (lista simplificada)
declare -A MALICIOUS_DOMAINS=(
    ["malware.com"]="Domínio de malware conhecido"
    ["phishing-site.net"]="Site de phishing"
    ["suspicious-domain.org"]="Domínio suspeito"
)

# TLDs suspeitos
SUSPICIOUS_TLDS=("tk" "ml" "ga" "cf" "pw" "top" "click" "download")

# Analisar URL completa
analyze_url() {
    local url="$1"
    local start_time=$(date +%s)
    
    log_info "Iniciando análise de URL: $url" "URL_ANALYZER"
    
    # Validações iniciais
    if ! validate_input "$url" "url"; then
        log_error "URL inválida: $url" "URL_ANALYZER"
        return 1
    fi
    
    if ! is_url_safe "$url"; then
        log_error "URL não é segura para análise: $url" "URL_ANALYZER"
        return 1
    fi
    
    # Inicializar resultado da análise
    local analysis_result=""
    analysis_result+="🌐 ANÁLISE AVANÇADA DE URL\n"
    analysis_result+="==========================\n\n"
    
    # 1. Análise da estrutura da URL
    analysis_result+="$(analyze_url_structure "$url")\n\n"
    
    # 2. Análise do domínio
    analysis_result+="$(analyze_domain_info "$url")\n\n"
    
    # 3. Verificação de conectividade
    analysis_result+="$(check_url_connectivity "$url")\n\n"
    
    # 4. Análise de cabeçalhos HTTP
    analysis_result+="$(analyze_http_headers "$url")\n\n"
    
    # 5. Verificação de certificado SSL
    analysis_result+="$(check_ssl_certificate "$url")\n\n"
    
    # 6. Análise de conteúdo
    analysis_result+="$(analyze_url_content "$url")\n\n"
    
    # 7. Verificação em blacklists
    analysis_result+="$(check_url_blacklists "$url")\n\n"
    
    # 8. Verificação em APIs externas
    analysis_result+="$(check_external_url_apis "$url")\n\n"
    
    # 9. Análise de risco
    local risk_level=$(calculate_url_risk "$url")
    analysis_result+="$(generate_url_risk_assessment "$risk_level")\n\n"
    
    # 10. Recomendações
    analysis_result+="$(generate_url_recommendations "$risk_level")\n\n"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    analysis_result+="Análise concluída em ${duration}s - $(date '+%Y-%m-%d %H:%M:%S')\n"
    
    # Log da análise
    log_analysis "URL" "$url" "$risk_level" "$duration"
    
    echo -e "$analysis_result"
    return 0
}

# Analisar estrutura da URL
analyze_url_structure() {
    local url="$1"
    local result=""
    
    result+="[🔍 Estrutura da URL]\n"
    result+="URL: $url\n"
    
    # Extrair componentes da URL
    local protocol=$(echo "$url" | sed -n 's|^\([^:]*\)://.*|\1|p')
    local domain=$(echo "$url" | sed -n 's|^[^:]*://\([^/]*\).*|\1|p')
    local path=$(echo "$url" | sed -n 's|^[^:]*://[^/]*\(.*\)|\1|p')
    
    result+="Protocolo: $protocol\n"
    result+="Domínio: $domain\n"
    result+="Caminho: ${path:-/}\n"
    
    # Verificar protocolo seguro
    if [[ "$protocol" == "https" ]]; then
        result+="✅ Protocolo seguro (HTTPS)\n"
    else
        result+="⚠️  Protocolo inseguro (HTTP)\n"
    fi
    
    # Verificar TLD suspeito
    local tld=$(echo "$domain" | sed -n 's|.*\.||p')
    for suspicious_tld in "${SUSPICIOUS_TLDS[@]}"; do
        if [[ "$tld" == "$suspicious_tld" ]]; then
            result+="⚠️  TLD suspeito: .$tld\n"
            break
        fi
    done
    
    # Verificar caracteres suspeitos
    if [[ "$url" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
        result+="⚠️  URL usa endereço IP em vez de domínio\n"
    fi
    
    if [[ "$url" =~ %[0-9a-fA-F]{2} ]]; then
        result+="⚠️  URL contém caracteres codificados\n"
    fi
    
    # Verificar comprimento suspeito
    if [[ ${#url} -gt 200 ]]; then
        result+="⚠️  URL muito longa (${#url} caracteres)\n"
    fi
    
    echo -e "$result"
}

# Analisar informações do domínio
analyze_domain_info() {
    local url="$1"
    local domain=$(echo "$url" | sed -n 's|^[^:]*://\([^/]*\).*|\1|p')
    local result=""
    
    result+="[🏠 Informações do Domínio]\n"
    result+="Domínio: $domain\n"
    
    # Verificar se domínio está na lista de maliciosos
    if [[ -n "${MALICIOUS_DOMAINS[$domain]}" ]]; then
        result+="🚨 DOMÍNIO MALICIOSO: ${MALICIOUS_DOMAINS[$domain]}\n"
    fi
    
    # Resolução DNS
    if command -v dig &>/dev/null; then
        local ip_address=$(dig +short "$domain" 2>/dev/null | head -1)
        if [[ -n "$ip_address" ]]; then
            result+="Endereço IP: $ip_address\n"
            
            # Verificar geolocalização se possível
            if command -v geoiplookup &>/dev/null; then
                local geo_info=$(geoiplookup "$ip_address" 2>/dev/null)
                [[ -n "$geo_info" ]] && result+="Localização: $geo_info\n"
            fi
        else
            result+="⚠️  Falha na resolução DNS\n"
        fi
    fi
    
    # Verificar WHOIS se disponível
    if command -v whois &>/dev/null; then
        local whois_info=$(timeout 10 whois "$domain" 2>/dev/null | grep -i -E "(creation|created|registered)" | head -1)
        [[ -n "$whois_info" ]] && result+="Registro: $whois_info\n"
    fi
    
    echo -e "$result"
}

# Verificar conectividade da URL
check_url_connectivity() {
    local url="$1"
    local result=""
    
    result+="[🔗 Teste de Conectividade]\n"
    
    # Teste básico de conectividade
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout $CONNECTION_TIMEOUT "$url" 2>/dev/null)
    
    if [[ -n "$http_code" ]]; then
        result+="Código HTTP: $http_code\n"
        
        case "$http_code" in
            200)
                result+="✅ Site acessível\n"
                ;;
            301|302|303|307|308)
                result+="🔄 Redirecionamento detectado\n"
                local redirect_url=$(curl -s -I --connect-timeout $CONNECTION_TIMEOUT "$url" | grep -i "location:" | cut -d' ' -f2- | tr -d '\r')
                [[ -n "$redirect_url" ]] && result+="Redirecionado para: $redirect_url\n"
                ;;
            404)
                result+="❌ Página não encontrada\n"
                ;;
            403)
                result+="🚫 Acesso negado\n"
                ;;
            500|502|503|504)
                result+="⚠️  Erro do servidor\n"
                ;;
            *)
                result+="⚠️  Resposta inesperada\n"
                ;;
        esac
    else
        result+="❌ Falha na conexão\n"
    fi
    
    # Teste de tempo de resposta
    local response_time=$(curl -s -o /dev/null -w "%{time_total}" --connect-timeout $CONNECTION_TIMEOUT "$url" 2>/dev/null)
    if [[ -n "$response_time" ]]; then
        result+="Tempo de resposta: ${response_time}s\n"
        
        # Avaliar tempo de resposta
        if (( $(echo "$response_time > 5.0" | bc -l 2>/dev/null || echo "0") )); then
            result+="⚠️  Tempo de resposta lento\n"
        fi
    fi
    
    echo -e "$result"
}

# Analisar cabeçalhos HTTP
analyze_http_headers() {
    local url="$1"
    local result=""
    
    result+="[📋 Cabeçalhos HTTP]\n"
    
    # Obter cabeçalhos
    local headers=$(curl -s -I --connect-timeout $CONNECTION_TIMEOUT "$url" 2>/dev/null)
    
    if [[ -n "$headers" ]]; then
        # Verificar cabeçalhos de segurança importantes
        local security_headers=(
            "Strict-Transport-Security"
            "Content-Security-Policy"
            "X-Frame-Options"
            "X-Content-Type-Options"
            "X-XSS-Protection"
        )
        
        local security_score=0
        for header in "${security_headers[@]}"; do
            if echo "$headers" | grep -qi "$header"; then
                result+="✅ $header presente\n"
                security_score=$((security_score + 1))
            else
                result+="❌ $header ausente\n"
            fi
        done
        
        result+="Pontuação de segurança: $security_score/5\n"
        
        # Verificar servidor
        local server=$(echo "$headers" | grep -i "server:" | cut -d' ' -f2- | tr -d '\r')
        [[ -n "$server" ]] && result+="Servidor: $server\n"
        
        # Verificar cookies
        local cookies=$(echo "$headers" | grep -i "set-cookie" | wc -l)
        [[ $cookies -gt 0 ]] && result+="Cookies definidos: $cookies\n"
        
    else
        result+="❌ Não foi possível obter cabeçalhos\n"
    fi
    
    echo -e "$result"
}

# Verificar certificado SSL
check_ssl_certificate() {
    local url="$1"
    local result=""
    
    # Verificar apenas URLs HTTPS
    if [[ "$url" != https://* ]]; then
        result+="[🔒 Certificado SSL]\n"
        result+="N/A - URL não usa HTTPS\n"
        echo -e "$result"
        return
    fi
    
    result+="[🔒 Certificado SSL]\n"
    
    local domain=$(echo "$url" | sed -n 's|^https://\([^/]*\).*|\1|p')
    
    # Verificar certificado
    local cert_info=$(timeout 10 openssl s_client -connect "$domain:443" -servername "$domain" </dev/null 2>/dev/null | openssl x509 -noout -text 2>/dev/null)
    
    if [[ -n "$cert_info" ]]; then
        # Extrair informações do certificado
        local issuer=$(echo "$cert_info" | grep "Issuer:" | cut -d':' -f2- | xargs)
        local subject=$(echo "$cert_info" | grep "Subject:" | cut -d':' -f2- | xargs)
        local not_after=$(echo "$cert_info" | grep "Not After" | cut -d':' -f2- | xargs)
        
        result+="✅ Certificado SSL válido\n"
        [[ -n "$issuer" ]] && result+="Emissor: $issuer\n"
        [[ -n "$subject" ]] && result+="Sujeito: $subject\n"
        [[ -n "$not_after" ]] && result+="Válido até: $not_after\n"
        
        # Verificar se o certificado está próximo do vencimento
        if command -v date &>/dev/null; then
            local expiry_date=$(echo "$not_after" | xargs -I {} date -d "{}" +%s 2>/dev/null)
            local current_date=$(date +%s)
            local days_until_expiry=$(( (expiry_date - current_date) / 86400 ))
            
            if [[ $days_until_expiry -lt 30 ]]; then
                result+="⚠️  Certificado expira em $days_until_expiry dias\n"
            fi
        fi
    else
        result+="❌ Certificado SSL inválido ou inacessível\n"
    fi
    
    echo -e "$result"
}

# Analisar conteúdo da URL
analyze_url_content() {
    local url="$1"
    local result=""
    
    result+="[📄 Análise de Conteúdo]\n"
    
    # Obter conteúdo (limitado)
    local content=$(curl -s -L --max-filesize 1048576 --connect-timeout $CONNECTION_TIMEOUT "$url" 2>/dev/null | head -c 10000)
    
    if [[ -n "$content" ]]; then
        # Verificar tipo de conteúdo
        if echo "$content" | grep -qi "<!DOCTYPE html\|<html"; then
            result+="Tipo: Página HTML\n"
            
            # Extrair título
            local title=$(echo "$content" | grep -i "<title>" | sed 's|.*<title>\(.*\)</title>.*|\1|i' | head -1)
            [[ -n "$title" ]] && result+="Título: $title\n"
            
            # Verificar padrões suspeitos
            local suspicious_patterns=0
            
            # Verificar JavaScript suspeito
            if echo "$content" | grep -qi "eval\|unescape\|fromCharCode"; then
                result+="⚠️  JavaScript ofuscado detectado\n"
                suspicious_patterns=$((suspicious_patterns + 1))
            fi
            
            # Verificar formulários de login
            if echo "$content" | grep -qi "password\|login"; then
                result+="🔐 Formulário de login detectado\n"
            fi
            
            # Verificar iframes suspeitos
            if echo "$content" | grep -qi "<iframe"; then
                result+="⚠️  iframes detectados\n"
                suspicious_patterns=$((suspicious_patterns + 1))
            fi
            
            # Verificar redirecionamentos JavaScript
            if echo "$content" | grep -qi "window.location\|document.location"; then
                result+="⚠️  Redirecionamento JavaScript detectado\n"
                suspicious_patterns=$((suspicious_patterns + 1))
            fi
            
            result+="Padrões suspeitos: $suspicious_patterns\n"
            
        else
            result+="Tipo: Conteúdo não-HTML\n"
        fi
        
        # Verificar tamanho do conteúdo
        local content_size=${#content}
        result+="Tamanho analisado: $content_size bytes\n"
        
    else
        result+="❌ Não foi possível obter conteúdo\n"
    fi
    
    echo -e "$result"
}

# Verificar URL em blacklists
check_url_blacklists() {
    local url="$1"
    local domain=$(echo "$url" | sed -n 's|^[^:]*://\([^/]*\).*|\1|p')
    local result=""
    
    result+="[🚫 Verificação em Blacklists]\n"
    
    # Verificar em lista local de domínios maliciosos
    if [[ -n "${MALICIOUS_DOMAINS[$domain]}" ]]; then
        result+="🚨 Encontrado em blacklist local: ${MALICIOUS_DOMAINS[$domain]}\n"
    else
        result+="✅ Não encontrado em blacklist local\n"
    fi
    
    # Verificar em Google Safe Browsing (simulado)
    result+="Google Safe Browsing: Verificação não implementada\n"
    
    echo -e "$result"
}

# Verificar em APIs externas
check_external_url_apis() {
    local url="$1"
    local result=""
    
    result+="[🌐 Verificação Externa]\n"
    
    # VirusTotal
    if is_api_configured "virustotal"; then
        result+="$(check_virustotal_url "$url")\n"
    else
        result+="VirusTotal: API não configurada\n"
    fi
    
    # URLScan.io
    if is_api_configured "urlscan"; then
        result+="$(check_urlscan_url "$url")\n"
    else
        result+="URLScan.io: API não configurada\n"
    fi
    
    echo -e "$result"
}

# Verificar URL no VirusTotal
check_virustotal_url() {
    local url="$1"
    local url_id=$(echo -n "$url" | base64 -w 0 | tr '+/' '-_' | tr -d '=')
    
    local response=$(make_api_request "virustotal" "$VIRUSTOTAL_API_URL/urls/$url_id")
    
    if [[ -n "$response" ]]; then
        local malicious=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.malicious // 0' 2>/dev/null)
        local suspicious=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.suspicious // 0' 2>/dev/null)
        local total=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats | add // 0' 2>/dev/null)
        
        if [[ "$malicious" != "null" && "$malicious" != "0" ]]; then
            echo "🚨 VirusTotal: $malicious/$total engines detectaram como malicioso"
        elif [[ "$suspicious" != "null" && "$suspicious" != "0" ]]; then
            echo "⚠️  VirusTotal: $suspicious/$total engines marcaram como suspeito"
        else
            echo "✅ VirusTotal: URL limpa (0/$total detecções)"
        fi
    else
        echo "VirusTotal: URL não encontrada na base de dados"
    fi
}

# Verificar URL no URLScan.io
check_urlscan_url() {
    local url="$1"
    
    # Submeter URL para análise
    local submit_response=$(make_api_request "urlscan" "$URLSCAN_API_URL/scan/" "POST" "{\"url\":\"$url\"}")
    
    if [[ -n "$submit_response" ]]; then
        local scan_id=$(echo "$submit_response" | jq -r '.uuid // empty' 2>/dev/null)
        
        if [[ -n "$scan_id" ]]; then
            echo "URLScan.io: Análise iniciada (ID: $scan_id)"
        else
            echo "URLScan.io: Erro ao submeter URL"
        fi
    else
        echo "URLScan.io: Falha na comunicação"
    fi
}

# Calcular nível de risco da URL
calculate_url_risk() {
    local url="$1"
    local domain=$(echo "$url" | sed -n 's|^[^:]*://\([^/]*\).*|\1|p')
    local risk_score=0
    
    # Verificar protocolo
    [[ "$url" != https://* ]] && risk_score=$((risk_score + 20))
    
    # Verificar domínio malicioso conhecido
    [[ -n "${MALICIOUS_DOMAINS[$domain]}" ]] && risk_score=$((risk_score + 50))
    
    # Verificar TLD suspeito
    local tld=$(echo "$domain" | sed -n 's|.*\.||p')
    for suspicious_tld in "${SUSPICIOUS_TLDS[@]}"; do
        [[ "$tld" == "$suspicious_tld" ]] && risk_score=$((risk_score + 15)) && break
    done
    
    # Verificar IP em vez de domínio
    [[ "$url" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] && risk_score=$((risk_score + 25))
    
    # Verificar URL muito longa
    [[ ${#url} -gt 200 ]] && risk_score=$((risk_score + 10))
    
    # Determinar nível baseado na pontuação
    if [[ $risk_score -ge 50 ]]; then
        echo "ALTO"
    elif [[ $risk_score -ge 25 ]]; then
        echo "MÉDIO"
    else
        echo "BAIXO"
    fi
}

# Gerar avaliação de risco da URL
generate_url_risk_assessment() {
    local risk_level="$1"
    local result=""
    
    result+="[⚖️  Avaliação de Risco]\n"
    
    case "$risk_level" in
        "ALTO")
            result+="🔴 RISCO ALTO - URL potencialmente perigosa\n"
            result+="   Recomendação: NÃO ACESSAR\n"
            ;;
        "MÉDIO")
            result+="🟡 RISCO MÉDIO - URL requer atenção\n"
            result+="   Recomendação: Acessar com cuidado\n"
            ;;
        "BAIXO")
            result+="🟢 RISCO BAIXO - URL aparentemente segura\n"
            result+="   Recomendação: Verificação adicional recomendada\n"
            ;;
    esac
    
    echo -e "$result"
}

# Gerar recomendações específicas para URL
generate_url_recommendations() {
    local risk_level="$1"
    local result=""
    
    result+="[💡 Recomendações]\n"
    
    case "$risk_level" in
        "ALTO")
            result+="• NÃO acesse esta URL\n"
            result+="• Bloqueie o domínio em seu firewall\n"
            result+="• Relate como site malicioso\n"
            result+="• Verifique se outros dispositivos acessaram\n"
            ;;
        "MÉDIO")
            result+="• Use navegador com proteção ativa\n"
            result+="• Não insira informações pessoais\n"
            result+="• Verifique certificado SSL\n"
            result+="• Monitore atividade de rede\n"
            ;;
        "BAIXO")
            result+="• Mantenha navegador atualizado\n"
            result+="• Verifique HTTPS quando possível\n"
            result+="• Use extensões de segurança\n"
            result+="• Monitore downloads automáticos\n"
            ;;
    esac
    
    echo -e "$result"
}
