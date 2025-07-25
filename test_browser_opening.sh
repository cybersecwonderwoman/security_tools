#!/bin/bash

echo "🔍 TESTE DETALHADO - ABERTURA AUTOMÁTICA DO NAVEGADOR"
echo "====================================================="
echo

# Verificar se o servidor está rodando
if ! pgrep -f "python.*8080" >/dev/null; then
    echo "🚀 Iniciando servidor..."
    cd ~/.security_analyzer/reports
    python3 -m http.server 8080 > /dev/null 2>&1 &
    sleep 3
fi

# URL de teste
test_url="http://localhost:8080/SA-20250725-4fa60c6d.html"
echo "🌐 URL de teste: $test_url"

# Verificar se a URL está acessível
echo "🔗 Verificando acessibilidade..."
if curl -s -I "$test_url" | grep -q "200 OK"; then
    echo "✅ URL acessível"
else
    echo "❌ URL não acessível"
    exit 1
fi

echo

# Teste 1: xdg-open com output detalhado
echo "1. Testando xdg-open com output detalhado..."
echo "Comando: xdg-open '$test_url'"

# Capturar tanto stdout quanto stderr
output=$(xdg-open "$test_url" 2>&1)
exit_code=$?

echo "Exit code: $exit_code"
echo "Output: $output"

if [[ $exit_code -eq 0 ]]; then
    echo "✅ xdg-open executou sem erros"
else
    echo "❌ xdg-open falhou com código $exit_code"
fi

echo

# Teste 2: Verificar qual aplicação o xdg-open está usando
echo "2. Verificando aplicação padrão para HTTP..."
default_browser=$(xdg-mime query default text/html 2>/dev/null)
echo "Aplicação padrão para HTML: $default_browser"

default_http=$(xdg-mime query default x-scheme-handler/http 2>/dev/null)
echo "Aplicação padrão para HTTP: $default_http"

echo

# Teste 3: Tentar com diferentes métodos
echo "3. Testando diferentes métodos de abertura..."

methods=(
    "xdg-open"
    "firefox --new-tab"
    "google-chrome --new-tab"
    "sensible-browser"
)

for method in "${methods[@]}"; do
    cmd_name=$(echo "$method" | cut -d' ' -f1)
    
    if command -v "$cmd_name" &>/dev/null; then
        echo "🧪 Testando: $method"
        
        # Executar comando em background e capturar PID
        $method "$test_url" &
        cmd_pid=$!
        
        # Aguardar um pouco
        sleep 2
        
        # Verificar se o processo ainda existe
        if kill -0 $cmd_pid 2>/dev/null; then
            echo "   ✅ Processo ativo (PID: $cmd_pid)"
        else
            echo "   ⚠️  Processo finalizou rapidamente"
        fi
        
        # Verificar se houve mudança nos processos de navegador
        browser_count=$(ps aux | grep -E "(firefox|chrome)" | grep -v grep | wc -l)
        echo "   📊 Processos de navegador: $browser_count"
        
    else
        echo "❌ $cmd_name não disponível"
    fi
    echo
done

echo

# Teste 4: Verificar se há bloqueios ou redirecionamentos
echo "4. Verificando possíveis bloqueios..."

# Verificar se há algum processo bloqueando
echo "🔍 Processos relacionados ao xdg-open:"
ps aux | grep xdg | grep -v grep

echo

# Verificar variáveis de ambiente que podem afetar
echo "🔍 Variáveis de ambiente relevantes:"
echo "BROWSER: ${BROWSER:-'Não definido'}"
echo "XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-'Não definido'}"
echo "XDG_DATA_HOME: ${XDG_DATA_HOME:-'Não definido'}"

echo

# Teste 5: Verificar logs do sistema
echo "5. Verificando logs recentes..."
echo "🔍 Últimas mensagens do sistema relacionadas a navegador:"
journalctl --user -n 10 --no-pager | grep -i -E "(firefox|chrome|browser|xdg)" || echo "Nenhuma mensagem encontrada"

echo

# Teste final: Instruções para o usuário
echo "6. TESTE MANUAL RECOMENDADO:"
echo "================================"
echo
echo "Para verificar se o navegador está realmente abrindo:"
echo
echo "1. 🖥️  Abra um terminal separado"
echo "2. 📊 Execute: watch -n 1 'ps aux | grep -E \"(firefox|chrome)\" | wc -l'"
echo "3. 🚀 Em outro terminal, execute: xdg-open '$test_url'"
echo "4. 👀 Observe se o número de processos aumenta"
echo
echo "Se o número aumentar mas você não vir o navegador:"
echo "- 🔍 Verifique todas as abas abertas"
echo "- 🖥️  Verifique outros workspaces/desktops"
echo "- 🔄 Tente Alt+Tab para ver janelas abertas"
echo "- 📱 Verifique se não está minimizado na barra de tarefas"
echo
echo "🌐 URL para acesso manual: $test_url"
echo
echo "⏰ Servidor permanecerá ativo para testes..."
