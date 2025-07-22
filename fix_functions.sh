#!/bin/bash

# Script para corrigir as funções no security_analyzer.sh

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" ]; then
    echo "Erro: O arquivo security_analyzer.sh não foi encontrado!"
    exit 1
fi

# Mover as funções para o início do arquivo, logo após as configurações
sed -i '/^# Configurações/a \
# Função para gerar relatório em Markdown\
generate_markdown_report() {\
    local analysis_type="$1"\
    local target="$2"\
    local log_content="$3"\
    local timestamp="$(date '"'"'+%Y-%m-%d %H:%M:%S'"'"')"\
    local report_file="$REPORTS_DIR/report_$(date '"'"'+%Y%m%d_%H%M%S'"'"').md"\
    \
    # Criar conteúdo do relatório\
    cat > "$report_file" << EOL\
# Relatório de Análise de Segurança\
\
## Informações Gerais\
\
**Tipo de Análise:** $analysis_type  \
**Alvo:** $target  \
**Data e Hora:** $timestamp  \
\
## Resultados da Análise\
\
\`\`\`\
$log_content\
\`\`\`\
\
---\
\
*Relatório gerado pelo Security Analyzer Tool*\
EOL\
    \
    echo "$report_file"\
}\
\
# Função para abrir relatório no navegador\
open_report_in_browser() {\
    local report_file="$1"\
    local html_file="${report_file%.md}.html"\
    \
    # Converter Markdown para HTML\
    cat > "$html_file" << EOL\
<!DOCTYPE html>\
<html lang="pt-BR">\
<head>\
    <meta charset="UTF-8">\
    <meta name="viewport" content="width=device-width, initial-scale=1.0">\
    <title>Relatório de Segurança</title>\
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>\
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css">\
    <style>\
        body {\
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;\
            line-height: 1.6;\
            color: #24292e;\
            max-width: 980px;\
            margin: 0 auto;\
            padding: 45px;\
        }\
        .markdown-body {\
            box-sizing: border-box;\
            min-width: 200px;\
            max-width: 980px;\
            margin: 0 auto;\
        }\
        .header {\
            text-align: center;\
            margin-bottom: 30px;\
        }\
        .header h1 {\
            color: #0366d6;\
        }\
        .risk-low {\
            color: #28a745;\
            font-weight: bold;\
        }\
        .risk-medium {\
            color: #f9c513;\
            font-weight: bold;\
        }\
        .risk-high {\
            color: #d73a49;\
            font-weight: bold;\
        }\
        .risk-critical {\
            color: #d73a49;\
            font-weight: bold;\
            text-transform: uppercase;\
        }\
        @media print {\
            body {\
                padding: 0;\
            }\
        }\
    </style>\
</head>\
<body>\
    <div class="header">\
        <h1>Relatório de Análise de Segurança</h1>\
        <p>Gerado em: $(date '"'"'+%d/%m/%Y %H:%M:%S'"'"')</p>\
    </div>\
    <div id="content" class="markdown-body"></div>\
\
    <script>\
        fetch('"'"'$(basename "$report_file")'"'"')\
            .then(response => response.text())\
            .then(text => {\
                document.getElementById('"'"'content'"'"').innerHTML = marked.parse(text);\
            });\
    </script>\
</body>\
</html>\
EOL\
    \
    # Determinar uma porta disponível\
    local PORT=8000\
    while nc -z localhost $PORT 2>/dev/null; do\
        PORT=$((PORT+1))\
    done\
    \
    echo -e "${GREEN}Abrindo relatório no navegador...${NC}"\
    echo -e "${GREEN}URL: http://localhost:$PORT/${html_file##*/}${NC}"\
    \
    # Iniciar servidor web em segundo plano\
    (cd "$(dirname "$html_file")" && python3 -m http.server $PORT > /dev/null 2>&1 &)\
    \
    # Abrir navegador\
    if command -v xdg-open > /dev/null; then\
        xdg-open "http://localhost:$PORT/${html_file##*/}" > /dev/null 2>&1\
    elif command -v open > /dev/null; then\
        open "http://localhost:$PORT/${html_file##*/}" > /dev/null 2>&1\
    else\
        echo -e "${YELLOW}Não foi possível abrir o navegador automaticamente.${NC}"\
        echo -e "${YELLOW}Acesse: http://localhost:$PORT/${html_file##*/}${NC}"\
    fi\
}' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Remover as funções duplicadas do final do arquivo
sed -i '/^# Função para gerar relatório em Markdown$/,/^}$/d' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"
sed -i '/^# Função para abrir relatório no navegador$/,/^}$/d' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

echo "Funções corrigidas com sucesso!"
