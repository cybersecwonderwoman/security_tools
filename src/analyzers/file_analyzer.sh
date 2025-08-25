#!/bin/bash

# ========================================
# Advanced File Analyzer
# Análise profunda de arquivos com múltiplas fontes
# ========================================

# Carregar dependências
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.conf"
source "$SCRIPT_DIR/../utils/security.sh"
source "$SCRIPT_DIR/../utils/logger.sh"
source "$SCRIPT_DIR/../modules/api_manager.sh"

# Tipos de arquivo perigosos
declare -A DANGEROUS_EXTENSIONS=(
    ["exe"]="Executável Windows"
    ["scr"]="Screen Saver"
    ["bat"]="Batch Script"
    ["cmd"]="Command Script"
    ["com"]="Command File"
    ["pif"]="Program Information File"
    ["vbs"]="VBScript"
    ["js"]="JavaScript"
    ["jar"]="Java Archive"
    ["app"]="macOS Application"
    ["deb"]="Debian Package"
    ["rpm"]="RPM Package"
)

# Assinaturas de malware conhecidas (simplificado)
declare -A MALWARE_SIGNATURES=(
    ["X5O!P%@AP[4\\PZX54(P^)7CC)7}\$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*"]="EICAR Test File"
    ["TVqQAAMAAAAEAAAA"]="PE Executable"
    ["UEsDBBQAAAAI"]="ZIP Archive"
)

# Analisar arquivo completo
analyze_file() {
    local file_path="$1"
    local start_time=$(date +%s)
    
    log_info "Iniciando análise de arquivo: $file_path" "FILE_ANALYZER"
    
    # Validações iniciais
    if ! validate_input "$file_path" "file"; then
        log_error "Arquivo inválido ou não encontrado: $file_path" "FILE_ANALYZER"
        return 1
    fi
    
    if ! is_file_safe "$file_path"; then
        log_error "Arquivo não é seguro para análise: $file_path" "FILE_ANALYZER"
        return 1
    fi
    
    # Inicializar resultado da análise
    local analysis_result=""
    analysis_result+="📁 ANÁLISE AVANÇADA DE ARQUIVO\n"
    analysis_result+="================================\n\n"
    
    # 1. Informações básicas
    analysis_result+="$(get_basic_file_info "$file_path")\n\n"
    
    # 2. Análise de hashes
    analysis_result+="$(calculate_file_hashes "$file_path")\n\n"
    
    # 3. Análise de tipo e estrutura
    analysis_result+="$(analyze_file_structure "$file_path")\n\n"
    
    # 4. Verificação de assinaturas
    analysis_result+="$(check_malware_signatures "$file_path")\n\n"
    
    # 5. Análise de metadados
    analysis_result+="$(extract_metadata "$file_path")\n\n"
    
    # 6. Verificação em APIs externas
    analysis_result+="$(check_external_apis "$file_path")\n\n"
    
    # 7. Análise de risco
    local risk_level=$(calculate_risk_level "$file_path")
    analysis_result+="$(generate_risk_assessment "$risk_level")\n\n"
    
    # 8. Recomendações
    analysis_result+="$(generate_file_recommendations "$risk_level")\n\n"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    analysis_result+="Análise concluída em ${duration}s - $(date '+%Y-%m-%d %H:%M:%S')\n"
    
    # Log da análise
    log_analysis "FILE" "$file_path" "$risk_level" "$duration"
    
    echo -e "$analysis_result"
    return 0
}

