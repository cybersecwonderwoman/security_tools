#!/bin/bash

echo "🧪 TESTE FINAL - ABERTURA EM NOVA JANELA"
echo "========================================"
echo

# Carregar função corrigida
source html_report.sh

# Gerar um novo relatório de teste
echo "📄 Gerando relatório de teste..."
test_content="🧪 TESTE FINAL DE ABERTURA

[Informações do Teste]
Data: $(date '+%d/%m/%Y %H:%M:%S')
Objetivo: Verificar abertura em nova janela
Status: Em teste

[Resultado Esperado]
✅ Nova janela do navegador deve abrir
✅ Relatório deve ser exibido formatado
✅ Conteúdo deve estar limpo (sem códigos ANSI)

[Instruções]
Se você está vendo este relatório no navegador:
✅ A correção funcionou!

Teste concluído em $(date '+%Y-%m-%d %H:%M:%S')"

report_file=$(generate_html_report "Teste Final" "teste_abertura.txt" "$test_content")

if [[ -f "$report_file" ]]; then
    echo "✅ Relatório de teste gerado: $(basename "$report_file")"
    echo
    echo "🚀 Testando abertura em nova janela..."
    echo "======================================"
    
    # Contar processos de navegador antes
    before_count=$(ps aux | grep -E "(firefox|chrome)" | grep -v grep | wc -l)
    echo "📊 Processos de navegador antes: $before_count"
    
    # Abrir relatório
    open_report "$report_file"
    
    # Aguardar um pouco
    sleep 3
    
    # Contar processos depois
    after_count=$(ps aux | grep -E "(firefox|chrome)" | grep -v grep | wc -l)
    echo "📊 Processos de navegador depois: $after_count"
    
    if [[ $after_count -gt $before_count ]]; then
        echo "✅ Novos processos de navegador detectados!"
        echo "🎯 Diferença: $((after_count - before_count)) processos"
    else
        echo "⚠️  Nenhum novo processo detectado"
    fi
    
    echo
    echo "🔍 VERIFICAÇÃO MANUAL:"
    echo "======================"
    echo "1. 👀 Procure por uma NOVA JANELA do navegador"
    echo "2. 🔄 Use Alt+Tab para alternar entre janelas"
    echo "3. 📱 Verifique a barra de tarefas"
    echo "4. 🖥️  Verifique outros workspaces/desktops"
    echo
    echo "🌐 Se não encontrar, acesse manualmente:"
    echo "   http://localhost:8080/$(basename "$report_file")"
    echo
    echo "📋 O que você deve ver no navegador:"
    echo "   - Título: Security Analyzer - Relatório Detalhado"
    echo "   - Seção: 🧪 TESTE FINAL DE ABERTURA"
    echo "   - Conteúdo formatado com cores e seções"
    echo "   - Mensagem: 'A correção funcionou!'"
    
else
    echo "❌ Erro ao gerar relatório de teste"
fi

echo
echo "⏰ Servidor permanecerá ativo para verificação manual..."
echo "🛑 Para parar o servidor: pkill -f 'python.*8080'"
