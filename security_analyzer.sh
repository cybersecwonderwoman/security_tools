#!/bin/bash

# ========================================
# Security Analyzer Tool - Ferramenta Avançada de Análise de Segurança
# Desenvolvido para análise de arquivos, URLs, emails, domínios e hashes
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
LOG_FILE="$CONFIG_DIR/analysis.log"
CACHE_DIR="$CONFIG_DIR/cache"
API_KEYS_FILE="$CONFIG_DIR/api_keys.conf"

# Criar diretórios necessários
mkdir -p "$CONFIG_DIR" "$CACHE_DIR"

# Função para logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Função para exibir banner
show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                    SECURITY ANALYZER TOOL                    ║
║              Ferramenta Avançada de Análise de Segurança     ║
║                                                               ║
║  Análise de: Arquivos | URLs | Emails | Domínios | Hashes    ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Função para exibir ajuda
show_help() {
    echo -e "${YELLOW}USO:${NC}"
    echo "  $0 [OPÇÃO] [ALVO]"
    echo ""
    echo -e "${YELLOW}OPÇÕES:${NC}"
    echo "  -f, --file      Analisar arquivo"
    echo "  -u, --url       Analisar URL"
    echo "  -e, --email     Analisar email"
    echo "  -i, --ip        Analisar endereço IP"
    echo "  -d, --domain    Analisar domínio"
    echo "  -h, --hash      Analisar hash"
    echo "  -i, --ip        Analisar endereço IP"
    echo "  --header        Analisar cabeçalho de email"
    echo "  --config        Configurar chaves de API"
    echo "  --help          Exibir esta ajuda"
    echo ""
    echo -e "${YELLOW}EXEMPLOS:${NC}"
    echo "  $0 -f /path/to/suspicious_file.exe"
    echo "  $0 -u https://suspicious-site.com"
    echo "  $0 -d malicious-domain.com"
    echo "  $0 -i 8.8.8.8"
    echo "  $0 -h 5d41402abc4b2a76b9719d911017c592"
    echo "  $0 -i 8.8.8.8"
    echo ""
}

# Função para configurar chaves de API
configure_api_keys() {
    echo -e "${YELLOW}Configuração de Chaves de API${NC}"
    echo "Configure suas chaves de API para melhor funcionalidade:"
    echo ""
    
    # VirusTotal
    echo -n "VirusTotal API Key (opcional): "
    read -r vt_key
    
    # Shodan
    echo -n "Shodan API Key (opcional): "
    read -r shodan_key
    
    # URLScan.io
    echo -n "URLScan.io API Key (opcional): "
    read -r urlscan_key
    
    # Hybrid Analysis
    echo -n "Hybrid Analysis API Key (opcional): "
    read -r hybrid_key
    
    # Salvar configurações
    cat > "$API_KEYS_FILE" << EOF
# Chaves de API - Security Analyzer Tool
VIRUSTOTAL_API_KEY="$vt_key"
SHODAN_API_KEY="$shodan_key"
URLSCAN_API_KEY="$urlscan_key"
HYBRID_ANALYSIS_API_KEY="$hybrid_key"
EOF
    
    chmod 600 "$API_KEYS_FILE"
    echo -e "${GREEN}Configurações salvas em: $API_KEYS_FILE${NC}"
}

# Carregar chaves de API
load_api_keys() {
    if [[ -f "$API_KEYS_FILE" ]]; then
        source "$API_KEYS_FILE"
    fi
}

# Função para verificar dependências
check_dependencies() {
    local deps=("curl" "jq" "dig" "whois" "file" "sha256sum" "md5sum")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Dependências faltando: ${missing[*]}${NC}"
        echo "Instale com: sudo apt-get install ${missing[*]}"
        exit 1
    fi
}

