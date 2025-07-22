#!/bin/bash

# Script para modificar as funções de análise do security_analyzer.sh

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" ]; then
    echo "Erro: O arquivo security_analyzer.sh não foi encontrado!"
    exit 1
fi

# Modificar a função analyze_file
sed -i '/^analyze_file() {/,/^}/ s/log_message "Arquivo analisado: $filepath (MD5: $md5_hash, SHA256: $sha256_hash)"/analysis_type="Análise de Arquivo"\n    analysis_target="$filepath"\n    analysis_output=$(cat "$LOG_FILE" | tail -n 20)\n    log_message "Arquivo analisado: $filepath (MD5: $md5_hash, SHA256: $sha256_hash)"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_url
sed -i '/^analyze_url() {/,/^}/ s/log_message "URL analisada: $url"/analysis_type="Análise de URL"\n    analysis_target="$url"\n    analysis_output=$(cat "$LOG_FILE" | tail -n 20)\n    log_message "URL analisada: $url"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_domain
sed -i '/^analyze_domain() {/,/^}/ s/log_message "Domínio analisado: $domain"/analysis_type="Análise de Domínio"\n    analysis_target="$domain"\n    analysis_output=$(cat "$LOG_FILE" | tail -n 20)\n    log_message "Domínio analisado: $domain"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_hash
sed -i '/^analyze_hash() {/,/^}/ s/log_message "Hash analisado: $hash ($hash_type)"/analysis_type="Análise de Hash"\n    analysis_target="$hash"\n    analysis_output=$(cat "$LOG_FILE" | tail -n 20)\n    log_message "Hash analisado: $hash ($hash_type)"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_email
sed -i '/^analyze_email() {/,/^}/ s/log_message "Email analisado: $email"/analysis_type="Análise de Email"\n    analysis_target="$email"\n    analysis_output=$(cat "$LOG_FILE" | tail -n 20)\n    log_message "Email analisado: $email"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_email_header
sed -i '/^analyze_email_header() {/,/^}/ s/log_message "Cabeçalho de email analisado: $header_file (Ameaças: $suspicious_count)"/analysis_type="Análise de Cabeçalho de Email"\n    analysis_target="$header_file"\n    analysis_output=$(cat "$LOG_FILE" | tail -n 20)\n    log_message "Cabeçalho de email analisado: $header_file (Ameaças: $suspicious_count)"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

echo "Funções de análise modificadas com sucesso!"
