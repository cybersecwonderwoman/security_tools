#!/bin/bash

echo "🧪 TESTE DA ANÁLISE DE DOMÍNIO COM RELATÓRIO HTML"
echo "================================================="
echo

# Carregar módulos necessários
echo "📚 Carregando módulos..."
source security_tool.sh >/dev/null 2>&1

# Verificar se as funções estão disponíveis
if declare -f analyze_domain >/dev/null 2>&1; then
    echo "✅ Função analyze_domain carregada"
else
    echo "❌ Função analyze_domain não encontrada"
    exit 1
fi

if declare -f generate_html_report >/dev/null 2>&1; then
    echo "✅ Função generate_html_report carregada"
else
    echo "❌ Função generate_html_report não encontrada"
    echo "🔧 Carregando html_report.sh..."
    source html_report.sh
    if declare -f generate_html_report >/dev/null 2>&1; then
        echo "✅ Função generate_html_report carregada"
    else
        echo "❌ Erro ao carregar html_report.sh"
        exit 1
    fi
fi

echo
echo "🔍 Testando análise de domínio..."

# Domínios de teste
test_domains=("google.com" "example.com" "malicious-test.com")

for domain in "${test_domains[@]}"; do
    echo
    echo "🌐 Testando domínio: $domain"
    echo "================================"
    
    # Simular entrada do usuário
    echo "$domain" | analyze_domain
    
    echo
    echo "⏳ Aguardando 3 segundos..."
    sleep 3
done

echo
echo "📊 Verificando relatórios gerados..."

reports_dir="$HOME/.security_analyzer/reports"
if [[ -d "$reports_dir" ]]; then
    echo "📁 Diretório de relatórios: $reports_dir"
    
    # Contar relatórios HTML
    html_count=$(find "$reports_dir" -name "*.html" -type f | wc -l)
    echo "📄 Total de relatórios HTML: $html_count"
    
    # Mostrar últimos 5 relatórios
    echo "📋 Últimos relatórios gerados:"
    find "$reports_dir" -name "*.html" -type f -printf '%T@ %p\n' 2>/dev/null | \
        sort -rn | head -5 | while read timestamp filepath; do
        filename=$(basename "$filepath")
        date_str=$(date -d "@$timestamp" '+%d/%m/%Y %H:%M:%S' 2>/dev/null || echo "N/A")
        echo "  $filename ($date_str)"
    done
    
    # Verificar se há relatórios de domínio recentes
    recent_domain_reports=$(find "$reports_dir" -name "*.html" -type f -mmin -5 | wc -l)
    echo "🕒 Relatórios gerados nos últimos 5 minutos: $recent_domain_reports"
    
    if [[ $recent_domain_reports -gt 0 ]]; then
        echo "✅ Relatórios de domínio foram gerados com sucesso!"
        
        # Mostrar o último relatório gerado
        latest_report=$(find "$reports_dir" -name "*.html" -type f -printf '%T@ %p\n' 2>/dev/null | \
            sort -rn | head -1 | cut -d' ' -f2-)
        
        if [[ -f "$latest_report" ]]; then
            echo
            echo "📄 Último relatório gerado: $(basename "$latest_report")"
            echo "🔍 Primeiras linhas do relatório:"
            head -10 "$latest_report" | grep -v "^$"
            
            echo
            echo "🌐 Para visualizar o relatório:"
            echo "   1. Execute: source html_report.sh"
            echo "   2. Execute: open_report \"$latest_report\""
            echo "   3. Ou acesse: http://localhost:8080/$(basename "$latest_report")"
        fi
    else
        echo "❌ Nenhum relatório de domínio foi gerado recentemente"
        echo "🔧 Possíveis problemas:"
        echo "   - Função generate_html_report não está funcionando"
        echo "   - Permissões do diretório de relatórios"
        echo "   - Erro na integração das funções"
    fi
else
    echo "❌ Diretório de relatórios não existe: $reports_dir"
fi

echo
echo "🎯 Para testar manualmente:"
echo "   1. Execute: ./security_tool.sh"
echo "   2. Selecione opção: 3 (🏠 Analisar Domínio)"
echo "   3. Digite um domínio (ex: google.com)"
echo "   4. Responda 's' quando perguntado sobre abrir o relatório"
echo
echo "✅ Teste concluído!"