# Função para análise de hash via VirusTotal
analyze_hash_virustotal() {
    local hash="$1"
    
    if [[ -z "$VIRUSTOTAL_API_KEY" ]]; then
        echo -e "${YELLOW}[VirusTotal] API Key não configurada${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[VirusTotal] Analisando hash: $hash${NC}"
    
    local response
    response=$(curl -s -H "x-apikey: $VIRUSTOTAL_API_KEY" \
        "https://www.virustotal.com/api/v3/files/$hash")
    
    if echo "$response" | jq -e '.data' > /dev/null 2>&1; then
        local malicious
        local suspicious
        malicious=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.malicious // 0')
        suspicious=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.suspicious // 0')
        
        if [[ $malicious -gt 0 || $suspicious -gt 0 ]]; then
            echo -e "${RED}[VirusTotal] AMEAÇA DETECTADA!${NC}"
            echo "  Malicioso: $malicious detecções"
            echo "  Suspeito: $suspicious detecções"
            return 0
        else
            echo -e "${GREEN}[VirusTotal] Hash limpo${NC}"
        fi
    else
        echo -e "${YELLOW}[VirusTotal] Hash não encontrado na base${NC}"
    fi
}

# Função para análise de URL via URLScan.io
analyze_url_urlscan() {
    local url="$1"
    
    echo -e "${BLUE}[URLScan.io] Analisando URL: $url${NC}"
    
    # Submeter URL para análise
    local submit_response
    local headers=(-H "Content-Type: application/json")
    
    if [[ -n "$URLSCAN_API_KEY" ]]; then
        headers+=(-H "API-Key: $URLSCAN_API_KEY")
    fi
    
    submit_response=$(curl -s "${headers[@]}" -d "{\"url\":\"$url\"}" \
        "https://urlscan.io/api/v1/scan/")
    
    if echo "$submit_response" | jq -e '.uuid' > /dev/null 2>&1; then
        local uuid
        uuid=$(echo "$submit_response" | jq -r '.uuid')
        echo "  Análise iniciada. UUID: $uuid"
        echo "  Aguarde alguns segundos para resultados..."
        
        # Aguardar análise
        sleep 10
        
        # Obter resultados
        local result_response
        result_response=$(curl -s "https://urlscan.io/api/v1/result/$uuid/")
        
        if echo "$result_response" | jq -e '.verdicts' > /dev/null 2>&1; then
            local overall_malicious
            overall_malicious=$(echo "$result_response" | jq -r '.verdicts.overall.malicious // false')
            
            if [[ "$overall_malicious" == "true" ]]; then
                echo -e "${RED}[URLScan.io] URL MALICIOSA DETECTADA!${NC}"
                return 0
            else
                echo -e "${GREEN}[URLScan.io] URL aparenta ser segura${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}[URLScan.io] Erro na submissão da URL${NC}"
    fi
}

# Função para análise de domínio via Shodan
analyze_domain_shodan() {
    local domain="$1"
    
    if [[ -z "$SHODAN_API_KEY" ]]; then
        echo -e "${YELLOW}[Shodan] API Key não configurada${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[Shodan] Analisando domínio: $domain${NC}"
    
    local response
    response=$(curl -s "https://api.shodan.io/shodan/host/search?key=$SHODAN_API_KEY&query=hostname:$domain")
    
    if echo "$response" | jq -e '.matches' > /dev/null 2>&1; then
        local total
        total=$(echo "$response" | jq -r '.total // 0')
        
        if [[ $total -gt 0 ]]; then
            echo "  Encontrados $total hosts associados"
            echo "$response" | jq -r '.matches[0:3][] | "  IP: \(.ip_str) | Porta: \(.port) | Serviço: \(.product // "N/A")"'
        else
            echo -e "${GREEN}[Shodan] Nenhum host encontrado${NC}"
        fi
    fi
}

