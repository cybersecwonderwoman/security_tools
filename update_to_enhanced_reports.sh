#!/bin/bash

# Script para atualizar o security_analyzer.sh para usar relatórios aprimorados

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" ]; then
    echo "Erro: O arquivo security_analyzer.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak_enhanced"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak_enhanced"

# Modificar a função main para carregar as funções de relatório aprimorado
sed -i '/^main() {/a \
    # Carregar funções de relatório aprimorado em Markdown\
    if [[ -f "$(dirname "$0")/enhanced_report_functions.sh" ]]; then\
        source "$(dirname "$0")/enhanced_report_functions.sh"\
    fi' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_file para usar o relatório aprimorado
sed -i '/^analyze_file() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de Arquivo" "$filepath" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    elif declare -f generate_markdown_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_markdown_report "Análise de Arquivo" "$filepath" "$log_content")\n        open_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_url para usar o relatório aprimorado
sed -i '/^analyze_url() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de URL" "$url" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    elif declare -f generate_markdown_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_markdown_report "Análise de URL" "$url" "$log_content")\n        open_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_domain para usar o relatório aprimorado
sed -i '/^analyze_domain() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de Domínio" "$domain" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    elif declare -f generate_markdown_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_markdown_report "Análise de Domínio" "$domain" "$log_content")\n        open_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_hash para usar o relatório aprimorado
sed -i '/^analyze_hash() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de Hash" "$hash" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    elif declare -f generate_markdown_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_markdown_report "Análise de Hash" "$hash" "$log_content")\n        open_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_email para usar o relatório aprimorado
sed -i '/^analyze_email() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de Email" "$email" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    elif declare -f generate_markdown_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_markdown_report "Análise de Email" "$email" "$log_content")\n        open_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_email_header para usar o relatório aprimorado
sed -i '/^analyze_email_header() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório aprimorado\n    if declare -f generate_enhanced_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_enhanced_report "Análise de Cabeçalho de Email" "$header_file" "$log_content")\n        open_enhanced_report_in_browser "$report_file"\n    elif declare -f generate_markdown_report > \/dev\/null; then\n        local log_content=$(cat "$LOG_FILE" | tail -n 50)\n        local report_file=$(generate_markdown_report "Análise de Cabeçalho de Email" "$header_file" "$log_content")\n        open_report_in_browser "$report_file"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

echo "Script security_analyzer.sh atualizado com sucesso para usar relatórios aprimorados!"
echo "Agora ele abrirá uma página localhost com relatórios mais detalhados e visualmente atraentes."
