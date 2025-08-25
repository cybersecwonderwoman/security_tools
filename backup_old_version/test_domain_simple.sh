#!/bin/bash

echo "🧪 TESTE SIMPLES - ANÁLISE DE DOMÍNIO"
echo "====================================="

# Carregar funções
source html_report.sh

# Simular análise de domínio diretamente
echo "📝 Executando análise de domínio para: example.com"

# Chamar função diretamente sem menu
domain="example.com"

# Simular resultado da análise (sem códigos ANSI)
analysis_result="🏠 ANÁLISE DE DOMÍNIO

[Informações Básicas]
Domínio: example.com
Data da análise: $(date '+%d/%m/%Y %H:%M:%S')

[Resolução DNS]
Registros A: 93.184.216.34
Registros MX: 0 .
Registros NS: a.iana-servers.net.

[Informações WHOIS]
Domain Name: EXAMPLE.COM
Creation Date: 1995-08-14T04:00:00Z
Registry Expiry Date: 2025-08-13T04:00:00Z

[Análise de Reputação]
✅ Nenhuma ameaça óbvia detectada
Reputação: Aparentemente limpa
Risco: Baixo

Análise concluída em $(date '+%Y-%m-%d %H:%M:%S')"

echo "📄 Gerando relatório HTML..."
report_file=$(generate_html_report "Domínio" "$domain" "$analysis_result")

if [[ -f "$report_file" ]]; then
    echo "✅ Relatório gerado: $(basename "$report_file")"
    
    # Verificar se não há códigos ANSI no HTML
    if grep -q '\[0;' "$report_file"; then
        echo "❌ CÓDIGOS ANSI ENCONTRADOS NO HTML!"
        echo "🔍 Primeiros códigos encontrados:"
        grep -o '\[0;[0-9]*m' "$report_file" | head -3
    else
        echo "✅ HTML limpo - sem códigos ANSI"
    fi
    
    echo "🌐 Abrindo relatório..."
    open_report "$report_file"
    
    echo "✅ Teste concluído!"
    echo "🎯 Acesse: http://localhost:8080/$(basename "$report_file")"
else
    echo "❌ Erro ao gerar relatório"
fi
