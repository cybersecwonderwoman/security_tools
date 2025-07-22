#!/bin/bash

# Script para atualizar o security_analyzer.sh para usar o relatório simplificado

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" ]; then
    echo "Erro: O arquivo security_analyzer.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak_simple"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak_simple"

# Modificar a função main para carregar o script de relatório simplificado
sed -i '/^main() {/a \
    # Carregar script de relatório simplificado\
    if [[ -f "$(dirname "$0")/simple_enhanced_report.sh" ]]; then\
        source "$(dirname "$0")/simple_enhanced_report.sh"\
    fi' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_file para usar o relatório simplificado
sed -i '/^analyze_file() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório\n    if declare -f generate_and_show_report > \/dev\/null; then\n        generate_and_show_report "Análise de Arquivo" "$filepath" "$LOG_FILE"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_url para usar o relatório simplificado
sed -i '/^analyze_url() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório\n    if declare -f generate_and_show_report > \/dev\/null; then\n        generate_and_show_report "Análise de URL" "$url" "$LOG_FILE"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_domain para usar o relatório simplificado
sed -i '/^analyze_domain() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório\n    if declare -f generate_and_show_report > \/dev\/null; then\n        generate_and_show_report "Análise de Domínio" "$domain" "$LOG_FILE"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_hash para usar o relatório simplificado
sed -i '/^analyze_hash() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório\n    if declare -f generate_and_show_report > \/dev\/null; then\n        generate_and_show_report "Análise de Hash" "$hash" "$LOG_FILE"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_email para usar o relatório simplificado
sed -i '/^analyze_email() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório\n    if declare -f generate_and_show_report > \/dev\/null; then\n        generate_and_show_report "Análise de Email" "$email" "$LOG_FILE"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_email_header para usar o relatório simplificado
sed -i '/^analyze_email_header() {/,/^}/ s/# Gerar e abrir relatório.*$/# Gerar e abrir relatório\n    if declare -f generate_and_show_report > \/dev\/null; then\n        generate_and_show_report "Análise de Cabeçalho de Email" "$header_file" "$LOG_FILE"\n    fi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

echo "Script security_analyzer.sh atualizado com sucesso para usar o relatório simplificado!"
echo "Agora ele abrirá uma única página localhost com um relatório visualmente atraente."
