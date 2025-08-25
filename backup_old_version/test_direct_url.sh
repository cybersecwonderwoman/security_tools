#!/bin/bash

# Teste direto da função de análise de URL

echo "🧪 TESTE DIRETO DA FUNÇÃO DE ANÁLISE DE URL"
echo "==========================================="

# Carregar o script principal
source ./security_tool.sh

# Testar diretamente a função analyze_url
echo "Testando função analyze_url diretamente..."
echo

# Simular entrada do usuário
echo "https://example.com" | analyze_url

echo
echo "✅ Teste concluído"
