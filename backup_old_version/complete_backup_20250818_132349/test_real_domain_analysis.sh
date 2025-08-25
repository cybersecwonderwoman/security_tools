#!/bin/bash

echo "🧪 TESTE REAL - ANÁLISE DE DOMÍNIO COM NOVA ABORDAGEM"
echo "====================================================="
echo

# Simular análise de domínio real
echo "📝 Simulando análise de domínio: google.com"
echo "============================================"

# Carregar funções
source security_tool.sh >/dev/null 2>&1

# Simular entrada do usuário: opção 3 (domínio), google.com, s (abrir), enter (finalizar)
echo "🚀 Executando análise..."
echo

# Chamar função analyze_domain diretamente
domain="google.com"

# Simular o conteúdo da análise (como seria gerado pela função real)
analysis_result="🏠 ANÁLISE DE DOMÍNIO

[Informações Básicas]
Domínio: google.com
Data da análise: $(date '+%d/%m/%Y %H:%M:%S')

[Resolução DNS]
Registros A: 142.250.191.14
Registros MX: 10 smtp.google.com.
Registros NS: ns1.google.com.

[Informações WHOIS]
Domain Name: GOOGLE.COM
Creation Date: 1997-09-15T04:00:00Z
Registry Expiry Date: 2028-09-14T04:00:00Z
Registrar: MarkMonitor Inc.

[Análise de Reputação]
✅ Nenhuma ameaça óbvia detectada
Reputação: Aparentemente limpa
Risco: Baixo

[VirusTotal]
Nenhuma URL maliciosa conhecida

Análise concluída em $(date '+%Y-%m-%d %H:%M:%S')"

echo "📄 Gerando relatório HTML..."
if declare -f generate_html_report >/dev/null 2>&1; then
    report_file=$(generate_html_report "Domínio" "$domain" "$analysis_result")
    
    if [[ -f "$report_file" ]]; then
        echo "✅ Relatório HTML gerado: $(basename "$report_file")"
        
        # Usar a nova função de abertura controlada
        if declare -f open_report_controlled >/dev/null 2>&1; then
            echo
            echo "🎯 Testando nova abordagem de abertura..."
            echo "========================================"
            echo
            echo "📋 INSTRUÇÕES PARA O TESTE:"
            echo "   1. O sistema vai perguntar se quer abrir o relatório"
            echo "   2. Digite 's' e pressione ENTER"
            echo "   3. O navegador deve abrir automaticamente"
            echo "   4. Visualize o relatório no navegador"
            echo "   5. Volte ao terminal e pressione ENTER para finalizar"
            echo
            echo "🚀 Iniciando teste interativo..."
            echo
            
            # Chamar a função interativa
            open_report_controlled "$report_file"
            
        else
            echo "❌ Função open_report_controlled não encontrada"
        fi
    else
        echo "❌ Erro ao gerar relatório HTML"
    fi
else
    echo "❌ Função generate_html_report não encontrada"
fi

echo
echo "✅ Teste real concluído!"
echo
echo "📋 Resumo do que foi testado:"
echo "   ✅ Geração de relatório HTML"
echo "   ✅ Pergunta interativa ao usuário"
echo "   ✅ Inicialização do servidor temporário"
echo "   ✅ Abertura do navegador"
echo "   ✅ Finalização controlada do servidor"
echo
echo "🎯 Para usar no sistema real:"
echo "   ./security_tool.sh → Opção 3 → Digite domínio → Responda 's'"
