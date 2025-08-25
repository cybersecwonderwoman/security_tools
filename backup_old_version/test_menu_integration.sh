#!/bin/bash

# Teste de integração da funcionalidade de relatórios HTML no menu principal

echo "🧪 Testando integração da funcionalidade de relatórios HTML..."
echo

# Verificar se a opção aparece no menu
echo "1. Verificando se a opção aparece no menu principal..."
if timeout 3 ./security_tool.sh 2>/dev/null | grep -q "📈 Relatórios HTML"; then
    echo "✅ Opção 'Relatórios HTML' encontrada no menu principal"
else
    echo "❌ Opção 'Relatórios HTML' NÃO encontrada no menu principal"
    exit 1
fi

# Verificar se as funções estão sendo importadas
echo "2. Verificando se as funções estão sendo importadas..."
if source ./security_tool.sh 2>/dev/null && declare -f manage_reports >/dev/null 2>&1; then
    echo "✅ Função 'manage_reports' está disponível"
else
    echo "❌ Função 'manage_reports' NÃO está disponível"
    exit 1
fi

# Verificar se os arquivos de script existem
echo "3. Verificando arquivos de script..."
if [[ -f "html_report.sh" && -f "report_integration.sh" ]]; then
    echo "✅ Arquivos de script encontrados"
else
    echo "❌ Arquivos de script não encontrados"
    exit 1
fi

# Verificar se há relatórios para testar
echo "4. Verificando relatórios existentes..."
reports_count=$(find "$HOME/.security_analyzer/reports" -name "*.html" -type f 2>/dev/null | wc -l)
echo "📊 Encontrados $reports_count relatórios"

echo
echo "🎉 Teste de integração concluído com sucesso!"
echo "A funcionalidade de Relatórios HTML está totalmente integrada ao menu principal."
echo
echo "Para usar:"
echo "  1. Execute: ./security_tool.sh"
echo "  2. Selecione opção: 10"
echo "  3. Selecione opção: 1 (Listar Relatórios)"