# Obter informações básicas do arquivo
get_basic_file_info() {
    local file_path="$1"
    local result=""
    
    result+="[📋 Informações Básicas]\n"
    result+="Nome: $(basename "$file_path")\n"
    result+="Caminho: $file_path\n"
    
    # Tamanho
    local file_size=$(stat -c%s "$file_path" 2>/dev/null || echo "0")
    local size_mb=$((file_size / 1024 / 1024))
    result+="Tamanho: $file_size bytes (${size_mb}MB)\n"
    
    # Datas
    local created=$(stat -c%w "$file_path" 2>/dev/null || echo "N/A")
    local modified=$(stat -c%y "$file_path" 2>/dev/null || echo "N/A")
    local accessed=$(stat -c%x "$file_path" 2>/dev/null || echo "N/A")
    
    result+="Criado: $created\n"
    result+="Modificado: $modified\n"
    result+="Acessado: $accessed\n"
    
    # Permissões
    local permissions=$(stat -c%A "$file_path" 2>/dev/null || echo "N/A")
    result+="Permissões: $permissions\n"
    
    echo -e "$result"
}

# Calcular hashes do arquivo
calculate_file_hashes() {
    local file_path="$1"
    local result=""
    
    result+="[🔢 Hashes Criptográficos]\n"
    
    # MD5
    if command -v md5sum &>/dev/null; then
        local md5_hash=$(md5sum "$file_path" | cut -d ' ' -f 1)
        result+="MD5:    $md5_hash\n"
    fi
    
    # SHA1
    if command -v sha1sum &>/dev/null; then
        local sha1_hash=$(sha1sum "$file_path" | cut -d ' ' -f 1)
        result+="SHA1:   $sha1_hash\n"
    fi
    
    # SHA256
    if command -v sha256sum &>/dev/null; then
        local sha256_hash=$(sha256sum "$file_path" | cut -d ' ' -f 1)
        result+="SHA256: $sha256_hash\n"
    fi
    
    # SHA512
    if command -v sha512sum &>/dev/null; then
        local sha512_hash=$(sha512sum "$file_path" | cut -d ' ' -f 1)
        result+="SHA512: $sha512_hash\n"
    fi
    
    echo -e "$result"
}

# Analisar estrutura do arquivo
analyze_file_structure() {
    local file_path="$1"
    local result=""
    
    result+="[🔍 Análise de Estrutura]\n"
    
    # Tipo de arquivo
    local file_type=$(file -b "$file_path" 2>/dev/null || echo "Desconhecido")
    result+="Tipo: $file_type\n"
    
    # MIME type
    local mime_type=$(file -b --mime-type "$file_path" 2>/dev/null || echo "Desconhecido")
    result+="MIME: $mime_type\n"
    
    # Extensão
    local extension="${file_path##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    result+="Extensão: .$extension\n"
    
    # Verificar se extensão é perigosa
    if [[ -n "${DANGEROUS_EXTENSIONS[$extension]}" ]]; then
        result+="⚠️  EXTENSÃO PERIGOSA: ${DANGEROUS_EXTENSIONS[$extension]}\n"
    fi
    
    # Análise específica por tipo
    case "$mime_type" in
        "application/x-executable"|"application/x-dosexec")
            result+="$(analyze_executable "$file_path")\n"
            ;;
        "application/zip"|"application/x-zip-compressed")
            result+="$(analyze_archive "$file_path")\n"
            ;;
        "text/"*)
            result+="$(analyze_text_file "$file_path")\n"
            ;;
    esac
    
    echo -e "$result"
}

# Analisar executável
analyze_executable() {
    local file_path="$1"
    local result=""
    
    result+="[⚠️  Análise de Executável]\n"
    
    # Verificar se é PE (Windows)
    if command -v objdump &>/dev/null; then
        local pe_info=$(objdump -p "$file_path" 2>/dev/null | head -5)
        if [[ -n "$pe_info" ]]; then
            result+="Formato: PE (Windows Executable)\n"
        fi
    fi
    
    # Verificar strings suspeitas
    if command -v strings &>/dev/null; then
        local suspicious_strings=$(strings "$file_path" | grep -i -E "(password|keylog|backdoor|trojan|virus)" | head -3)
        if [[ -n "$suspicious_strings" ]]; then
            result+="⚠️  Strings suspeitas encontradas:\n"
            echo "$suspicious_strings" | while read -r line; do
                result+="  - $line\n"
            done
        fi
    fi
    
    echo -e "$result"
}

