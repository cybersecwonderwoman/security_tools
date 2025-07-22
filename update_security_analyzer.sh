#!/bin/bash

# Script para modificar o security_analyzer.sh para abrir relatórios em localhost

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" ]; then
    echo "Erro: O arquivo security_analyzer.sh não foi encontrado!"
    exit 1
fi

# Verificar se o script generate_markdown_report.sh existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/generate_markdown_report.sh" ]; then
    echo "Erro: O arquivo generate_markdown_report.sh não foi encontrado!"
    exit 1
fi

# Verificar se o script serve_report.sh existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/serve_report.sh" ]; then
    echo "Erro: O arquivo serve_report.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak"

# Modificar a função main() para capturar a saída e gerar relatório em Markdown
sed -i '/^main() {/,/^}/ s/echo -e "\\n${GREEN}Análise concluída. Log salvo em: $LOG_FILE${NC}"/echo -e "\\n${GREEN}Análise concluída. Log salvo em: $LOG_FILE${NC}"\\n\\n# Gerar e abrir relatório em Markdown\\nif [[ -f "$(dirname "$0")\/generate_markdown_report.sh" ]]; then\\n    source "$(dirname "$0")\/generate_markdown_report.sh"\\n    local markdown_content=$(generate_markdown_report "$analysis_type" "$analysis_target" "$analysis_output")\\n    "$(dirname "$0")\/serve_report.sh" "$markdown_content"\\nfi/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Adicionar variáveis para capturar o tipo de análise, alvo e saída
sed -i '/^main() {/a \    local analysis_type="Análise de Segurança"\n    local analysis_target=""\n    local analysis_output=""' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

echo "Script security_analyzer.sh modificado com sucesso!"
echo "Agora ele abrirá uma página localhost com os relatórios em Markdown."
