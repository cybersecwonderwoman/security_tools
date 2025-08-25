#!/bin/bash

echo "🧪 TESTE FINAL DOS RELATÓRIOS HTML"
echo "=================================="
echo

# Parar servidores existentes
pkill -f "python.*8080" 2>/dev/null
sleep 2

# Carregar funções
source html_report.sh

echo "1. Gerando novo relatório de domínio..."
echo "google.com" | source security_tool.sh >/dev/null 2>&1 &
sleep 5

# Encontrar o relatório mais recente
latest_report=$(find ~/.security_analyzer/reports/ -name "*.html" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

if [[ -f "$latest_report" ]]; then
    echo "✅ Relatório encontrado: $(basename "$latest_report")"
    
    echo "2. Verificando conteúdo do relatório..."
    if grep -q "<h3.*Informações Básicas" "$latest_report"; then
        echo "✅ Formatação HTML correta"
    else
        echo "❌ Problema na formatação"
    fi
    
    echo "3. Iniciando servidor web..."
    cd ~/.security_analyzer/reports
    python3 -m http.server 8080 > /dev/null 2>&1 &
    server_pid=$!
    sleep 3
    
    echo "4. Testando acesso via HTTP..."
    report_name=$(basename "$latest_report")
    
    if curl -s -I "http://localhost:8080/$report_name" | grep -q "200 OK"; then
        echo "✅ Relatório acessível via HTTP"
        
        echo "5. Verificando conteúdo via HTTP..."
        content=$(curl -s "http://localhost:8080/$report_name")
        
        if [[ -n "$content" ]] && echo "$content" | grep -q "Security Analyzer"; then
            echo "✅ Conteúdo HTML sendo servido corretamente"
            
            # Verificar se há seções formatadas
            if echo "$content" | grep -q "<h3.*style.*color.*#3498db"; then
                echo "✅ Seções formatadas encontradas"
            else
                echo "❌ Seções não estão formatadas"
            fi
            
            # Verificar se há dados da análise
            if echo "$content" | grep -q "Informações Básicas\|Análise de\|DNS\|WHOIS"; then
                echo "✅ Dados da análise presentes"
            else
                echo "❌ Dados da análise ausentes"
            fi
            
        else
            echo "❌ Conteúdo HTML vazio ou inválido"
        fi
        
    else
        echo "❌ Relatório não acessível via HTTP"
    fi
    
    echo
    echo "6. Testando abertura no navegador..."
    echo "🌐 URL: http://localhost:8080/$report_name"
    
    # Tentar abrir no navegador
    if command -v xdg-open &>/dev/null; then
        echo "🚀 Abrindo no navegador..."
        xdg-open "http://localhost:8080/$report_name" &
        echo "✅ Comando de abertura executado"
    else
        echo "❌ xdg-open não disponível"
    fi
    
    echo
    echo "⏰ Servidor ficará ativo por 30 segundos para teste manual..."
    echo "🌐 Acesse: http://localhost:8080/$report_name"
    sleep 30
    
    # Parar servidor
    kill $server_pid 2>/dev/null
    echo "🛑 Servidor parado"
    
else
    echo "❌ Nenhum relatório encontrado"
fi

echo
echo "✅ Teste final concluído!"
echo
echo "🎯 Para usar normalmente:"
echo "   1. ./security_tool.sh"
echo "   2. Opção 3 (Analisar Domínio)"
echo "   3. Digite um domínio"
echo "   4. Responda 's' para abrir relatório"
echo "   5. Navegador deve abrir com conteúdo formatado!"
