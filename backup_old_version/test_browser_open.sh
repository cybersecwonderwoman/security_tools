#!/bin/bash

echo "🔍 TESTE DE ABERTURA DO NAVEGADOR"
echo "================================="
echo

# URL de teste
TEST_URL="http://localhost:8080/SA-20250725-8e0ed806.html"

echo "🌐 URL de teste: $TEST_URL"
echo

# Verificar se o servidor está rodando
echo "1. Verificando servidor..."
if curl -s -I "$TEST_URL" >/dev/null 2>&1; then
    echo "✅ Servidor respondendo"
else
    echo "❌ Servidor não está respondendo"
    echo "🚀 Iniciando servidor..."
    cd ~/.security_analyzer/reports
    python3 -m http.server 8080 &
    sleep 3
    if curl -s -I "$TEST_URL" >/dev/null 2>&1; then
        echo "✅ Servidor iniciado com sucesso"
    else
        echo "❌ Falha ao iniciar servidor"
        exit 1
    fi
fi
echo

# Testar comandos de abertura disponíveis
echo "2. Testando comandos de abertura..."

commands=(
    "xdg-open"
    "open" 
    "firefox"
    "google-chrome"
    "chromium-browser"
    "chromium"
    "sensible-browser"
    "x-www-browser"
)

available_commands=()

for cmd in "${commands[@]}"; do
    if command -v "$cmd" &>/dev/null; then
        echo "✅ $cmd: Disponível"
        available_commands+=("$cmd")
    else
        echo "❌ $cmd: Não encontrado"
    fi
done
echo

if [[ ${#available_commands[@]} -eq 0 ]]; then
    echo "❌ Nenhum comando de abertura de navegador encontrado!"
    echo "📋 URL para acesso manual: $TEST_URL"
    exit 1
fi

# Testar o primeiro comando disponível
echo "3. Testando abertura com ${available_commands[0]}..."
echo "🌐 Executando: ${available_commands[0]} '$TEST_URL'"

# Capturar saída e erros
output=$(${available_commands[0]} "$TEST_URL" 2>&1 &)
pid=$!

echo "✅ Comando executado (PID: $pid)"

# Aguardar um pouco para ver se há erros
sleep 2

# Verificar se o processo ainda está rodando
if kill -0 $pid 2>/dev/null; then
    echo "✅ Processo do navegador ainda ativo"
else
    echo "⚠️  Processo do navegador finalizou"
fi

# Mostrar saída se houver
if [[ -n "$output" ]]; then
    echo "📄 Saída do comando:"
    echo "$output"
fi

echo
echo "4. Verificações adicionais..."

# Verificar se há processos de navegador rodando
browser_processes=$(ps aux | grep -E "(firefox|chrome|chromium)" | grep -v grep | wc -l)
echo "🌐 Processos de navegador ativos: $browser_processes"

# Verificar variáveis de ambiente relacionadas ao display
echo "🖥️  DISPLAY: ${DISPLAY:-'Não definido'}"
echo "🖥️  WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-'Não definido'}"
echo "🖥️  XDG_SESSION_TYPE: ${XDG_SESSION_TYPE:-'Não definido'}"

echo
echo "5. Teste manual..."
echo "📋 Para testar manualmente, execute:"
echo "   ${available_commands[0]} '$TEST_URL'"
echo
echo "📋 Ou acesse diretamente no navegador:"
echo "   $TEST_URL"
echo

# Oferecer teste interativo
echo -n "Deseja tentar abrir o navegador agora? (s/n): "
read -r response

if [[ "$response" =~ ^[Ss]$ ]]; then
    echo "🚀 Abrindo navegador..."
    ${available_commands[0]} "$TEST_URL" &
    echo "✅ Comando executado"
    echo "⏳ Aguarde alguns segundos para o navegador abrir..."
    sleep 5
    echo "🎯 Se o navegador não abriu, pode haver um problema com o ambiente gráfico"
else
    echo "ℹ️  Teste manual cancelado"
fi

echo
echo "🔍 Diagnóstico concluído!"
