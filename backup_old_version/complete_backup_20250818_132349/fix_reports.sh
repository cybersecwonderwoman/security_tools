#!/bin/bash

# Script para corrigir problemas com relatórios HTML

echo "🔧 CORREÇÃO DOS RELATÓRIOS HTML"
echo "==============================="
echo

# Verificar se html_report.sh existe
if [[ ! -f "html_report.sh" ]]; then
    echo "❌ html_report.sh não encontrado"
    exit 1
fi

# Verificar se report_integration.sh existe
if [[ ! -f "report_integration.sh" ]]; then
    echo "❌ report_integration.sh não encontrado"
    exit 1
fi

# Corrigir função open_report no html_report.sh
echo "1. Corrigindo função open_report..."

# Backup do arquivo original
cp html_report.sh html_report.sh.backup

# Criar versão corrigida da função open_report
cat > temp_open_report.sh << 'EOF'
# Função para abrir o relatório no navegador (versão corrigida)
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
    if ! pgrep -f "python.*http.server.*8080" &>/dev/null && ! pgrep -f "python.*SimpleHTTPServer.*8080" &>/dev/null; then
        echo "🚀 Iniciando servidor web..."
        start_report_server
        sleep 2  # Aguardar servidor inicializar
    else
        echo "✅ Servidor já está rodando"
    fi
    
    # Verificar se o servidor está respondendo
    local max_attempts=5
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -s -I http://localhost:8080/ >/dev/null 2>&1; then
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
    local report_url="http://localhost:8080/$report_name"
    
    # Verificar se o relatório está acessível
    if curl -s -I "$report_url" >/dev/null 2>&1; then
        echo "✅ Relatório acessível em: $report_url"
        
        # Abrir o navegador
        if command -v xdg-open &>/dev/null; then
            echo "🌐 Abrindo com xdg-open..."
            xdg-open "$report_url" &
        elif command -v open &>/dev/null; then
            echo "🌐 Abrindo com open..."
            open "$report_url" &
        elif command -v firefox &>/dev/null; then
            echo "🌐 Abrindo com Firefox..."
            firefox "$report_url" &
        elif command -v google-chrome &>/dev/null; then
            echo "🌐 Abrindo com Chrome..."
            google-chrome "$report_url" &
        elif command -v chromium-browser &>/dev/null; then
            echo "🌐 Abrindo com Chromium..."
            chromium-browser "$report_url" &
        else
            echo "⚠️  Não foi possível abrir o navegador automaticamente."
            echo "📋 Por favor, acesse manualmente: $report_url"
        fi
        
        echo "🎯 Relatório disponível em: $report_url"
        return 0
    else
        echo "❌ Relatório não está acessível via HTTP"
        echo "📁 Arquivo local: $report_file"
        return 1
    fi
}
EOF

# Substituir a função no arquivo original
echo "2. Aplicando correção..."

# Encontrar onde começa e termina a função open_report
start_line=$(grep -n "^open_report()" html_report.sh | cut -d: -f1)
end_line=$(grep -n "^}" html_report.sh | awk -v start="$start_line" '$1 > start {print $1; exit}')

if [[ -n "$start_line" && -n "$end_line" ]]; then
    # Criar arquivo temporário com a correção
    head -n $((start_line - 1)) html_report.sh > temp_html_report.sh
    cat temp_open_report.sh >> temp_html_report.sh
    tail -n +$((end_line + 1)) html_report.sh >> temp_html_report.sh
    
    # Substituir arquivo original
    mv temp_html_report.sh html_report.sh
    echo "✅ Função open_report corrigida"
else
    echo "⚠️  Não foi possível localizar a função open_report"
fi

# Limpar arquivos temporários
rm -f temp_open_report.sh

# Corrigir função start_report_server
echo "3. Melhorando função start_report_server..."

