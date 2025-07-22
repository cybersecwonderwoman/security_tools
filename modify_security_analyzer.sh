#!/bin/bash

# Script para modificar o security_analyzer.sh para abrir relatórios em localhost

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" ]; then
    echo "Erro: O arquivo security_analyzer.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/security_analyzer.sh.bak"

# Adicionar variável para o diretório de relatórios
sed -i '/^CONFIG_DIR="$HOME\/.security_analyzer"/a REPORTS_DIR="$CONFIG_DIR\/reports"\nmkdir -p "$REPORTS_DIR"' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Adicionar função para gerar relatório em Markdown
cat >> "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh" << 'EOF'

# Função para gerar relatório em Markdown
generate_markdown_report() {
    local analysis_type="$1"
    local target="$2"
    local log_content="$3"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local report_file="$REPORTS_DIR/report_$(date '+%Y%m%d_%H%M%S').md"
    
    # Criar conteúdo do relatório
    cat > "$report_file" << EOL
# Relatório de Análise de Segurança

## Informações Gerais

**Tipo de Análise:** $analysis_type  
**Alvo:** $target  
**Data e Hora:** $timestamp  

## Resultados da Análise

\`\`\`
$log_content
\`\`\`

---

*Relatório gerado pelo Security Analyzer Tool*
EOL
    
    echo "$report_file"
}

# Função para abrir relatório no navegador
open_report_in_browser() {
    local report_file="$1"
    local html_file="${report_file%.md}.html"
    
    # Converter Markdown para HTML
    cat > "$html_file" << EOL
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Relatório de Segurança</title>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #24292e;
            max-width: 980px;
            margin: 0 auto;
            padding: 45px;
        }
        .markdown-body {
            box-sizing: border-box;
            min-width: 200px;
            max-width: 980px;
            margin: 0 auto;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            color: #0366d6;
        }
        .risk-low {
            color: #28a745;
            font-weight: bold;
        }
        .risk-medium {
            color: #f9c513;
            font-weight: bold;
        }
        .risk-high {
            color: #d73a49;
            font-weight: bold;
        }
        .risk-critical {
            color: #d73a49;
            font-weight: bold;
            text-transform: uppercase;
        }
        @media print {
            body {
                padding: 0;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Relatório de Análise de Segurança</h1>
        <p>Gerado em: $(date '+%d/%m/%Y %H:%M:%S')</p>
    </div>
    <div id="content" class="markdown-body"></div>

    <script>
        fetch('$(basename "$report_file")')
            .then(response => response.text())
            .then(text => {
                document.getElementById('content').innerHTML = marked.parse(text);
            });
    </script>
</body>
</html>
EOL
    
    # Determinar uma porta disponível
    local PORT=8000
    while nc -z localhost $PORT 2>/dev/null; do
        PORT=$((PORT+1))
    done
    
    echo -e "${GREEN}Abrindo relatório no navegador...${NC}"
    echo -e "${GREEN}URL: http://localhost:$PORT/${html_file##*/}${NC}"
    
    # Iniciar servidor web em segundo plano
    (cd "$(dirname "$html_file")" && python3 -m http.server $PORT > /dev/null 2>&1 &)
    
    # Abrir navegador
    if command -v xdg-open > /dev/null; then
        xdg-open "http://localhost:$PORT/${html_file##*/}" > /dev/null 2>&1
    elif command -v open > /dev/null; then
        open "http://localhost:$PORT/${html_file##*/}" > /dev/null 2>&1
    else
        echo -e "${YELLOW}Não foi possível abrir o navegador automaticamente.${NC}"
        echo -e "${YELLOW}Acesse: http://localhost:$PORT/${html_file##*/}${NC}"
    fi
}
EOF

# Modificar a função analyze_file para gerar relatório
sed -i '/^analyze_file() {/,/^}/ s/log_message "Arquivo analisado: $filepath (MD5: $md5_hash, SHA256: $sha256_hash)"/log_message "Arquivo analisado: $filepath (MD5: $md5_hash, SHA256: $sha256_hash)"\n    \n    # Gerar e abrir relatório\n    local log_content=$(tail -n 50 "$LOG_FILE")\n    local report_file=$(generate_markdown_report "Análise de Arquivo" "$filepath" "$log_content")\n    open_report_in_browser "$report_file"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_url para gerar relatório
sed -i '/^analyze_url() {/,/^}/ s/log_message "URL analisada: $url"/log_message "URL analisada: $url"\n    \n    # Gerar e abrir relatório\n    local log_content=$(tail -n 50 "$LOG_FILE")\n    local report_file=$(generate_markdown_report "Análise de URL" "$url" "$log_content")\n    open_report_in_browser "$report_file"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_domain para gerar relatório
sed -i '/^analyze_domain() {/,/^}/ s/log_message "Domínio analisado: $domain"/log_message "Domínio analisado: $domain"\n    \n    # Gerar e abrir relatório\n    local log_content=$(tail -n 50 "$LOG_FILE")\n    local report_file=$(generate_markdown_report "Análise de Domínio" "$domain" "$log_content")\n    open_report_in_browser "$report_file"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_hash para gerar relatório
sed -i '/^analyze_hash() {/,/^}/ s/log_message "Hash analisado: $hash ($hash_type)"/log_message "Hash analisado: $hash ($hash_type)"\n    \n    # Gerar e abrir relatório\n    local log_content=$(tail -n 50 "$LOG_FILE")\n    local report_file=$(generate_markdown_report "Análise de Hash" "$hash" "$log_content")\n    open_report_in_browser "$report_file"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_email para gerar relatório
sed -i '/^analyze_email() {/,/^}/ s/log_message "Email analisado: $email"/log_message "Email analisado: $email"\n    \n    # Gerar e abrir relatório\n    local log_content=$(tail -n 50 "$LOG_FILE")\n    local report_file=$(generate_markdown_report "Análise de Email" "$email" "$log_content")\n    open_report_in_browser "$report_file"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

# Modificar a função analyze_email_header para gerar relatório
sed -i '/^analyze_email_header() {/,/^}/ s/log_message "Cabeçalho de email analisado: $header_file (Ameaças: $suspicious_count)"/log_message "Cabeçalho de email analisado: $header_file (Ameaças: $suspicious_count)"\n    \n    # Gerar e abrir relatório\n    local log_content=$(tail -n 50 "$LOG_FILE")\n    local report_file=$(generate_markdown_report "Análise de Cabeçalho de Email" "$header_file" "$log_content")\n    open_report_in_browser "$report_file"/' "/home/anny-ribeiro/amazonQ/app/security_analyzer.sh"

echo "Script security_analyzer.sh modificado com sucesso!"
echo "Agora ele abrirá uma página localhost com os relatórios em Markdown."
