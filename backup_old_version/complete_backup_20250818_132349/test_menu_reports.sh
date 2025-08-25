#!/bin/bash

echo "🧪 TESTE COMPLETO DO MENU DE RELATÓRIOS"
echo "======================================="
echo

# Simular o fluxo completo do menu
echo "1. Carregando módulos..."
source security_tool.sh >/dev/null 2>&1

# Verificar se as funções estão disponíveis
if declare -f manage_reports >/dev/null 2>&1; then
    echo "✅ Função manage_reports disponível"
else
    echo "❌ Função manage_reports não encontrada"
    echo "🔧 Carregando report_integration.sh..."
    source report_integration.sh
fi

if declare -f list_reports >/dev/null 2>&1; then
    echo "✅ Função list_reports disponível"
else
    echo "❌ Função list_reports não encontrada"
    exit 1
fi

if declare -f open_report >/dev/null 2>&1; then
    echo "✅ Função open_report disponível"
else
    echo "❌ Função open_report não encontrada"
    exit 1
fi

echo
echo "2. Testando fluxo do menu..."

# Simular: security_tool.sh -> opção 10 -> opção 1 -> opção 1
echo "📋 Simulando: Menu Principal -> Relatórios HTML -> Listar -> Abrir primeiro"

# Parar servidores existentes
pkill -f "python.*8080" 2>/dev/null
sleep 1

echo
echo "🔍 Executando list_reports com seleção automática..."

# Simular entrada "1" para selecionar o primeiro relatório
echo "1" | list_reports

echo
echo "3. Verificando resultado..."

# Verificar se o servidor está rodando
if pgrep -f "python.*8080" >/dev/null; then
    echo "✅ Servidor web está rodando"
    
    # Verificar se está respondendo
    if curl -s -I http://localhost:8080/ >/dev/null 2>&1; then
        echo "✅ Servidor respondendo"
        
        # Listar relatórios disponíveis
        echo "📄 Relatórios disponíveis no servidor:"
        curl -s http://localhost:8080/ | grep -o 'href="[^"]*\.html"' | sed 's/href="//;s/"//' | head -5
        
    else
        echo "❌ Servidor não está respondendo"
    fi
else
    echo "❌ Servidor web não está rodando"
fi

echo
echo "4. Teste manual..."
echo "🎯 Para testar manualmente:"
echo "   1. Execute: ./security_tool.sh"
echo "   2. Selecione opção: 10 (📈 Relatórios HTML)"
echo "   3. Selecione opção: 1 (📋 Listar Relatórios)"
echo "   4. Selecione opção: 1 (primeiro relatório)"
echo "   5. O navegador deve abrir automaticamente"
echo
echo "🌐 Ou acesse diretamente: http://localhost:8080/"

# Manter servidor ativo
echo
echo "⏰ Servidor ficará ativo por 20 segundos para teste..."
sleep 20

pkill -f "python.*8080" 2>/dev/null
echo "🛑 Servidor parado"
echo
echo "✅ Teste completo finalizado!"