# Criar versão melhorada
cat > temp_start_server.sh << 'EOF'
# Função para iniciar um servidor web simples para servir os relatórios (versão melhorada)
start_report_server() {
    local port=${PORT:-8080}
    
    echo "🚀 Iniciando servidor web na porta $port..."
    
    # Verificar se a porta já está em uso
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo "⚠️  Porta $port já está em uso"
        echo "🛑 Parando processos existentes..."
        pkill -f "python.*http.server.*$port" 2>/dev/null
        pkill -f "python.*SimpleHTTPServer.*$port" 2>/dev/null
        sleep 2
    fi
    
    # Ir para o diretório de relatórios
    if [[ ! -d "$REPORTS_DIR" ]]; then
        echo "📁 Criando diretório de relatórios: $REPORTS_DIR"
        mkdir -p "$REPORTS_DIR"
    fi
    
    cd "$REPORTS_DIR" || {
        echo "❌ Erro: Não foi possível acessar $REPORTS_DIR"
        return 1
    }
    
    echo "📂 Servindo arquivos de: $(pwd)"
    echo "📄 Relatórios disponíveis: $(ls -1 *.html 2>/dev/null | wc -l)"
    
    # Verificar se o Python está instalado e iniciar servidor
    if command -v python3 &>/dev/null; then
        echo "🐍 Usando Python 3"
        python3 -m http.server $port > /dev/null 2>&1 &
        local server_pid=$!
        echo "✅ Servidor iniciado (PID: $server_pid)"
    elif command -v python &>/dev/null; then
        echo "🐍 Usando Python 2"
        python -m SimpleHTTPServer $port > /dev/null 2>&1 &
        local server_pid=$!
        echo "✅ Servidor iniciado (PID: $server_pid)"
    else
        echo "❌ Erro: Python não encontrado. Não foi possível iniciar o servidor."
        return 1
    fi
    
    # Aguardar servidor inicializar
    sleep 2
    
    # Verificar se o servidor está funcionando
    if curl -s -I "http://localhost:$port/" >/dev/null 2>&1; then
        echo "✅ Servidor funcionando em http://localhost:$port/"
        return 0
    else
        echo "❌ Erro: Servidor não está respondendo"
        return 1
    fi
}
EOF

# Aplicar correção similar para start_report_server
start_line=$(grep -n "^start_report_server()" html_report.sh | cut -d: -f1)
end_line=$(grep -n "^}" html_report.sh | awk -v start="$start_line" '$1 > start {print $1; exit}')

if [[ -n "$start_line" && -n "$end_line" ]]; then
    # Criar arquivo temporário com a correção
    head -n $((start_line - 1)) html_report.sh > temp_html_report.sh
    cat temp_start_server.sh >> temp_html_report.sh
    tail -n +$((end_line + 1)) html_report.sh >> temp_html_report.sh
    
    # Substituir arquivo original
    mv temp_html_report.sh html_report.sh
    echo "✅ Função start_report_server melhorada"
else
    echo "⚠️  Não foi possível localizar a função start_report_server"
fi

# Limpar arquivos temporários
rm -f temp_start_server.sh

# Criar script de teste rápido
echo "4. Criando script de teste rápido..."

cat > test_reports_quick.sh << 'EOF'
#!/bin/bash

echo "🧪 TESTE RÁPIDO DOS RELATÓRIOS HTML"
echo "==================================="

# Carregar funções
source html_report.sh

# Gerar relatório de teste
echo "📄 Gerando relatório de teste..."
report_file=$(generate_html_report "Teste Rápido" "teste.txt" "Relatório de teste para verificar funcionamento")

echo "✅ Relatório gerado: $report_file"

# Abrir relatório
echo "🌐 Abrindo relatório..."
open_report "$report_file"

echo "✅ Teste concluído!"
echo "🎯 Se o navegador não abriu automaticamente, acesse: http://localhost:8080/"
EOF

chmod +x test_reports_quick.sh

echo "✅ Correções aplicadas com sucesso!"
echo
echo "📋 Arquivos modificados:"
echo "  ✅ html_report.sh (função open_report corrigida)"
echo "  ✅ html_report.sh (função start_report_server melhorada)"
echo "  ✅ test_reports_quick.sh (script de teste criado)"
echo
echo "🧪 Para testar as correções:"
echo "  ./test_reports_quick.sh"
echo
echo "🔧 Para usar no menu principal:"
echo "  ./security_tool.sh"
echo "  Opção 10 → Opção 1 → Selecionar relatório"
echo
echo "🎯 Correções concluídas! Os relatórios HTML agora devem abrir corretamente no localhost."
