#!/bin/bash

echo "🧪 TESTE RÁPIDO - ANÁLISE DE DOMÍNIO COM RELATÓRIO HTML"
echo "======================================================"
echo

# Simular entrada do usuário para análise de domínio
echo "📝 Simulando análise de domínio: example.com"
echo

# Executar análise de domínio
echo -e "3\nexample.com\ns\n0" | ./security_tool.sh

echo
echo "✅ Teste concluído!"
echo
echo "🔍 Verificando se o relatório foi gerado..."

# Verificar se há relatórios recentes
recent_reports=$(find ~/.security_analyzer/reports/ -name "*.html" -type f -mmin -2 | wc -l)

if [[ $recent_reports -gt 0 ]]; then
    echo "✅ $recent_reports relatório(s) gerado(s) nos últimos 2 minutos"
    
    # Mostrar o último relatório
    latest_report=$(find ~/.security_analyzer/reports/ -name "*.html" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    
    if [[ -f "$latest_report" ]]; then
        echo "📄 Último relatório: $(basename "$latest_report")"
        
        # Verificar se o conteúdo está formatado
        if grep -q "<h3.*style.*color.*#3498db" "$latest_report"; then
            echo "✅ Relatório com formatação HTML correta"
        else
            echo "❌ Problema na formatação HTML"
        fi
        
        # Verificar se há dados de domínio
        if grep -q "example.com" "$latest_report"; then
            echo "✅ Dados do domínio presentes no relatório"
        else
            echo "❌ Dados do domínio ausentes"
        fi
        
        echo
        echo "🌐 Para visualizar o relatório:"
        echo "   1. Execute: source html_report.sh"
        echo "   2. Execute: open_report \"$latest_report\""
        echo "   3. Ou acesse: http://localhost:8080/$(basename "$latest_report")"
        
    fi
else
    echo "❌ Nenhum relatório gerado recentemente"
fi

echo
echo "🎯 Para testar manualmente:"
echo "   ./security_tool.sh → Opção 3 → Digite domínio → Responda 's'"
