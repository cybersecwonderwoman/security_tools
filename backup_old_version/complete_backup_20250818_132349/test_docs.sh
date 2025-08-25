#!/bin/bash

# Script para testar a função de documentação

# Configurações
DOCS_DIR="$HOME/.security_analyzer/docs"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}📚 TESTANDO DOCUMENTAÇÃO${NC}"
echo ""

# Criar diretório de documentação se não existir
mkdir -p "$DOCS_DIR"

# Copiar README.md para o diretório de documentação
cp "$SCRIPT_DIR/README.md" "$DOCS_DIR/index.md"

# Criar um arquivo HTML simples que carrega o README.md
cat > "$DOCS_DIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Security Analyzer Tool - Documentação</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
        }
        h1, h2, h3 {
            color: #2c3e50;
        }
        pre {
            background-color: #f5f5f5;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }
        code {
            background-color: #f5f5f5;
            padding: 2px 4px;
            border-radius: 3px;
        }
        table {
            border-collapse: collapse;
            width: 100%;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>🛡️ Security Analyzer Tool</h1>
    <p>Carregando documentação...</p>
    <div id="content"></div>

    <script>
        // Função para carregar o conteúdo do README.md
        fetch('index.md')
            .then(response => response.text())
            .then(text => {
                // Exibir o conteúdo como texto pré-formatado
                document.getElementById('content').innerHTML = '<pre>' + text + '</pre>';
            })
            .catch(error => {
                console.error('Erro ao carregar a documentação:', error);
                document.getElementById('content').innerHTML = '<p>Erro ao carregar a documentação.</p>';
            });
    </script>
</body>
</html>
EOF

# Copiar outros arquivos de documentação
for doc_file in "$SCRIPT_DIR"/*.md; do
    if [[ -f "$doc_file" ]]; then
        cp "$doc_file" "$DOCS_DIR/"
    fi
done

# Parar qualquer servidor existente
pkill -f "python3 -m http.server 8000" || true

# Iniciar servidor HTTP
echo -e "${GREEN}Iniciando servidor de documentação na porta 8000...${NC}"
python3 -m http.server 8000 --directory "$DOCS_DIR" &

# Aguardar um momento para o servidor iniciar
sleep 2

echo -e "${GREEN}Servidor iniciado! Acesse http://localhost:8000 no seu navegador${NC}"

# Abrir navegador
if command -v xdg-open &> /dev/null; then
    xdg-open http://localhost:8000
elif command -v open &> /dev/null; then
    open http://localhost:8000
else
    echo -e "${YELLOW}Não foi possível abrir o navegador automaticamente.${NC}"
    echo -e "${YELLOW}Por favor, acesse http://localhost:8000 manualmente.${NC}"
fi

echo ""
echo -e "${GREEN}Documentação disponível em: http://localhost:8000${NC}"
echo -e "${YELLOW}Pressione ENTER para parar o servidor e sair...${NC}"
read

# Parar o servidor
pkill -f "python3 -m http.server 8000" || true
echo -e "${GREEN}Servidor parado!${NC}"
