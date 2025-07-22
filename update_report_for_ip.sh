#!/bin/bash

# Script para atualizar o generate_report.sh para incluir informações específicas para análise de IP

# Verificar se o script original existe
if [ ! -f "/home/anny-ribeiro/amazonQ/app/generate_report.sh" ]; then
    echo "Erro: O arquivo generate_report.sh não foi encontrado!"
    exit 1
fi

# Fazer backup do script original
cp "/home/anny-ribeiro/amazonQ/app/generate_report.sh" "/home/anny-ribeiro/amazonQ/app/generate_report.sh.bak_ip"
echo "Backup criado em: /home/anny-ribeiro/amazonQ/app/generate_report.sh.bak_ip"

# Adicionar recomendações específicas para análise de IP
sed -i '/case "$ANALYSIS_TYPE" in/,/esac/ s/"Análise de Cabeçalho de Email")/&\n        ;;\n    "Análise de IP")\n        RECOMMENDATIONS="<li>Verifique se o IP está em listas de bloqueio (RBLs)<\/li>\n<li>Monitore o tráfego de e para este IP<\/li>\n<li>Se o IP for malicioso, considere bloqueá-lo em seu firewall<\/li>\n<li>Verifique logs de acesso para atividades suspeitas deste IP<\/li>"/' "/home/anny-ribeiro/amazonQ/app/generate_report.sh"

# Adicionar extração de informações específicas para IP
sed -i '/# Extrair IOCs (Indicadores de Compromisso)/a \
# Extrair informações específicas para análise de IP\nif [ "$ANALYSIS_TYPE" = "Análise de IP" ]; then\n    # Verificar se há informações de geolocalização no log\n    IP_COUNTRY=$(echo "$LOG_CONTENT" | grep -o "País: [A-Za-z ]*" | head -1 | cut -d" " -f2-)\n    IP_ORG=$(echo "$LOG_CONTENT" | grep -o "Organização: [^\\n]*" | head -1 | cut -d" " -f2-)\n    \n    # Verificar se há informações de risco no log\n    RISK_SCORE=$(echo "$LOG_CONTENT" | grep -o "Pontuação de Risco: [0-9]*" | head -1 | cut -d" " -f3-)\n    \n    # Ajustar nível de risco com base na pontuação específica de IP\n    if [ -n "$RISK_SCORE" ] && [ "$RISK_SCORE" -ge 50 ]; then\n        RISK_LEVEL="Alto"\n        RISK_COLOR="#d73a49"\n        RISK_EMOJI="🚨"\n    elif [ -n "$RISK_SCORE" ] && [ "$RISK_SCORE" -ge 20 ]; then\n        RISK_LEVEL="Médio"\n        RISK_COLOR="#f9c513"\n        RISK_EMOJI="⚠️"\n    fi\n    \n    # Extrair fatores de risco\n    IP_RISK_FACTORS=$(echo "$LOG_CONTENT" | grep -A 10 "Fatores de risco identificados:" | grep "^  - " | sed "s/^  - //")\n    if [ -n "$IP_RISK_FACTORS" ]; then\n        IP_RISK_FACTORS_HTML="<h4>Fatores de Risco Identificados</h4><ul>"\n        while IFS= read -r line; do\n            IP_RISK_FACTORS_HTML+="<li>$line</li>"\n        done <<< "$IP_RISK_FACTORS"\n        IP_RISK_FACTORS_HTML+="</ul>"\n    fi\nfi' "/home/anny-ribeiro/amazonQ/app/generate_report.sh"

# Adicionar seção específica para IP no relatório HTML
sed -i '/<div class="summary-box">/a \
        <!-- Informações específicas para análise de IP -->\n        <% if [ "$ANALYSIS_TYPE" = "Análise de IP" ]; then %>\n        <p><strong>País:</strong> ${IP_COUNTRY:-Desconhecido}</p>\n        <p><strong>Organização:</strong> ${IP_ORG:-Desconhecida}</p>\n        <% if [ -n "$RISK_SCORE" ]; then %>\n        <p><strong>Pontuação de Risco:</strong> ${RISK_SCORE}/100</p>\n        <% fi %>\n        <% fi %>' "/home/anny-ribeiro/amazonQ/app/generate_report.sh"

# Adicionar fatores de risco ao relatório HTML
sed -i '/<h2>Indicadores de Compromisso (IOCs)<\/h2>/i \
        <!-- Fatores de risco para análise de IP -->\n        <% if [ "$ANALYSIS_TYPE" = "Análise de IP" ] && [ -n "$IP_RISK_FACTORS_HTML" ]; then %>\n        ${IP_RISK_FACTORS_HTML}\n        <% fi %>' "/home/anny-ribeiro/amazonQ/app/generate_report.sh"

# Corrigir a sintaxe do template
sed -i 's/<% if \[ "$ANALYSIS_TYPE" = "Análise de IP" \]; then %>/{% if [ "$ANALYSIS_TYPE" = "Análise de IP" ]; then %}/' "/home/anny-ribeiro/amazonQ/app/generate_report.sh"
sed -i 's/<% if \[ -n "$RISK_SCORE" \]; then %>/{% if [ -n "$RISK_SCORE" ]; then %}/' "/home/anny-ribeiro/amazonQ/app/generate_report.sh"
sed -i 's/<% fi %>/{% fi %}/' "/home/anny-ribeiro/amazonQ/app/generate_report.sh"

# Remover as modificações de template que não funcionarão em bash puro
sed -i '/<% if \[ "$ANALYSIS_TYPE" = "Análise de IP" \]; then %>/,/<% fi %>/d' "/home/anny-ribeiro/amazonQ/app/generate_report.sh"
sed -i '/<% if \[ "$ANALYSIS_TYPE" = "Análise de IP" \] && \[ -n "$IP_RISK_FACTORS_HTML" \]; then %>/,/<% fi %>/d' "/home/anny-ribeiro/amazonQ/app/generate_report.sh"

echo "Script generate_report.sh atualizado com sucesso!"
echo "Agora ele inclui informações específicas para análise de IP."