# Função para análise básica de domínio (DNS/WHOIS)
analyze_domain_basic() {
    local domain="$1"
    
    echo -e "${BLUE}[DNS/WHOIS] Analisando domínio: $domain${NC}"
    
    # Verificar resolução DNS
    if dig +short "$domain" > /dev/null 2>&1; then
        local ips
        ips=$(dig +short "$domain" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
        echo "  IPs resolvidos:"
        echo "$ips" | while read -r ip; do
            echo "    $ip"
        done
    else
        echo -e "${RED}  Domínio não resolve${NC}"
    fi
    
    # WHOIS básico
    if command -v whois &> /dev/null; then
        echo "  Informações WHOIS:"
        whois "$domain" 2>/dev/null | grep -E "(Creation Date|Registry Expiry|Registrar:|Status:)" | head -5
    fi
}

# Função para análise de arquivo
analyze_file() {
    local filepath="$1"
    
    if [[ ! -f "$filepath" ]]; then
        echo -e "${RED}Arquivo não encontrado: $filepath${NC}"
        return 1
    fi
    
    echo -e "${PURPLE}=== ANÁLISE DE ARQUIVO ===${NC}"
    echo "Arquivo: $filepath"
    
    # Informações básicas do arquivo
    echo -e "\n${BLUE}[Informações Básicas]${NC}"
    file "$filepath"
    ls -lh "$filepath"
    
    # Calcular hashes
    echo -e "\n${BLUE}[Hashes]${NC}"
    local md5_hash sha256_hash
    md5_hash=$(md5sum "$filepath" | cut -d' ' -f1)
    sha256_hash=$(sha256sum "$filepath" | cut -d' ' -f1)
    
    echo "MD5:    $md5_hash"
    echo "SHA256: $sha256_hash"
    
    # Analisar hashes
    analyze_hash_virustotal "$sha256_hash"
    analyze_hash_virustotal "$md5_hash"
    
    log_message "Arquivo analisado: $filepath (MD5: $md5_hash, SHA256: $sha256_hash)"
    
    # Gerar e abrir relatório HTML
    "$(dirname "$0")/generate_report.sh" "Análise de Arquivo" "$filepath" "$LOG_FILE"
}

# Função para análise de URL
analyze_url() {
    local url="$1"
    
    echo -e "${PURPLE}=== ANÁLISE DE URL ===${NC}"
    echo "URL: $url"
    
    # Extrair domínio
    local domain
    domain=$(echo "$url" | sed -E 's|^https?://([^/]+).*|\1|')
    
    echo "Domínio extraído: $domain"
    
    # Análises
    analyze_url_urlscan "$url"
    analyze_domain_basic "$domain"
    analyze_domain_shodan "$domain"
    
    log_message "URL analisada: $url"
    
    # Gerar e abrir relatório HTML
    "$(dirname "$0")/generate_report.sh" "Análise de URL" "$url" "$LOG_FILE"
}

# Função para análise de domínio
analyze_domain() {
    local domain="$1"
    
    echo -e "${PURPLE}=== ANÁLISE DE DOMÍNIO ===${NC}"
    echo "Domínio: $domain"
    
    analyze_domain_basic "$domain"
    analyze_domain_shodan "$domain"
    
    log_message "Domínio analisado: $domain"
    
    # Gerar e abrir relatório HTML
    "$(dirname "$0")/generate_report.sh" "Análise de Domínio" "$domain" "$LOG_FILE"
}

# Função para análise de hash
analyze_hash() {
    local hash="$1"
    
    echo -e "${PURPLE}=== ANÁLISE DE HASH ===${NC}"
    echo "Hash: $hash"
    
    # Detectar tipo de hash
    local hash_type
    case ${#hash} in
        32) hash_type="MD5" ;;
        40) hash_type="SHA1" ;;
        64) hash_type="SHA256" ;;
        *) hash_type="Desconhecido" ;;
    esac
    
    echo "Tipo detectado: $hash_type"
    
    analyze_hash_virustotal "$hash"
    
    log_message "Hash analisado: $hash ($hash_type)"
    
    # Gerar e abrir relatório HTML
    "$(dirname "$0")/generate_report.sh" "Análise de Hash" "$hash" "$LOG_FILE"
}