# Analisar arquivo compactado
analyze_archive() {
    local file_path="$1"
    local result=""
    
    result+="[📦 Análise de Arquivo]\n"
    
    # Listar conteúdo do ZIP
    if command -v unzip &>/dev/null; then
        local zip_content=$(unzip -l "$file_path" 2>/dev/null | tail -n +4 | head -n -2)
        if [[ -n "$zip_content" ]]; then
            local file_count=$(echo "$zip_content" | wc -l)
            result+="Arquivos no ZIP: $file_count\n"
            
            # Verificar arquivos suspeitos
            local suspicious_files=$(echo "$zip_content" | grep -i -E "\.(exe|scr|bat|cmd|vbs|js)$")
            if [[ -n "$suspicious_files" ]]; then
                result+="⚠️  Arquivos executáveis encontrados:\n"
                echo "$suspicious_files" | while read -r line; do
                    result+="  - $(echo "$line" | awk '{print $NF}')\n"
                done
            fi
        fi
    fi
    
    echo -e "$result"
}

# Analisar arquivo de texto
analyze_text_file() {
    local file_path="$1"
    local result=""
    
    result+="[📄 Análise de Texto]\n"
    
    # Contar linhas
    local line_count=$(wc -l < "$file_path")
    result+="Linhas: $line_count\n"
    
    # Verificar encoding
    if command -v file &>/dev/null; then
        local encoding=$(file -bi "$file_path" | cut -d'=' -f2)
        result+="Encoding: $encoding\n"
    fi
    
    # Procurar por padrões suspeitos
    local suspicious_patterns=$(grep -i -E "(eval|exec|system|shell_exec|base64_decode)" "$file_path" 2>/dev/null | wc -l)
    if [[ $suspicious_patterns -gt 0 ]]; then
        result+="⚠️  Padrões suspeitos encontrados: $suspicious_patterns\n"
    fi
    
    echo -e "$result"
}

# Verificar assinaturas de malware
check_malware_signatures() {
    local file_path="$1"
    local result=""
    
    result+="[🦠 Verificação de Assinaturas]\n"
    
    # Ler primeiros bytes do arquivo
    local file_header=$(head -c 1024 "$file_path" | base64 -w 0 2>/dev/null)
    
    local signatures_found=0
    for signature in "${!MALWARE_SIGNATURES[@]}"; do
        if [[ "$file_header" == *"$signature"* ]]; then
            result+="🚨 ASSINATURA DETECTADA: ${MALWARE_SIGNATURES[$signature]}\n"
            signatures_found=$((signatures_found + 1))
        fi
    done
    
    if [[ $signatures_found -eq 0 ]]; then
        result+="✅ Nenhuma assinatura conhecida detectada\n"
    fi
    
    echo -e "$result"
}

# Extrair metadados
extract_metadata() {
    local file_path="$1"
    local result=""
    
    result+="[📊 Metadados]\n"
    
    # Usar exiftool se disponível
    if command -v exiftool &>/dev/null; then
        local metadata=$(exiftool "$file_path" 2>/dev/null | head -10)
        if [[ -n "$metadata" ]]; then
            result+="$metadata\n"
        fi
    else
        result+="ExifTool não disponível para extração de metadados\n"
    fi
    
    echo -e "$result"
}

# Verificar em APIs externas
check_external_apis() {
    local file_path="$1"
    local result=""
    
    result+="[🌐 Verificação Externa]\n"
    
    # Calcular SHA256 para consultas
    local sha256_hash=$(sha256sum "$file_path" | cut -d ' ' -f 1)
    
    # VirusTotal
    if is_api_configured "virustotal"; then
        result+="$(check_virustotal_file "$sha256_hash")\n"
    else
        result+="VirusTotal: API não configurada\n"
    fi
    
    # Hybrid Analysis
    if is_api_configured "hybrid"; then
        result+="$(check_hybrid_analysis "$sha256_hash")\n"
    else
        result+="Hybrid Analysis: API não configurada\n"
    fi
    
    echo -e "$result"
}

