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
