#!/bin/bash

# ========================================
# API Manager Module
# Gerenciamento seguro de APIs e chaves
# ========================================

# Carregar dependências
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.conf"
source "$SCRIPT_DIR/../utils/security.sh"
source "$SCRIPT_DIR/../utils/logger.sh"

# APIs suportadas
declare -A SUPPORTED_APIS=(
    ["virustotal"]="VirusTotal API"
    ["urlscan"]="URLScan.io API"
    ["shodan"]="Shodan API"
    ["threatfox"]="ThreatFox API"
    ["alienvault"]="AlienVault OTX API"
    ["hybrid"]="Hybrid Analysis API"
    ["malshare"]="MalShare API"
    ["joesandbox"]="Joe Sandbox API"
)

# Inicializar gerenciador de APIs
init_api_manager() {
    create_secure_directory "$(dirname "$API_KEYS_FILE")"
    log_info "API Manager inicializado" "API_MANAGER"
}

# Armazenar chave de API de forma segura
store_api_key() {
    local api_name="$1"
    local api_key="$2"
    
    # Validar entrada
    if [[ -z "$api_name" || -z "$api_key" ]]; then
        log_error "Nome da API ou chave não fornecidos" "API_MANAGER"
        return 1
    fi
    
    # Verificar se API é suportada
    if [[ -z "${SUPPORTED_APIS[$api_name]}" ]]; then
        log_error "API não suportada: $api_name" "API_MANAGER"
        return 1
    fi
    
    # Criptografar chave
    local encrypted_key=$(encrypt_data "$api_key")
    
    if [[ -z "$encrypted_key" ]]; then
        log_error "Falha ao criptografar chave da API $api_name" "API_MANAGER"
        return 1
    fi
    
    # Criar arquivo temporário
    local temp_file=$(mktemp)
    
    # Ler configurações existentes se houver
    if [[ -f "$API_KEYS_FILE" ]]; then
        cp "$API_KEYS_FILE" "$temp_file"
    fi
    
    # Remover entrada existente da API
    grep -v "^${api_name}=" "$temp_file" > "${temp_file}.new" 2>/dev/null || touch "${temp_file}.new"
    
    # Adicionar nova entrada
    echo "${api_name}=${encrypted_key}" >> "${temp_file}.new"
    
    # Mover para arquivo final
    mv "${temp_file}.new" "$API_KEYS_FILE"
    chmod 600 "$API_KEYS_FILE"
    
    # Limpar arquivos temporários
    rm -f "$temp_file"
    
    log_info "Chave da API $api_name armazenada com segurança" "API_MANAGER"
    return 0
}

# Recuperar chave de API
get_api_key() {
    local api_name="$1"
    
    if [[ ! -f "$API_KEYS_FILE" ]]; then
        return 1
    fi
    
    local encrypted_key=$(grep "^${api_name}=" "$API_KEYS_FILE" | cut -d'=' -f2-)
    
    if [[ -n "$encrypted_key" ]]; then
        decrypt_data "$encrypted_key"
    else
        return 1
    fi
}

# Verificar se API está configurada
is_api_configured() {
    local api_name="$1"
    local api_key=$(get_api_key "$api_name")
    
    [[ -n "$api_key" ]]
}

# Testar conectividade com API
test_api_connection() {
    local api_name="$1"
    local api_key=$(get_api_key "$api_name")
    
    if [[ -z "$api_key" ]]; then
        log_warn "Chave da API $api_name não configurada" "API_MANAGER"
        return 1
    fi
    
    case "$api_name" in
        "virustotal")
            test_virustotal_api "$api_key"
            ;;
        "urlscan")
            test_urlscan_api "$api_key"
            ;;
        "shodan")
            test_shodan_api "$api_key"
            ;;
        *)
            log_warn "Teste não implementado para API: $api_name" "API_MANAGER"
            return 1
            ;;
    esac
}

# Testar VirusTotal API
test_virustotal_api() {
    local api_key="$1"
    
    local response=$(curl -s -H "x-apikey: $api_key" \
        --connect-timeout $CONNECTION_TIMEOUT \
        "$VIRUSTOTAL_API_URL/users/current")
    
    if echo "$response" | grep -q '"type": "user"'; then
        log_info "VirusTotal API: Conexão bem-sucedida" "API_MANAGER"
        return 0
    else
        log_error "VirusTotal API: Falha na conexão" "API_MANAGER"
        return 1
    fi
}

# Testar URLScan API
test_urlscan_api() {
    local api_key="$1"
    
    local response=$(curl -s -H "API-Key: $api_key" \
        --connect-timeout $CONNECTION_TIMEOUT \
        "$URLSCAN_API_URL/user/quotas/")
    
    if echo "$response" | grep -q '"limits"'; then
        log_info "URLScan API: Conexão bem-sucedida" "API_MANAGER"
        return 0
    else
        log_error "URLScan API: Falha na conexão" "API_MANAGER"
        return 1
    fi
}

