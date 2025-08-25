#!/bin/bash

echo "🔍 DIAGNÓSTICO COMPLETO - PROBLEMA DE ABERTURA DO NAVEGADOR"
echo "==========================================================="
echo

# 1. Verificar se o relatório existe
echo "1. Verificando relatórios existentes..."
reports_dir="$HOME/.security_analyzer/reports"
if [[ -d "$reports_dir" ]]; then
    echo "✅ Diretório de relatórios existe: $reports_dir"
    report_count=$(find "$reports_dir" -name "*.html" -type f | wc -l)
    echo "📄 Total de relatórios HTML: $report_count"
    
    if [[ $report_count -gt 0 ]]; then
        latest_report=$(find "$reports_dir" -name "*.html" -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)
        echo "📄 Último relatório: $(basename "$latest_report")"
        echo "📁 Caminho completo: $latest_report"
        
        if [[ -f "$latest_report" ]]; then
            echo "✅ Arquivo existe e é legível"
            file_size=$(stat -c%s "$latest_report")
            echo "📊 Tamanho: $file_size bytes"
        else
            echo "❌ Arquivo não encontrado"
            exit 1
        fi
    else
        echo "❌ Nenhum relatório HTML encontrado"
        exit 1
    fi
else
    echo "❌ Diretório de relatórios não existe"
    exit 1
fi

echo

# 2. Testar servidor web
echo "2. Testando servidor web..."
cd "$reports_dir"

# Parar qualquer servidor existente
pkill -f "python.*8080" 2>/dev/null
sleep 2

# Iniciar servidor
echo "🚀 Iniciando servidor na porta 8080..."
python3 -m http.server 8080 > server.log 2>&1 &
server_pid=$!
echo "📋 PID do servidor: $server_pid"

# Aguardar servidor inicializar
sleep 3

# Verificar se o servidor está rodando
if kill -0 $server_pid 2>/dev/null; then
    echo "✅ Servidor está rodando (PID: $server_pid)"
else
    echo "❌ Servidor não está rodando"
    echo "📋 Log do servidor:"
    cat server.log
    exit 1
fi

# Testar conectividade
echo "🔗 Testando conectividade..."
if curl -s -I http://localhost:8080/ | grep -q "200 OK"; then
    echo "✅ Servidor respondendo na porta 8080"
else
    echo "❌ Servidor não está respondendo"
    echo "📋 Tentando diagnóstico de rede..."
    netstat -tuln | grep 8080
    exit 1
fi

echo

# 3. Testar acesso ao relatório específico
echo "3. Testando acesso ao relatório..."
report_name=$(basename "$latest_report")
report_url="http://localhost:8080/$report_name"

echo "🌐 URL do relatório: $report_url"

if curl -s -I "$report_url" | grep -q "200 OK"; then
    echo "✅ Relatório acessível via HTTP"
    
    # Verificar conteúdo
    content_length=$(curl -s -I "$report_url" | grep -i content-length | cut -d' ' -f2 | tr -d '\r')
    echo "📊 Tamanho do conteúdo: $content_length bytes"
    
    # Verificar se há conteúdo HTML válido
    if curl -s "$report_url" | grep -q "<!DOCTYPE html>"; then
        echo "✅ Conteúdo HTML válido"
    else
        echo "❌ Conteúdo HTML inválido"
    fi
    
else
    echo "❌ Relatório não acessível via HTTP"
    echo "📋 Arquivos disponíveis no servidor:"
    curl -s http://localhost:8080/ | grep -o 'href="[^"]*\.html"' | head -5
    exit 1
fi

echo

# 4. Testar comandos de abertura
echo "4. Testando comandos de abertura do navegador..."

commands=("xdg-open" "firefox" "google-chrome" "chromium-browser")
working_command=""

for cmd in "${commands[@]}"; do
    if command -v "$cmd" &>/dev/null; then
        echo "✅ $cmd: Disponível"
        if [[ -z "$working_command" ]]; then
            working_command="$cmd"
        fi
    else
        echo "❌ $cmd: Não encontrado"
    fi
done

if [[ -n "$working_command" ]]; then
    echo "🎯 Usando comando: $working_command"
else
    echo "❌ Nenhum comando de abertura disponível"
    exit 1
fi

echo

# 5. Testar abertura real
echo "5. Testando abertura real do navegador..."
echo "🚀 Executando: $working_command '$report_url'"

# Capturar saída do comando
output=$($working_command "$report_url" 2>&1 &)
cmd_pid=$!

echo "📋 PID do comando: $cmd_pid"

# Aguardar um pouco
sleep 3

# Verificar se o comando ainda está rodando
if kill -0 $cmd_pid 2>/dev/null; then
    echo "✅ Comando de abertura ainda ativo"
else
    echo "⚠️  Comando de abertura finalizou"
fi

# Mostrar saída se houver
if [[ -n "$output" ]]; then
    echo "📄 Saída do comando:"
    echo "$output"
fi

echo

# 6. Verificar variáveis de ambiente
echo "6. Verificando ambiente gráfico..."
echo "🖥️  DISPLAY: ${DISPLAY:-'Não definido'}"
echo "🖥️  WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-'Não definido'}"
echo "🖥️  XDG_SESSION_TYPE: ${XDG_SESSION_TYPE:-'Não definido'}"
echo "🖥️  XDG_CURRENT_DESKTOP: ${XDG_CURRENT_DESKTOP:-'Não definido'}"

# Verificar se há sessão gráfica ativa
if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    echo "✅ Sessão gráfica detectada"
else
    echo "❌ Nenhuma sessão gráfica detectada"
fi

echo

# 7. Teste manual
echo "7. Teste manual..."
echo "📋 Para testar manualmente, execute em outro terminal:"
echo "   $working_command '$report_url'"
echo
echo "📋 Ou acesse diretamente no navegador:"
echo "   $report_url"
echo

# Manter servidor ativo
echo "⏰ Servidor ficará ativo por 30 segundos para teste manual..."
echo "🌐 Acesse: $report_url"

sleep 30

# Limpar
kill $server_pid 2>/dev/null
rm -f server.log

echo
echo "🔍 Diagnóstico concluído!"
echo
echo "📋 Resumo:"
echo "  - Relatório: $(basename "$latest_report")"
echo "  - URL: $report_url"
echo "  - Comando: $working_command"
echo "  - Servidor: Funcionando"
echo "  - Conteúdo: Acessível"
