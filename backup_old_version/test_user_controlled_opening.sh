#!/bin/bash

echo "🧪 TESTE - ABERTURA CONTROLADA PELO USUÁRIO"
echo "==========================================="
echo

# Carregar funções
source html_report.sh

# Gerar relatório de teste
echo "📄 Gerando relatório de teste..."
test_content="🧪 TESTE DE ABERTURA CONTROLADA

[Informações do Teste]
Data: $(date '+%d/%m/%Y %H:%M:%S')
Método: Abertura controlada pelo usuário
Status: Testando nova abordagem

[Como Funciona]
1. Relatório é gerado
2. Sistema pergunta se quer abrir
3. Se sim: servidor inicia, abre navegador
4. Usuário visualiza o relatório
5. Usuário pressiona ENTER
6. Servidor é finalizado automaticamente

[Vantagens]
✅ Controle total do usuário
✅ Servidor não fica rodando indefinidamente
✅ Não perde a geração do relatório
✅ Mais eficiente e limpo

Teste realizado em $(date '+%Y-%m-%d %H:%M:%S')"

report_file=$(generate_html_report "Teste Controlado" "teste_usuario.txt" "$test_content")

if [[ -f "$report_file" ]]; then
    echo "✅ Relatório gerado: $(basename "$report_file")"
    echo
    echo "🚀 Testando abertura controlada..."
    echo "=================================="
    echo
    echo "📋 O sistema vai perguntar se você quer abrir o relatório."
    echo "📋 Responda 's' para testar a funcionalidade completa."
    echo
    
    # Testar a função
    open_report_controlled "$report_file"
    
    echo
    echo "✅ Teste concluído!"
else
    echo "❌ Erro ao gerar relatório de teste"
fi
