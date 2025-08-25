#!/bin/bash

echo "🧪 TESTE DIRETO DA FUNÇÃO OPEN_REPORT"
echo "====================================="
echo

# Carregar as funções
echo "📚 Carregando funções..."
source html_report.sh
source report_integration.sh

# Verificar se as funções foram carregadas
if declare -f open_report >/dev/null 2>&1; then
    echo "✅ Função open_report carregada"
else
    echo "❌ Função open_report não encontrada"
    exit 1
fi

# Encontrar um relatório para testar
echo "🔍 Procurando relatórios..."
reports_dir="$HOME/.security_analyzer/reports"
report_file=$(find "$reports_dir" -name "*.html" -type f | head -1)

if [[ -z "$report_file" ]]; then
    echo "❌ Nenhum relatório HTML encontrado"
    echo "📄 Gerando relatório de teste..."
    report_file=$(generate_html_report "Teste Direto" "teste_direto.txt" "Teste da função open_report")
    echo "✅ Relatório gerado: $report_file"
fi

echo "📄 Usando relatório: $(basename "$report_file")"
echo

# Parar qualquer servidor existente
echo "🛑 Parando servidores existentes..."
pkill -f "python.*8080" 2>/dev/null
sleep 2

# Testar a função open_report diretamente
echo "🚀 Testando função open_report..."
echo "================================="

# Executar com output detalhado
set -x
open_report "$report_file"
set +x

echo
echo "✅ Teste da função open_report concluído"
echo

# Verificar se o servidor está rodando
echo "🔍 Verificando servidor..."
if pgrep -f "python.*8080" >/dev/null; then
    echo "✅ Servidor está rodando"
    
    # Testar acesso
    report_name=$(basename "$report_file")
    url="http://localhost:8080/$report_name"
    
    if curl -s -I "$url" >/dev/null 2>&1; then
        echo "✅ Relatório acessível em: $url"
        
        # Mostrar primeiras linhas
        echo "📄 Primeiras linhas do relatório:"
        curl -s "$url" | head -5
        
    else
        echo "❌ Relatório não acessível via HTTP"
    fi
else
    echo "❌ Servidor não está rodando"
fi

echo
echo "🎯 Para testar manualmente:"
echo "   1. Acesse: http://localhost:8080/"
echo "   2. Ou execute: xdg-open http://localhost:8080/$(basename "$report_file")"
echo

# Manter servidor ativo por um tempo
echo "⏰ Mantendo servidor ativo por 30 segundos para teste manual..."
sleep 30

# Parar servidor
pkill -f "python.*8080" 2>/dev/null
echo "🛑 Servidor parado"
