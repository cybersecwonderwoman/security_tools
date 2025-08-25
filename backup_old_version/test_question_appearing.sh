#!/bin/bash

echo "🧪 TESTE - VERIFICANDO SE A PERGUNTA APARECE"
echo "==========================================="
echo

# Carregar funções
source security_tool.sh >/dev/null 2>&1

# Verificar se as funções estão carregadas
echo "🔍 Verificando funções carregadas..."

if declare -f analyze_domain >/dev/null 2>&1; then
    echo "✅ analyze_domain: Carregada"
else
    echo "❌ analyze_domain: Não encontrada"
fi

if declare -f generate_html_report >/dev/null 2>&1; then
    echo "✅ generate_html_report: Carregada"
else
    echo "❌ generate_html_report: Não encontrada"
fi

if declare -f open_report_controlled >/dev/null 2>&1; then
    echo "✅ open_report_controlled: Carregada"
else
    echo "❌ open_report_controlled: Não encontrada"
fi

echo

# Testar geração de relatório e pergunta
echo "📄 Testando geração de relatório..."

test_content="🧪 TESTE DE PERGUNTA

[Informações do Teste]
Data: $(date '+%d/%m/%Y %H:%M:%S')
Objetivo: Verificar se a pergunta aparece

[Resultado Esperado]
A pergunta 'Deseja abrir o relatório no navegador? (s/n)' deve aparecer

Teste realizado em $(date '+%Y-%m-%d %H:%M:%S')"

if declare -f generate_html_report >/dev/null 2>&1; then
    report_file=$(generate_html_report "Teste Pergunta" "teste_pergunta.txt" "$test_content")
    
    if [[ -f "$report_file" ]]; then
        echo "✅ Relatório gerado: $(basename "$report_file")"
        
        echo
        echo "🎯 Testando função open_report_controlled..."
        echo "============================================"
        
        if declare -f open_report_controlled >/dev/null 2>&1; then
            echo "📋 A função vai perguntar se você quer abrir o relatório."
            echo "📋 Digite 'n' para não abrir e finalizar o teste."
            echo
            
            # Chamar a função que deve mostrar a pergunta
            open_report_controlled "$report_file"
            
            echo
            echo "✅ Teste da pergunta concluído!"
        else
            echo "❌ Função open_report_controlled não está disponível"
        fi
    else
        echo "❌ Erro ao gerar relatório"
    fi
else
    echo "❌ Função generate_html_report não está disponível"
fi

echo
echo "📋 Resumo:"
echo "   - Se a pergunta apareceu: ✅ Funcionando"
echo "   - Se a pergunta não apareceu: ❌ Problema na integração"
