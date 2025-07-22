#!/bin/bash

# Script para corrigir o problema de múltiplos relatórios

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" ]; then
    echo "Erro: O arquivo security_analyzer.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak_fix"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak_fix"

# Modificar a função analyze_file para usar apenas o relatório aprimorado
sed -i '/^analyze_file() {/,/^}/ s/# Gerar e abrir relatório aprimorado.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de Arquivo" "$filepath" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_url para usar apenas o relatório aprimorado
sed -i '/^analyze_url() {/,/^}/ s/# Gerar e abrir relatório aprimorado.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de URL" "$url" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_domain para usar apenas o relatório aprimorado
sed -i '/^analyze_domain() {/,/^}/ s/# Gerar e abrir relatório aprimorado.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de Domínio" "$domain" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_hash para usar apenas o relatório aprimorado
sed -i '/^analyze_hash() {/,/^}/ s/# Gerar e abrir relatório aprimorado.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de Hash" "$hash" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_email para usar apenas o relatório aprimorado
sed -i '/^analyze_email() {/,/^}/ s/# Gerar e abrir relatório aprimorado.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de Email" "$email" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_email_header para usar apenas o relatório aprimorado
sed -i '/^analyze_email_header() {/,/^}/ s/# Gerar e abrir relatório aprimorado.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de Cabeçalho de Email" "$header_file" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

echo "Script security_analyzer.sh corrigido com sucesso!"
echo "Agora ele abrirá apenas um relatório aprimorado por análise."
