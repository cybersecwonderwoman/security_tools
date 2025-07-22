#!/bin/bash

# ========================================
# Configurações - Security Analyzer Tool
# ========================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Diretórios
CONFIG_DIR="$HOME/.security_analyzer"
LOG_FILE="$CONFIG_DIR/analysis.log"
CACHE_DIR="$CONFIG_DIR/cache"
API_KEYS_FILE="$CONFIG_DIR/api_keys.conf"
REPORTS_DIR="$CONFIG_DIR/reports"

# Criar diretórios se não existirem
mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$REPORTS_DIR"

# Carregar chaves de API se existirem
if [[ -f "$API_KEYS_FILE" ]]; then
    source "$API_KEYS_FILE"
fi

# URLs das APIs
VIRUSTOTAL_API_URL="https://www.virustotal.com/api/v3"
URLSCAN_API_URL="https://urlscan.io/api/v1"
SHODAN_API_URL="https://api.shodan.io"
HYBRID_ANALYSIS_API_URL="https://www.hybrid-analysis.com/api/v2"
THREATFOX_API_URL="https://threatfox-api.abuse.ch/api/v1"
ALIENVAULT_OTX_API_URL="https://otx.alienvault.com/api/v1"
MALSHARE_API_URL="https://malshare.com/api.php"

# Configurações de timeout
CURL_TIMEOUT=30
API_RATE_LIMIT_DELAY=1

# Função para logging com timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Função para criar relatório
create_report() {
    local target="$1"
    local analysis_type="$2"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local report_file="$REPORTS_DIR/${analysis_type}_${timestamp}.json"
    
    echo "{\"target\":\"$target\",\"type\":\"$analysis_type\",\"timestamp\":\"$(date -Iseconds)\",\"results\":[]}" > "$report_file"
    echo "$report_file"
}

# Função para adicionar resultado ao relatório
add_to_report() {
    local report_file="$1"
    local source="$2"
    local result="$3"
    local status="$4"
    
    if [[ -f "$report_file" ]]; then
        local temp_file=$(mktemp)
        jq --arg source "$source" --arg result "$result" --arg status "$status" \
           '.results += [{"source": $source, "result": $result, "status": $status}]' \
           "$report_file" > "$temp_file" && mv "$temp_file" "$report_file"
    fi
}

# Exportar variáveis importantes
export CONFIG_DIR LOG_FILE CACHE_DIR API_KEYS_FILE REPORTS_DIR
export RED GREEN YELLOW BLUE PURPLE CYAN NC
export CURL_TIMEOUT API_RATE_LIMIT_DELAY
