#!/bin/bash

echo "🔧 CORREÇÃO - ABERTURA FORÇADA EM NOVA JANELA"
echo "============================================="
echo

# Backup da função original
cp html_report.sh html_report.sh.backup.browser

# Criar nova versão da função open_report que força nova janela
cat > temp_open_report_fixed.sh << 'EOF'
# Função para abrir o relatório no navegador (versão com nova janela forçada)
open_report() {
    local report_file="$1"
    local report_name=$(basename "$report_file")
    
    echo "🌐 Abrindo relatório: $report_name"
    
    # Verificar se o arquivo existe
    if [[ ! -f "$report_file" ]]; then
        echo "❌ Arquivo de relatório não encontrado: $report_file"
        return 1
    fi
    
    # Verificar se o servidor já está rodando
    if ! pgrep -f "python.*http.server.*$PORT" &>/dev/null && ! pgrep -f "python.*SimpleHTTPServer.*$PORT" &>/dev/null; then
        echo "🚀 Iniciando servidor web..."
        start_report_server
        sleep 2
    else
        echo "✅ Servidor já está rodando"
    fi
    
    # Verificar se o servidor está respondendo
    local max_attempts=5
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -s -I "http://localhost:$PORT/" >/dev/null 2>&1; then
            echo "✅ Servidor respondendo (tentativa $attempt)"
            break
        else
            echo "⏳ Aguardando servidor... (tentativa $attempt)"
            sleep 2
            ((attempt++))
        fi
    done
    
    if [[ $attempt -gt $max_attempts ]]; then
        echo "❌ Servidor não está respondendo após $max_attempts tentativas"
        echo "🔧 Tentando reiniciar servidor..."
        stop_report_server
        sleep 1
        start_report_server
        sleep 3
    fi
    
    # URL do relatório
    local report_url="http://localhost:$PORT/$report_name"
    
    # Verificar se o relatório está acessível
    if curl -s -I "$report_url" >/dev/null 2>&1; then
        echo "✅ Relatório acessível em: $report_url"
        
        # NOVA ABORDAGEM: Tentar múltiplos métodos com nova janela forçada
        local opened=false
        
        # Método 1: Firefox com nova janela
        if command -v firefox &>/dev/null && [[ "$opened" == false ]]; then
            echo "🌐 Tentando abrir com Firefox (nova janela)..."
            if firefox --new-window "$report_url" &>/dev/null & then
                echo "✅ Firefox executado"
                opened=true
                sleep 2
            fi
        fi
        
        # Método 2: Google Chrome com nova janela
        if command -v google-chrome &>/dev/null && [[ "$opened" == false ]]; then
            echo "🌐 Tentando abrir com Google Chrome (nova janela)..."
            if google-chrome --new-window "$report_url" &>/dev/null & then
                echo "✅ Google Chrome executado"
                opened=true
                sleep 2
            fi
        fi
        
        # Método 3: Chromium com nova janela
        if command -v chromium-browser &>/dev/null && [[ "$opened" == false ]]; then
            echo "🌐 Tentando abrir com Chromium (nova janela)..."
            if chromium-browser --new-window "$report_url" &>/dev/null & then
                echo "✅ Chromium executado"
                opened=true
                sleep 2
            fi
        fi
        
        # Método 4: xdg-open como fallback
        if [[ "$opened" == false ]]; then
            echo "🌐 Usando xdg-open como fallback..."
            if command -v xdg-open &>/dev/null; then
                xdg-open "$report_url" &
                echo "✅ xdg-open executado"
                opened=true
            fi
        fi
        
        if [[ "$opened" == true ]]; then
            echo "🎯 Relatório disponível em: $report_url"
            echo ""
            echo "📋 INSTRUÇÕES:"
            echo "   - O navegador deve abrir em NOVA JANELA"
            echo "   - Se não aparecer, verifique a barra de tarefas"
            echo "   - Ou acesse manualmente: $report_url"
            echo "   - Use Alt+Tab para encontrar a janela"
        else
            echo "⚠️  Não foi possível abrir automaticamente"
            echo "📋 Acesse manualmente: $report_url"
        fi
        
        return 0
    else
        echo "❌ Relatório não está acessível via HTTP"
        echo "📁 Arquivo local: $report_file"
        return 1
    fi
}
EOF

# Aplicar correção
start_line=$(grep -n "^open_report()" html_report.sh | cut -d: -f1)
if [[ -n "$start_line" ]]; then
    # Encontrar o final da função
    end_line=$(tail -n +$((start_line + 1)) html_report.sh | grep -n "^}" | head -1 | cut -d: -f1)
    end_line=$((start_line + end_line))
    
    # Criar arquivo temporário com a correção
    head -n $((start_line - 1)) html_report.sh > temp_html_report.sh
    cat temp_open_report_fixed.sh >> temp_html_report.sh
    tail -n +$((end_line + 1)) html_report.sh >> temp_html_report.sh
    
    # Substituir arquivo original
    mv temp_html_report.sh html_report.sh
    echo "✅ Função open_report corrigida para forçar nova janela"
else
    echo "❌ Não foi possível localizar a função open_report"
fi

# Limpar arquivos temporários
rm -f temp_open_report_fixed.sh

echo "2. Testando nova função..."

# Testar a função corrigida
source html_report.sh
latest_report=$(find ~/.security_analyzer/reports/ -name "*.html" -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)

if [[ -f "$latest_report" ]]; then
    echo "📄 Testando com: $(basename "$latest_report")"
    open_report "$latest_report"
else
    echo "❌ Nenhum relatório encontrado para teste"
fi

echo
echo "✅ Correção aplicada!"
echo
echo "🎯 Agora o navegador deve abrir em NOVA JANELA"
echo "📋 Se ainda não aparecer, verifique:"
echo "   - Barra de tarefas"
echo "   - Alt+Tab"
echo "   - Outros workspaces"
echo "   - Ou acesse: http://localhost:8080/"