# Testar Shodan API
test_shodan_api() {
    local api_key="$1"
    
    local response=$(curl -s \
        --connect-timeout $CONNECTION_TIMEOUT \
        "$SHODAN_API_URL/account/profile?key=$api_key")
    
    if echo "$response" | grep -q '"member"'; then
        log_info "Shodan API: Conexão bem-sucedida" "API_MANAGER"
        return 0
    else
        log_error "Shodan API: Falha na conexão" "API_MANAGER"
        return 1
    fi
}

# Fazer requisição segura para API
make_api_request() {
    local api_name="$1"
    local endpoint="$2"
    local method="${3:-GET}"
    local data="$4"
    
    # Verificar rate limiting
    if ! check_rate_limit "$api_name"; then
        log_warn "Rate limit atingido para API: $api_name" "API_MANAGER"
        return 1
    fi
    
    local api_key=$(get_api_key "$api_name")
    if [[ -z "$api_key" ]]; then
        log_error "API $api_name não configurada" "API_MANAGER"
        return 1
    fi
    
    local curl_opts=(
        -s
        --connect-timeout $CONNECTION_TIMEOUT
        --max-time $DEFAULT_TIMEOUT
        -H "User-Agent: SecurityAnalyzer/3.0"
    )
    
    case "$api_name" in
        "virustotal")
            curl_opts+=(-H "x-apikey: $api_key")
            ;;
        "urlscan")
            curl_opts+=(-H "API-Key: $api_key")
            ;;
        "shodan")
            endpoint="${endpoint}?key=${api_key}"
            ;;
    esac
    
    if [[ "$method" == "POST" && -n "$data" ]]; then
        curl_opts+=(-X POST -d "$data")
    fi
    
    curl "${curl_opts[@]}" "$endpoint"
}

# Listar APIs configuradas
list_configured_apis() {
    echo "📋 APIs Configuradas:"
    echo "===================="
    
    for api_name in "${!SUPPORTED_APIS[@]}"; do
        local status="❌ Não configurada"
        local connection_status=""
        
        if is_api_configured "$api_name"; then
            status="✅ Configurada"
            
            # Testar conexão
            if test_api_connection "$api_name" >/dev/null 2>&1; then
                connection_status=" (🟢 Online)"
            else
                connection_status=" (🔴 Offline)"
            fi
        fi
        
        printf "%-15s: %s%s\n" "${SUPPORTED_APIS[$api_name]}" "$status" "$connection_status"
    done
}

# Remover chave de API
remove_api_key() {
    local api_name="$1"
    
    if [[ ! -f "$API_KEYS_FILE" ]]; then
        log_warn "Arquivo de chaves não encontrado" "API_MANAGER"
        return 1
    fi
    
    # Criar arquivo temporário sem a chave especificada
    local temp_file=$(mktemp)
    grep -v "^${api_name}=" "$API_KEYS_FILE" > "$temp_file"
    
    # Substituir arquivo original
    mv "$temp_file" "$API_KEYS_FILE"
    chmod 600 "$API_KEYS_FILE"
    
    log_info "Chave da API $api_name removida" "API_MANAGER"
}

# Configurar API interativamente
configure_api_interactive() {
    local api_name="$1"
    
    if [[ -z "${SUPPORTED_APIS[$api_name]}" ]]; then
        echo "API não suportada: $api_name"
        return 1
    fi
    
    echo "🔑 Configurando ${SUPPORTED_APIS[$api_name]}"
    echo "============================================"
    
    # Verificar se já está configurada
    if is_api_configured "$api_name"; then
        echo "⚠️  API já configurada. Deseja reconfigurar? (s/n)"
        read -r reconfigure
        [[ "$reconfigure" =~ ^[Ss]$ ]] || return 0
    fi
    
    echo "Digite a chave da API:"
    read -r -s api_key
    echo
    
    if [[ -z "$api_key" ]]; then
        echo "❌ Chave não fornecida"
        return 1
    fi
    
    # Armazenar chave
    if store_api_key "$api_name" "$api_key"; then
        echo "✅ Chave armazenada com sucesso"
        
        # Testar conexão
        echo "🔍 Testando conexão..."
        if test_api_connection "$api_name"; then
            echo "✅ Conexão bem-sucedida!"
        else
            echo "⚠️  Conexão falhou. Verifique a chave."
        fi
    else
        echo "❌ Erro ao armazenar chave"
        return 1
    fi
}

# Exportar configurações (sem chaves)
export_api_config() {
    local output_file="$1"
    
    {
        echo "# Security Analyzer Tool - Configuração de APIs"
        echo "# Gerado em: $(date)"
        echo ""
        
        for api_name in "${!SUPPORTED_APIS[@]}"; do
            if is_api_configured "$api_name"; then
                echo "${api_name}=CONFIGURED"
            else
                echo "${api_name}=NOT_CONFIGURED"
            fi
        done
    } > "$output_file"
    
    log_info "Configuração de APIs exportada para: $output_file" "API_MANAGER"
}