# Verificar arquivo no VirusTotal
check_virustotal_file() {
    local file_hash="$1"
    local result=""
    
    local response=$(make_api_request "virustotal" "$VIRUSTOTAL_API_URL/files/$file_hash")
    
    if [[ -n "$response" ]]; then
        local malicious=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.malicious // 0' 2>/dev/null)
        local suspicious=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.suspicious // 0' 2>/dev/null)
        local total=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats | add // 0' 2>/dev/null)
        
        if [[ "$malicious" != "null" && "$malicious" != "0" ]]; then
            result+="🚨 VirusTotal: $malicious/$total engines detectaram como malicioso"
        elif [[ "$suspicious" != "null" && "$suspicious" != "0" ]]; then
            result+="⚠️  VirusTotal: $suspicious/$total engines marcaram como suspeito"
        else
            result+="✅ VirusTotal: Arquivo limpo (0/$total detecções)"
        fi
    else
        result+="VirusTotal: Hash não encontrado na base de dados"
    fi
    
    echo "$result"
}

# Calcular nível de risco
calculate_risk_level() {
    local file_path="$1"
    local risk_score=0
    
    # Verificar extensão perigosa
    local extension="${file_path##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    [[ -n "${DANGEROUS_EXTENSIONS[$extension]}" ]] && risk_score=$((risk_score + 30))
    
    # Verificar tamanho suspeito
    local file_size=$(stat -c%s "$file_path" 2>/dev/null || echo "0")
    [[ $file_size -gt 50000000 ]] && risk_score=$((risk_score + 10))  # > 50MB
    [[ $file_size -lt 1000 ]] && risk_score=$((risk_score + 15))      # < 1KB
    
    # Verificar tipo MIME
    local mime_type=$(file -b --mime-type "$file_path" 2>/dev/null)
    case "$mime_type" in
        "application/x-executable"|"application/x-dosexec")
            risk_score=$((risk_score + 25))
            ;;
        "application/javascript"|"text/x-shellscript")
            risk_score=$((risk_score + 20))
            ;;
    esac
    
    # Determinar nível baseado na pontuação
    if [[ $risk_score -ge 50 ]]; then
        echo "ALTO"
    elif [[ $risk_score -ge 25 ]]; then
        echo "MÉDIO"
    else
        echo "BAIXO"
    fi
}

# Gerar avaliação de risco
generate_risk_assessment() {
    local risk_level="$1"
    local result=""
    
    result+="[⚖️  Avaliação de Risco]\n"
    
    case "$risk_level" in
        "ALTO")
            result+="🔴 RISCO ALTO - Arquivo potencialmente perigoso\n"
            result+="   Recomendação: NÃO EXECUTAR\n"
            ;;
        "MÉDIO")
            result+="🟡 RISCO MÉDIO - Arquivo requer atenção\n"
            result+="   Recomendação: Analisar com cuidado\n"
            ;;
        "BAIXO")
            result+="🟢 RISCO BAIXO - Arquivo aparentemente seguro\n"
            result+="   Recomendação: Verificação adicional recomendada\n"
            ;;
    esac
    
    echo -e "$result"
}

# Gerar recomendações específicas
generate_file_recommendations() {
    local risk_level="$1"
    local result=""
    
    result+="[💡 Recomendações]\n"
    
    case "$risk_level" in
        "ALTO")
            result+="• Isole o arquivo em quarentena\n"
            result+="• Execute análise em ambiente sandbox\n"
            result+="• Verifique outros arquivos do mesmo diretório\n"
            result+="• Execute varredura completa do sistema\n"
            ;;
        "MÉDIO")
            result+="• Analise o arquivo com antivírus atualizado\n"
            result+="• Verifique a origem do arquivo\n"
            result+="• Execute em ambiente isolado se necessário\n"
            ;;
        "BAIXO")
            result+="• Mantenha antivírus atualizado\n"
            result+="• Monitore comportamento se executado\n"
            result+="• Verifique assinatura digital se aplicável\n"
            ;;
    esac
    
    echo -e "$result"
}
