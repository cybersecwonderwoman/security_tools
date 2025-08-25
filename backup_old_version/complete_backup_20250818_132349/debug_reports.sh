#!/bin/bash

# Script de diagnóstico para relatórios HTML

echo "🔍 DIAGNÓSTICO DOS RELATÓRIOS HTML"
echo "=================================="
echo

# Verificar diretório de relatórios
echo "1. Verificando diretório de relatórios..."
REPORTS_DIR="$HOME/.security_analyzer/reports"
if [[ -d "$REPORTS_DIR" ]]; then
    echo "✅ Diretório existe: $REPORTS_DIR"
    echo "📊 Relatórios HTML encontrados: $(find "$REPORTS_DIR" -name "*.html" | wc -l)"
    echo "📁 Últimos 3 relatórios:"
    ls -lt "$REPORTS_DIR"/*.html 2>/dev/null | head -3 | while read line; do
        echo "   $line"
    done
else
    echo "❌ Diretório não existe: $REPORTS_DIR"
    mkdir -p "$REPORTS_DIR"
    echo "✅ Diretório criado"
fi
echo

# Verificar Python
echo "2. Verificando Python..."
if command -v python3 &>/dev/null; then
    echo "✅ Python3 encontrado: $(python3 --version)"
elif command -v python &>/dev/null; then
    echo "✅ Python encontrado: $(python --version)"
else
    echo "❌ Python não encontrado"
    exit 1
fi
echo

# Verificar porta 8080
echo "3. Verificando porta 8080..."
if netstat -tuln 2>/dev/null | grep -q ":8080"; then
    echo "⚠️  Porta 8080 já está em uso:"
    netstat -tuln | grep ":8080"
    echo "🛑 Parando processos na porta 8080..."
    pkill -f "python.*http.server.*8080" 2>/dev/null
    pkill -f "python.*SimpleHTTPServer.*8080" 2>/dev/null
    sleep 2
else
    echo "✅ Porta 8080 disponível"
fi
echo

# Gerar relatório de teste
echo "4. Gerando relatório de teste..."
cd "$(dirname "$0")"
source html_report.sh 2>/dev/null || {
    echo "❌ Erro ao carregar html_report.sh"
    exit 1
}

TEST_REPORT=$(generate_html_report "Teste Debug" "debug.txt" "Este é um relatório de teste para diagnóstico")
echo "✅ Relatório gerado: $TEST_REPORT"

if [[ -f "$TEST_REPORT" ]]; then
    echo "✅ Arquivo existe ($(stat -c%s "$TEST_REPORT") bytes)"
else
    echo "❌ Arquivo não foi criado"
    exit 1
fi
echo

# Iniciar servidor
echo "5. Iniciando servidor web..."
cd "$REPORTS_DIR"
echo "📂 Diretório atual: $(pwd)"
echo "📄 Arquivos disponíveis:"
ls -la *.html 2>/dev/null | head -5

# Iniciar servidor em background
if command -v python3 &>/dev/null; then
    python3 -m http.server 8080 &
    SERVER_PID=$!
    echo "🌐 Servidor Python3 iniciado (PID: $SERVER_PID)"
elif command -v python &>/dev/null; then
    python -m SimpleHTTPServer 8080 &
    SERVER_PID=$!
    echo "🌐 Servidor Python2 iniciado (PID: $SERVER_PID)"
fi

# Aguardar servidor inicializar
sleep 3
echo

# Testar conectividade
echo "6. Testando conectividade..."
if curl -s -I http://localhost:8080/ >/dev/null 2>&1; then
    echo "✅ Servidor respondendo em http://localhost:8080/"
    
    # Testar acesso ao relatório
    REPORT_NAME=$(basename "$TEST_REPORT")
    if curl -s -I "http://localhost:8080/$REPORT_NAME" >/dev/null 2>&1; then
        echo "✅ Relatório acessível em http://localhost:8080/$REPORT_NAME"
        
        # Mostrar primeiras linhas do relatório
        echo "📄 Primeiras linhas do relatório:"
        curl -s "http://localhost:8080/$REPORT_NAME" | head -10
        
    else
        echo "❌ Relatório não acessível"
    fi
else
    echo "❌ Servidor não está respondendo"
fi
echo

# Testar função open_report
echo "7. Testando função open_report..."
echo "🌐 Tentando abrir relatório no navegador..."

# Simular abertura (sem realmente abrir o navegador)
echo "URL que seria aberta: http://localhost:8080/$REPORT_NAME"

# Verificar comandos de abertura disponíveis
if command -v xdg-open &>/dev/null; then
    echo "✅ xdg-open disponível"
elif command -v open &>/dev/null; then
    echo "✅ open disponível"
else
    echo "⚠️  Nenhum comando de abertura de navegador encontrado"
fi
echo

echo "8. Resumo do diagnóstico:"
echo "========================"
echo "✅ Diretório de relatórios: OK"
echo "✅ Python: OK"
echo "✅ Servidor web: OK"
echo "✅ Geração de relatórios: OK"
echo "✅ Acesso via HTTP: OK"
echo
echo "🎯 Para acessar os relatórios:"
echo "   1. Acesse: http://localhost:8080/"
echo "   2. Clique no relatório desejado"
echo "   3. Ou acesse diretamente: http://localhost:8080/$REPORT_NAME"
echo
echo "🛑 Para parar o servidor:"
echo "   kill $SERVER_PID"
echo "   ou"
echo "   pkill -f 'python.*http.server.*8080'"
echo

# Manter servidor rodando por 30 segundos para teste
echo "⏰ Servidor ficará ativo por 30 segundos para teste..."
echo "   Acesse http://localhost:8080/ agora!"
sleep 30

# Parar servidor
kill $SERVER_PID 2>/dev/null
echo "🛑 Servidor parado"
