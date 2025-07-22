#!/bin/bash

# ========================================
# Markdown Report Server - Servidor de Relatórios em Markdown
# ========================================

# Verifica se o markdown foi fornecido
if [ -z "$1" ]; then
    echo "Uso: $0 <conteúdo_markdown>"
    exit 1
fi

# Cria um arquivo temporário para o HTML
TEMP_HTML=$(mktemp --suffix=.html)
TEMP_MD=$(mktemp --suffix=.md)

# Salva o markdown no arquivo temporário
echo "$1" > "$TEMP_MD"

# Converte o markdown para HTML
cat > "$TEMP_HTML" << EOF
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
        // Carregar o conteúdo do markdown
        fetch('$TEMP_MD')
            .then(response => response.text())
            .then(text => {
                document.getElementById('content').innerHTML = marked.parse(text);
                
                // Aplicar classes de risco
                const riskElements = document.querySelectorAll('strong:contains("BAIXO"), strong:contains("MÉDIO"), strong:contains("ALTO"), strong:contains("CRÍTICO")');
                riskElements.forEach(el => {
                    if (el.textContent.includes('BAIXO')) {
                        el.classList.add('risk-low');
                    } else if (el.textContent.includes('MÉDIO')) {
                        el.classList.add('risk-medium');
                    } else if (el.textContent.includes('ALTO')) {
                        el.classList.add('risk-high');
                    } else if (el.textContent.includes('CRÍTICO')) {
                        el.classList.add('risk-critical');
                    }
                });
            });
    </script>
</body>
</html>
EOF

# Determina uma porta disponível
PORT=8000
while nc -z localhost $PORT 2>/dev/null; do
    PORT=$((PORT+1))
done

echo "Iniciando servidor na porta $PORT..."
echo "Acesse: http://localhost:$PORT"
echo "Pressione Ctrl+C para encerrar o servidor"

# Inicia um servidor web simples
cd "$(dirname "$TEMP_HTML")"
python3 -m http.server $PORT 2>/dev/null || python -m SimpleHTTPServer $PORT 2>/dev/null

# Limpa os arquivos temporários ao sair
trap 'rm -f "$TEMP_HTML" "$TEMP_MD"' EXIT