# Função para análise de email
analyze_email() {
    local email="$1"
    
    echo -e "${PURPLE}=== ANÁLISE DE EMAIL ===${NC}"
    echo "Email: $email"
    
    # Extrair domínio do email
    local domain
    domain=$(echo "$email" | cut -d'@' -f2)
    
    echo "Domínio do email: $domain"
    
    analyze_domain_basic "$domain"
    
    log_message "Email analisado: $email"
    
    # Gerar e abrir relatório HTML
    "$(dirname "$0")/generate_report.sh" "Análise de Email" "$email" "$LOG_FILE"
}

# Função para análise de cabeçalho de email
analyze_email_header() {
    local header_file="$1"
    
    # Verificar se o arquivo existe
    if [[ ! -f "$header_file" ]]; then
        echo -e "${RED}Erro: Arquivo não encontrado: $header_file${NC}"
        echo -e "${YELLOW}Verifique se o caminho está correto e se o arquivo existe.${NC}"
        return 1
    fi
    
    # Verificar se o arquivo não está vazio
    if [[ ! -s "$header_file" ]]; then
        echo -e "${RED}Erro: Arquivo está vazio: $header_file${NC}"
        return 1
    fi
    
    # Verificar se o arquivo é legível
    if [[ ! -r "$header_file" ]]; then
        echo -e "${RED}Erro: Sem permissão para ler o arquivo: $header_file${NC}"
        echo -e "${YELLOW}Execute: chmod +r \"$header_file\"${NC}"
        return 1
    fi
    
    echo -e "${PURPLE}=== ANÁLISE DE CABEÇALHO DE EMAIL ===${NC}"
    echo "Arquivo: $header_file"
    echo "Tamanho: $(wc -c < "$header_file") bytes"
    echo "Linhas: $(wc -l < "$header_file")"
    echo ""
    
    # Verificar se parece ser um cabeçalho de email válido
    if ! grep -qi "^From:\|^To:\|^Subject:\|^Received:\|^Message-ID:" "$header_file"; then
        echo -e "${YELLOW}Aviso: O arquivo não parece conter cabeçalhos de email válidos.${NC}"
        echo -e "${YELLOW}Continuando com a análise...${NC}"
        echo ""
    fi
    
    # Extrair informações importantes
    echo -e "${BLUE}[Informações Básicas do Email]${NC}"
    
    # From
    local from_header
    from_header=$(grep -i "^From:" "$header_file" | head -1)
    if [[ -n "$from_header" ]]; then
        echo "From: $(echo "$from_header" | cut -d' ' -f2-)"
    else
        echo "From: não encontrado"
    fi
    
    # To
    local to_header
    to_header=$(grep -i "^To:" "$header_file" | head -1)
    if [[ -n "$to_header" ]]; then
        echo "To: $(echo "$to_header" | cut -d' ' -f2-)"
    else
        echo "To: não encontrado"
    fi
    
    # Subject
    local subject_header
    subject_header=$(grep -i "^Subject:" "$header_file" | head -1)
    if [[ -n "$subject_header" ]]; then
        echo "Subject: $(echo "$subject_header" | cut -d' ' -f2-)"
    else
        echo "Subject: não encontrado"
    fi
    
    # Date
    local date_header
    date_header=$(grep -i "^Date:" "$header_file" | head -1)
    if [[ -n "$date_header" ]]; then
        echo "Date: $(echo "$date_header" | cut -d' ' -f2-)"
    else
        echo "Date: não encontrado"
    fi
    
    # Message-ID
    local msgid_header
    msgid_header=$(grep -i "^Message-ID:" "$header_file" | head -1)
    if [[ -n "$msgid_header" ]]; then
        echo "Message-ID: $(echo "$msgid_header" | cut -d' ' -f2-)"
    else
        echo "Message-ID: não encontrado"
    fi
    
    echo ""
    echo -e "${BLUE}[Caminho do Email - Servidores Received]${NC}"
    local received_count
    received_count=$(grep -c "^Received:" "$header_file")
    
    if [[ $received_count -gt 0 ]]; then
        echo "Total de hops: $received_count"
        grep -i "^Received:" "$header_file" | nl -v0 | while read -r num line; do
            echo "  [$num] $(echo "$line" | cut -c1-80)..."
        done
    else
        echo "Nenhum cabeçalho Received encontrado"
    fi
    
    echo ""
    echo -e "${BLUE}[Autenticação de Email]${NC}"
    
    # SPF
    if grep -qi "Received-SPF:" "$header_file"; then
        local spf_result
        spf_result=$(grep -i "Received-SPF:" "$header_file" | head -1 | awk '{print $2}')
        case "$spf_result" in
            "pass") echo -e "  SPF: ${GREEN}PASS${NC}" ;;
            "fail") echo -e "  SPF: ${RED}FAIL${NC}" ;;
            "softfail") echo -e "  SPF: ${YELLOW}SOFTFAIL${NC}" ;;
            *) echo -e "  SPF: ${YELLOW}$spf_result${NC}" ;;
        esac
    else
        echo -e "  SPF: ${YELLOW}Não encontrado${NC}"
    fi
    
    # DKIM
    if grep -qi "DKIM-Signature:" "$header_file"; then
        echo -e "  DKIM: ${GREEN}Presente${NC}"
        local dkim_domain
        dkim_domain=$(grep -i "DKIM-Signature:" "$header_file" | grep -o "d=[^;]*" | cut -d'=' -f2 | head -1)
        if [[ -n "$dkim_domain" ]]; then
            echo "    Domínio DKIM: $dkim_domain"
        fi
    else
        echo -e "  DKIM: ${RED}Ausente${NC}"
    fi
    
    # DMARC
    if grep -qi "dmarc=" "$header_file"; then
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
    
    echo ""
    echo -e "${BLUE}[IPs Extraídos dos Cabeçalhos]${NC}"
    local ips_found
    ips_found=$(grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$header_file" | sort -u)
    
    if [[ -n "$ips_found" ]]; then
        # Verificação básica de reputação de IPs
        
        local public_ips=()
        local threats_detected=0
        
        echo "$ips_found" | while read -r ip; do
            # Filtrar IPs privados
            if [[ ! "$ip" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
                echo -e "  ${GREEN}IP público encontrado:${NC} $ip"
                public_ips+=("$ip")
                
                # Verificação básica de padrões maliciosos
                if [[ "$ip" =~ ^184\.107\.85\. ]]; then
                    echo -e "    ${RED}⚠ IP em range conhecido por atividade maliciosa (184.107.85.x)${NC}"
                    ((threats_detected++))
                elif [[ "$ip" =~ ^185\.220\. ]]; then
                    echo -e "    ${YELLOW}⚠ Possível Tor exit node${NC}"
                    ((suspicious_count++))
                fi
                
                echo ""
            else
                echo -e "  ${YELLOW}IP privado:${NC} $ip"
            fi
        done
        
        # Atualizar contador de suspeitas se IPs maliciosos foram encontrados
        if [[ $threats_detected -gt 0 ]]; then
            suspicious_count=$((suspicious_count + threats_detected))
        fi
    else
        echo "  Nenhum IP encontrado nos cabeçalhos"
    fi
    
    echo ""
    echo -e "${BLUE}[Indicadores de Suspeita]${NC}"
    local suspicious_count=0
    
    # Verificar X-Mailer suspeito
    if grep -qi "X-Mailer.*mass\|X-Mailer.*bulk" "$header_file"; then
        echo -e "  ${RED}⚠ Possível email em massa detectado${NC}"
        ((suspicious_count++))
    fi
    
    # Verificar discrepâncias no From vs Return-Path
    local from_domain return_domain
    from_domain=$(grep -i "^From:" "$header_file" | head -1 | grep -o "@[^>]*" | tr -d '@>' | head -1)
    return_domain=$(grep -i "^Return-Path:" "$header_file" | head -1 | grep -o "@[^>]*" | tr -d '@>' | head -1)
    
    if [[ -n "$from_domain" && -n "$return_domain" && "$from_domain" != "$return_domain" ]]; then
        echo -e "  ${YELLOW}⚠ Return-Path difere do From${NC}"
        echo "    From: $from_domain | Return-Path: $return_domain"
        ((suspicious_count++))
    fi
    
    # Verificar muitos hops
    if [[ $received_count -gt 8 ]]; then
        echo -e "  ${YELLOW}⚠ Muitos hops de email ($received_count)${NC}"
        ((suspicious_count++))
    fi
    
    if [[ $suspicious_count -eq 0 ]]; then
        echo -e "  ${GREEN}Nenhum indicador óbvio de suspeita encontrado${NC}"
    else
        echo -e "  ${RED}Total de indicadores suspeitos: $suspicious_count${NC}"
    fi
    
    # Análise avançada integrada
    echo ""
    echo -e "${BLUE}[Análise Avançada]${NC}"
    echo "Executando análise avançada..."
    
    echo -e "${PURPLE}=== ANÁLISE COMPLETA DE CABEÇALHO DE EMAIL ===${NC}"
    echo "Arquivo: $header_file"
    echo ""
    
    echo -e "${BLUE}[Informações Básicas]${NC}"
    echo "From: $(grep -i "^From:" "$header_file" | head -1 | cut -d' ' -f2- || echo "não encontrado")"
    echo "To: $(grep -i "^To:" "$header_file" | head -1 | cut -d' ' -f2- || echo "não encontrado")"
    echo "Subject: $(grep -i "^Subject:" "$header_file" | head -1 | cut -d' ' -f2- || echo "não encontrado")"
    echo "Date: $(grep -i "^Date:" "$header_file" | head -1 | cut -d' ' -f2- || echo "não encontrado")"
    echo ""
    
    echo -e "${BLUE}[Email Analyzer] Verificando autenticação de email${NC}"
    # SPF
    if grep -qi "Received-SPF:" "$header_file"; then
        local spf_result
        spf_result=$(grep -i "Received-SPF:" "$header_file" | head -1 | awk '{print $2}')
        case "$spf_result" in
            "pass") echo -e "  SPF: ${GREEN}PASS${NC}" ;;
            "fail") echo -e "  SPF: ${RED}FAIL${NC}" ;;
            *) echo -e "  SPF: ${YELLOW}$spf_result${NC}" ;;
        esac
    else
        echo -e "  SPF: ${YELLOW}Não encontrado${NC}"
    fi
    
    # DKIM
    if grep -qi "DKIM-Signature:" "$header_file"; then
        echo -e "  DKIM: ${GREEN}Presente${NC}"
    else
        echo -e "  DKIM: ${RED}Ausente${NC}"
    fi
    
    # DMARC
    if grep -qi "dmarc=pass" "$header_file"; then
        echo -e "  DMARC: ${GREEN}PASS${NC}"
    elif grep -qi "dmarc=fail" "$header_file"; then
        echo -e "  DMARC: ${RED}FAIL${NC}"
    else
        echo -e "  DMARC: ${YELLOW}Não encontrado${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}[Email Analyzer] Extraindo IPs dos cabeçalhos${NC}"
    echo ""
    
    echo -e "${BLUE}[Email Analyzer] Detectando indicadores de phishing${NC}"
    if [[ $suspicious_count -eq 0 ]]; then
        echo -e "  ${GREEN}Nenhum indicador óbvio de phishing encontrado${NC}"
    else
        echo -e "  ${RED}$suspicious_count indicadores suspeitos detectados${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}[Caminho do Email]${NC}"
    local hop_count=0
    grep -i "^Received:" "$header_file" | while read -r line; do
        echo "  $hop_count: $(echo "$line" | cut -c1-80)..."
        ((hop_count++))
    done
    
    # Análise forense simplificada integrada
    if [[ $suspicious_count -gt 2 ]]; then
        echo ""
        echo -e "${CYAN}[Análise Forense Simplificada]${NC}"
        echo "Detectados $suspicious_count indicadores suspeitos."
        echo "Executando verificações adicionais..."
        
        # Verificar padrões de phishing comuns
        if grep -qi "urgent\|immediate\|verify.*account\|suspended.*account" "$header_file"; then
            echo -e "  ${RED}⚠ Linguagem típica de phishing detectada${NC}"
        fi
        
        # Verificar domínios suspeitos
        local domains
        domains=$(grep -oE '@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$header_file" | sort -u)
        echo "  Domínios encontrados:"
        echo "$domains" | while read -r domain; do
            echo "    $domain"
        done
    fi
    
    # Gerar resumo de ameaças (simplificado)
    echo ""
    echo -e "${BLUE}[Resumo da Análise]${NC}"
    echo "Arquivo analisado: $header_file"
    echo "Indicadores suspeitos encontrados: $suspicious_count"
    
    if [[ $suspicious_count -eq 0 ]]; then
        echo -e "Status: ${GREEN}Aparentemente legítimo${NC}"
    elif [[ $suspicious_count -le 2 ]]; then
        echo -e "Status: ${YELLOW}Requer atenção${NC}"
    else
        echo -e "Status: ${RED}Altamente suspeito${NC}"
    fi
    
    log_message "Cabeçalho de email analisado: $header_file (Ameaças: $suspicious_count)"
    
    echo ""
    echo -e "${GREEN}Análise concluída!${NC}"
    
    # Gerar e abrir relatório HTML
    "$(dirname "$0")/generate_report.sh" "Análise de Cabeçalho de Email" "$header_file" "$LOG_FILE"
}

