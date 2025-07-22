#!/bin/bash

# ========================================
# Markdown Report Generator - Gerador de Relatórios em Markdown
# ========================================

# Função para converter resultados da análise para Markdown
generate_markdown_report() {
    local analysis_type="$1"
    local target="$2"
    local analysis_output="$3"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    # Criar cabeçalho do relatório
    local markdown_content=$(cat << EOF
# Relatório de Análise de Segurança

## Informações Gerais

**Tipo de Análise:** $analysis_type  
**Alvo:** $target  
**Data e Hora:** $timestamp  

## Resultados da Análise

\`\`\`
$analysis_output
\`\`\`

---

*Relatório gerado pelo Security Analyzer Tool*
EOF
)

    echo "$markdown_content"
}

# Exportar função
export -f generate_markdown_report
