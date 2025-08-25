#!/bin/bash

# ========================================
# Security Utilities Module
# Funções de segurança e criptografia
# ========================================

# Carregar configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.conf"

# Gerar chave de criptografia baseada no sistema
generate_system_key() {
    local user_info="$USER"
    local host_info="$(hostname)"
    local system_info="$(uname -a | md5sum | cut -d' ' -f1)"
    
    echo "${user_info}-${host_info}-${system_info}" | sha256sum | cut -d' ' -f1
}

# Criptografar dados sensíveis
encrypt_data() {
    local data="$1"
    local key="$(generate_system_key)"
    
    echo "$data" | openssl enc -aes-256-cbc -a -salt -pass pass:"$key" 2>/dev/null
}

# Descriptografar dados
decrypt_data() {
    local encrypted_data="$1"
    local key="$(generate_system_key)"
    
    echo "$encrypted_data" | openssl enc -aes-256-cbc -d -a -pass pass:"$key" 2>/dev/null
}

# Validar entrada de acordo com o tipo
validate_input() {
    local input="$1"
    local type="$2"
    
    case "$type" in
        "url")
            [[ "$input" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]
            ;;
        "domain")
            [[ "$input" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
            ;;
        "ip")
            [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
            ;;
        "email")
            [[ "$input" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
            ;;
        "file")
            [[ -f "$input" && -r "$input" ]]
            ;;
        "hash_md5")
            [[ "$input" =~ ^[a-fA-F0-9]{32}$ ]]
            ;;
        "hash_sha1")
            [[ "$input" =~ ^[a-fA-F0-9]{40}$ ]]
            ;;
        "hash_sha256")
            [[ "$input" =~ ^[a-fA-F0-9]{64}$ ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Sanitizar entrada removendo caracteres perigosos
sanitize_input() {
    local input="$1"
    
    # Remover caracteres perigosos
    input=$(echo "$input" | tr -d '`$(){}[]|&;<>?*')
    
    # Limitar tamanho
    input=$(echo "$input" | cut -c1-1000)
    
    echo "$input"
}

# Verificar se arquivo é seguro para análise
is_file_safe() {
    local file_path="$1"
    
    # Verificar se existe e é legível
    [[ -f "$file_path" && -r "$file_path" ]] || return 1
    
    # Verificar tamanho
    local file_size=$(stat -c%s "$file_path" 2>/dev/null || echo "0")
    [[ $file_size -le $MAX_FILE_SIZE ]] || return 1
    
    # Verificar se não é um link simbólico perigoso
    [[ ! -L "$file_path" ]] || return 1
    
    return 0
}

# Gerar hash seguro para identificação
generate_secure_hash() {
    local data="$1"
    echo "$data$(date +%s)$(openssl rand -hex 8)" | sha256sum | cut -d' ' -f1
}

# Verificar integridade de arquivo
verify_file_integrity() {
    local file_path="$1"
    local expected_hash="$2"
    
    if [[ -f "$file_path" ]]; then
        local actual_hash=$(sha256sum "$file_path" | cut -d' ' -f1)
        [[ "$actual_hash" == "$expected_hash" ]]
    else
        return 1
    fi
}

# Limpar dados sensíveis da memória
secure_cleanup() {
    local var_name="$1"
    
    if [[ -n "${!var_name}" ]]; then
        unset "$var_name"
    fi
}

# Verificar se processo está sendo executado com privilégios adequados
check_privileges() {
    # Não deve ser executado como root para segurança
    if [[ $EUID -eq 0 ]]; then
        echo "AVISO: Executando como root não é recomendado por segurança"
        return 1
    fi
    
    return 0
}

# Criar diretório seguro
create_secure_directory() {
    local dir_path="$1"
    
    mkdir -p "$dir_path"
    chmod 700 "$dir_path"
}

# Verificar se URL é segura para análise
is_url_safe() {
    local url="$1"
    
    # Lista de domínios perigosos conhecidos
    local dangerous_domains=("localhost" "127.0.0.1" "0.0.0.0" "::1")
    
    for domain in "${dangerous_domains[@]}"; do
        if [[ "$url" == *"$domain"* ]]; then
            return 1
        fi
    done
    
    return 0
}

# Rate limiting para APIs
check_rate_limit() {
    local api_name="$1"
    local rate_file="$CACHE_DIR/rate_${api_name}"
    local current_time=$(date +%s)
    
    # Criar arquivo se não existir
    [[ -f "$rate_file" ]] || echo "0" > "$rate_file"
    
    local last_request=$(cat "$rate_file")
    local time_diff=$((current_time - last_request))
    
    # Verificar se passou tempo suficiente (60s / API_RATE_LIMIT)
    local min_interval=$((60 / API_RATE_LIMIT))
    
    if [[ $time_diff -ge $min_interval ]]; then
        echo "$current_time" > "$rate_file"
        return 0
    else
        return 1
    fi
}