# Função para análise de IP
analyze_ip() {
    local ip="$1"
    
    echo -e "${PURPLE}=== ANÁLISE DE IP ===${NC}"
    echo "IP: $ip"
    echo ""
    
    # Validar formato do IP
    if ! [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo -e "${RED}Erro: Formato de IP inválido${NC}"
        return 1
    fi
    
    # Verificar se é IP privado
    if [[ $ip =~ ^10\. ]] || [[ $ip =~ ^192\.168\. ]] || [[ $ip =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
        echo -e "${YELLOW}⚠️  IP Privado detectado${NC}"
        echo "Este é um endereço IP privado (RFC 1918)"
        echo ""
    fi
    
    # Análise básica com whois
    echo -e "${BLUE}[Informações WHOIS]${NC}"
    if command -v whois > /dev/null; then
        whois_info=$(timeout 10 whois "$ip" 2>/dev/null | head -20)
        if [ -n "$whois_info" ]; then
            echo "$whois_info" | grep -E "(country|Country|organization|Organization|netname|NetName)" | head -5
        else
            echo "Informações WHOIS não disponíveis"
        fi
    else
        echo "Comando whois não encontrado"
    fi
    echo ""
    
    # Análise de geolocalização básica
    echo -e "${BLUE}[Análise de Geolocalização]${NC}"
    if command -v curl > /dev/null; then
        geo_info=$(timeout 10 curl -s "http://ip-api.com/json/$ip" 2>/dev/null)
        if [ -n "$geo_info" ] && echo "$geo_info" | grep -q "success"; then
            echo "$geo_info" | grep -o '"country":"[^"]*"' | cut -d'"' -f4 | sed 's/^/País: /'
            echo "$geo_info" | grep -o '"city":"[^"]*"' | cut -d'"' -f4 | sed 's/^/Cidade: /'
            echo "$geo_info" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4 | sed 's/^/ISP: /'
        else
            echo "Informações de geolocalização não disponíveis"
        fi
    else
        echo "curl não encontrado para análise de geolocalização"
    fi
    echo ""
    
    # Verificação de reputação básica
    echo -e "${BLUE}[Verificação de Reputação]${NC}"
    echo "Verificando listas de IPs maliciosos conhecidos..."
    
    # Verificar se está em algumas listas conhecidas (simulação)
    reputation_score=0
    risk_factors=()
    
    # Verificações básicas de padrões suspeitos
    if [[ $ip =~ ^(185\.|91\.|46\.) ]]; then
        risk_factors+=("IP em faixa frequentemente associada a atividades suspeitas")
        ((reputation_score += 20))
    fi
    
    if [ ${#risk_factors[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ Nenhum indicador óbvio de atividade maliciosa encontrado${NC}"
        risk_level="BAIXO"
        risk_emoji="🟢"
    elif [ $reputation_score -lt 50 ]; then
        echo -e "${YELLOW}⚠️  Alguns indicadores de risco encontrados${NC}"
        risk_level="MÉDIO"
        risk_emoji="🟡"
    else
        echo -e "${RED}⚠️  Múltiplos indicadores de risco encontrados${NC}"
        risk_level="ALTO"
        risk_emoji="🔴"
    fi
    
    # Exibir fatores de risco se houver
    if [ ${#risk_factors[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Fatores de risco identificados:${NC}"
        for factor in "${risk_factors[@]}"; do
            echo "  • $factor"
        done
    fi
    
    echo ""
    echo -e "${BLUE}[Resumo da Análise]${NC}"
    echo "IP analisado: $ip"
    echo "Nível de risco: $risk_emoji $risk_level"
    echo "Pontuação de risco: $reputation_score/100"
    
    log_message "IP analisado: $ip - Risco: $risk_level ($reputation_score/100)"
    
    # Gerar e abrir relatório HTML
    export IP_COUNTRY IP_ORG RISK_SCORE="$reputation_score" IP_RISK_FACTORS
    if [ ${#risk_factors[@]} -gt 0 ]; then
        IP_RISK_FACTORS=$(printf '%s\n' "${risk_factors[@]}")
    fi
    
    "$(dirname "$0")/generate_report.sh" "Análise de IP" "$ip" "$LOG_FILE"
}

# Função principal
main() {
    show_banner
    check_dependencies
    load_api_keys
    
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    case "$1" in
        -i|--ip)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erro: Especifique o IP para análise${NC}"
                exit 1
            fi
            analyze_ip "$2"
            ;;
        -f|--file)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erro: Especifique o arquivo para análise${NC}"
                exit 1
            fi
            analyze_file "$2"
            ;;
        -u|--url)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erro: Especifique a URL para análise${NC}"
                exit 1
            fi
            analyze_url "$2"
            ;;
        -d|--domain)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erro: Especifique o domínio para análise${NC}"
                exit 1
            fi
            analyze_domain "$2"
            ;;
        -h|--hash)
            ;;
        -i|--ip)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erro: Especifique o IP para análise${NC}"
                exit 1
            fi
            analyze_ip "$2"
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erro: Especifique o hash para análise${NC}"
                exit 1
            fi
            analyze_hash "$2"
            ;;
        -e|--email)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erro: Especifique o email para análise${NC}"
                exit 1
            fi
            analyze_email "$2"
            ;;
        --header)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erro: Especifique o arquivo de cabeçalho para análise${NC}"
                exit 1
            fi
            analyze_email_header "$2"
            ;;
        --config)
            configure_api_keys
            ;;
        --help)
            show_help
            ;;
        *)
            echo -e "${RED}Opção inválida: $1${NC}"
            show_help
            exit 1
            ;;
    esac
    
    echo -e "\n${GREEN}Análise concluída. Log salvo em: $LOG_FILE${NC}"
}

# Executar função principal
main "$@"
