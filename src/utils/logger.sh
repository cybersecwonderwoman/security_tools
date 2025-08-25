#!/bin/bash

# ========================================
# Advanced Logging Module
# Sistema de logging estruturado e seguro
# ========================================

# Carregar configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.conf"

# Níveis de log
declare -A LOG_LEVELS=(
    ["DEBUG"]=0
    ["INFO"]=1
    ["WARN"]=2
    ["ERROR"]=3
    ["CRITICAL"]=4
)

# Cores para diferentes níveis
declare -A LOG_COLORS=(
    ["DEBUG"]='\033[0;36m'    # Cyan
    ["INFO"]='\033[0;32m'     # Green
    ["WARN"]='\033[1;33m'     # Yellow
    ["ERROR"]='\033[0;31m'    # Red
    ["CRITICAL"]='\033[1;31m' # Bold Red
)

NC='\033[0m' # No Color

# Inicializar sistema de logging
init_logging() {
    # Criar diretório de logs se não existir
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Rotacionar logs se necessário
    rotate_logs
    
    # Log de inicialização
    log_message "INFO" "Sistema de logging inicializado"
}

# Função principal de logging
log_message() {
    local level="$1"
    local message="$2"
    local component="${3:-MAIN}"
    
    # Verificar se o nível está configurado para ser logado
    local current_level_num=${LOG_LEVELS[$LOG_LEVEL]}
    local message_level_num=${LOG_LEVELS[$level]}
    
    [[ $message_level_num -ge $current_level_num ]] || return 0
    
    # Preparar timestamp
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local pid=$$
    
    # Preparar mensagem estruturada
    local log_entry="[$timestamp] [$level] [$component] [PID:$pid] $message"
    
    # Escrever no arquivo de log
    echo "$log_entry" >> "$LOG_FILE"
    
    # Exibir no terminal se apropriado
    if [[ "$level" != "DEBUG" || "$LOG_LEVEL" == "DEBUG" ]]; then
        local color=${LOG_COLORS[$level]}
        echo -e "${color}[$level]${NC} $message" >&2
    fi
    
    # Verificar tamanho do log
    check_log_size
}

# Funções de conveniência para diferentes níveis
log_debug() {
    log_message "DEBUG" "$1" "$2"
}

log_info() {
    log_message "INFO" "$1" "$2"
}

log_warn() {
    log_message "WARN" "$1" "$2"
}

log_error() {
    log_message "ERROR" "$1" "$2"
}

log_critical() {
    log_message "CRITICAL" "$1" "$2"
}

# Log de análise com dados estruturados
log_analysis() {
    local analysis_type="$1"
    local target="$2"
    local result="$3"
    local duration="$4"
    
    local structured_message="ANALYSIS_COMPLETE type=$analysis_type target=$target result=$result duration=${duration}s"
    log_message "INFO" "$structured_message" "ANALYZER"
}

# Log de erro com stack trace
log_error_with_trace() {
    local error_message="$1"
    local function_name="${FUNCNAME[1]}"
    local line_number="${BASH_LINENO[0]}"
    local script_name="${BASH_SOURCE[1]}"
    
    local trace_message="ERROR in $function_name() at line $line_number in $(basename "$script_name"): $error_message"
    log_message "ERROR" "$trace_message" "SYSTEM"
}

# Rotacionar logs quando ficam muito grandes
rotate_logs() {
    if [[ -f "$LOG_FILE" ]]; then
        local log_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo "0")
        
        if [[ $log_size -gt $MAX_LOG_SIZE ]]; then
            local backup_file="${LOG_FILE}.$(date +%Y%m%d_%H%M%S)"
            mv "$LOG_FILE" "$backup_file"
            
            # Comprimir log antigo
            gzip "$backup_file" 2>/dev/null
            
            log_message "INFO" "Log rotacionado: $(basename "$backup_file")" "LOGGER"
        fi
    fi
}

# Verificar tamanho do log atual
check_log_size() {
    if [[ -f "$LOG_FILE" ]]; then
        local log_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo "0")
        
        if [[ $log_size -gt $MAX_LOG_SIZE ]]; then
            rotate_logs
        fi
    fi
}

# Limpar logs antigos
cleanup_old_logs() {
    local log_dir="$(dirname "$LOG_FILE")"
    
    # Remover logs mais antigos que LOG_RETENTION_DAYS
    find "$log_dir" -name "*.log.*" -type f -mtime +$LOG_RETENTION_DAYS -delete 2>/dev/null
    
    log_message "INFO" "Limpeza de logs antigos concluída" "LOGGER"
}

# Exportar logs para análise
export_logs() {
    local start_date="$1"
    local end_date="$2"
    local output_file="$3"
    
    if [[ -f "$LOG_FILE" ]]; then
        if [[ -n "$start_date" && -n "$end_date" ]]; then
            # Filtrar por data
            awk -v start="$start_date" -v end="$end_date" '
                $0 ~ /^\[/ {
                    date_str = substr($0, 2, 19)
                    if (date_str >= start && date_str <= end) print
                }
            ' "$LOG_FILE" > "$output_file"
        else
            # Exportar tudo
            cp "$LOG_FILE" "$output_file"
        fi
        
        log_message "INFO" "Logs exportados para: $output_file" "LOGGER"
    fi
}

# Analisar logs para estatísticas
analyze_logs() {
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "Arquivo de log não encontrado"
        return 1
    fi
    
    echo "📊 ESTATÍSTICAS DE LOGS"
    echo "======================"
    
    # Total de entradas
    local total_entries=$(wc -l < "$LOG_FILE")
    echo "Total de entradas: $total_entries"
    
    # Entradas por nível
    echo ""
    echo "Entradas por nível:"
    for level in DEBUG INFO WARN ERROR CRITICAL; do
        local count=$(grep -c "\[$level\]" "$LOG_FILE" 2>/dev/null || echo "0")
        echo "  $level: $count"
    done
    
    # Análises realizadas
    echo ""
    local analyses=$(grep -c "ANALYSIS_COMPLETE" "$LOG_FILE" 2>/dev/null || echo "0")
    echo "Análises realizadas: $analyses"
    
    # Erros recentes (últimas 24h)
    echo ""
    local recent_errors=$(grep "\[ERROR\]\|\[CRITICAL\]" "$LOG_FILE" | tail -10 | wc -l)
    echo "Erros recentes: $recent_errors"
    
    # Tamanho do arquivo
    echo ""
    local log_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo "0")
    local log_size_mb=$((log_size / 1024 / 1024))
    echo "Tamanho do log: ${log_size_mb}MB"
}

# Monitorar logs em tempo real
tail_logs() {
    local level_filter="$1"
    
    if [[ -n "$level_filter" ]]; then
        tail -f "$LOG_FILE" | grep --line-buffered "\[$level_filter\]"
    else
        tail -f "$LOG_FILE"
    fi
}

# Buscar nos logs
search_logs() {
    local pattern="$1"
    local context_lines="${2:-2}"
    
    if [[ -f "$LOG_FILE" ]]; then
        grep -i -C "$context_lines" "$pattern" "$LOG_FILE"
    fi
}
