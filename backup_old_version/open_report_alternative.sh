#!/bin/bash

echo "🌐 ABERTURA ALTERNATIVA DE RELATÓRIO"
echo "===================================="
echo

# Encontrar o último relatório
reports_dir="$HOME/.security_analyzer/reports"
latest_report=$(find "$reports_dir" -name "*.html" -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)

if [[ -f "$latest_report" ]]; then
    report_name=$(basename "$latest_report")
    echo "📄 Relatório encontrado: $report_name"
    
    # Iniciar servidor se não estiver rodando
    if ! pgrep -f "python.*8080" >/dev/null; then
        echo "🚀 Iniciando servidor web..."
        cd "$reports_dir"
        python3 -m http.server 8080 > /dev/null 2>&1 &
        sleep 3
    else
        echo "✅ Servidor já está rodando"
    fi
    
    report_url="http://localhost:8080/$report_name"
    
    echo "🌐 URL do relatório: $report_url"
    echo
    
    # Múltiplas tentativas de abertura
    echo "🚀 Tentando abrir o relatório..."
    
    # Tentativa 1: xdg-open
    echo "1. Tentando com xdg-open..."
    if command -v xdg-open &>/dev/null; then
        xdg-open "$report_url" &
        sleep 2
        echo "   ✅ Comando executado"
    else
        echo "   ❌ xdg-open não disponível"
    fi
    
    # Tentativa 2: Firefox direto
    echo "2. Tentando com Firefox..."
    if command -v firefox &>/dev/null; then
        firefox --new-tab "$report_url" &
        sleep 2
        echo "   ✅ Comando executado"
    else
        echo "   ❌ Firefox não disponível"
    fi
    
    # Tentativa 3: Chrome direto
    echo "3. Tentando com Google Chrome..."
    if command -v google-chrome &>/dev/null; then
        google-chrome --new-tab "$report_url" &
        sleep 2
        echo "   ✅ Comando executado"
    else
        echo "   ❌ Google Chrome não disponível"
    fi
    
    echo
    echo "📋 INSTRUÇÕES MANUAIS:"
    echo "======================================"
    echo "Se o navegador não abriu automaticamente:"
    echo
    echo "1. 🌐 Abra seu navegador manualmente"
    echo "2. 📋 Cole esta URL na barra de endereços:"
    echo "   $report_url"
    echo "3. ⏎ Pressione ENTER"
    echo
    echo "📊 O relatório deve exibir:"
    echo "   - Cabeçalho: Security Analyzer - Relatório Detalhado"
    echo "   - Seções coloridas com informações da análise"
    echo "   - Layout profissional e responsivo"
    echo
    echo "🔍 Se a página não carregar:"
    echo "   - Verifique se a URL está correta"
    echo "   - Tente atualizar a página (F5)"
    echo "   - Verifique se o servidor está rodando"
    echo
    echo "⏰ O servidor ficará ativo. Para parar:"
    echo "   pkill -f 'python.*8080'"
    
else
    echo "❌ Nenhum relatório encontrado"
    echo "💡 Execute uma análise primeiro:"
    echo "   ./security_tool.sh → Opção 3 → Digite um domínio"
fi
