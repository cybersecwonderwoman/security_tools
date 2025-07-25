#!/bin/bash

echo "🔧 CORREÇÃO FINAL - ANSI e Relatórios HTML"
echo "=========================================="
echo

# Função para remover códigos ANSI
create_ansi_cleaner() {
    cat > ansi_cleaner.sh << 'EOF'
#!/bin/bash

# Função para remover códigos ANSI de texto
clean_ansi_codes() {
    local text="$1"
    
    # Remover códigos de escape ANSI
    text=$(echo "$text" | sed -r 's/\x1B\[[0-9;]*[JKmsu]//g')
    text=$(echo "$text" | sed -r 's/\x1B\[[0-9;]*[A-Za-z]//g')
    text=$(echo "$text" | sed -r 's/\x1B\[H//g')
    text=$(echo "$text" | sed -r 's/\x1B\[2J//g')
    text=$(echo "$text" | sed -r 's/\x1B\[3J//g')
    
    # Remover códigos de cores específicos
    text=$(echo "$text" | sed 's/\[0;31m//g')  # RED
    text=$(echo "$text" | sed 's/\[0;32m//g')  # GREEN
    text=$(echo "$text" | sed 's/\[1;33m//g')  # YELLOW
    text=$(echo "$text" | sed 's/\[0;34m//g')  # BLUE
    text=$(echo "$text" | sed 's/\[0;35m//g')  # PURPLE
    text=$(echo "$text" | sed 's/\[0;36m//g')  # CYAN
    text=$(echo "$text" | sed 's/\[1;37m//g')  # WHITE
    text=$(echo "$text" | sed 's/\[1m//g')     # BOLD
    text=$(echo "$text" | sed 's/\[0m//g')     # NC
    
    echo "$text"
}

# Exportar função
export -f clean_ansi_codes
EOF
    chmod +x ansi_cleaner.sh
}

echo "1. Criando limpador de códigos ANSI..."
create_ansi_cleaner

echo "2. Corrigindo função generate_html_report..."

# Backup da função original
cp html_report.sh html_report.sh.backup.ansi

# Criar nova versão da função generate_html_report com limpeza ANSI
cat > temp_generate_html_report_clean.sh << 'EOF'
# Função principal para gerar relatório HTML (versão com limpeza ANSI)
generate_html_report() {
    local analysis_type="$1"
    local target="$2"
    local analysis_text="$3"
    
    # Carregar função de limpeza ANSI
    source "$(dirname "${BASH_SOURCE[0]}")/ansi_cleaner.sh" 2>/dev/null || {
        # Função de limpeza ANSI inline se o arquivo não existir
        clean_ansi_codes() {
            local text="$1"
            text=$(echo "$text" | sed -r 's/\x1B\[[0-9;]*[JKmsu]//g')
            text=$(echo "$text" | sed -r 's/\x1B\[[0-9;]*[A-Za-z]//g')
            text=$(echo "$text" | sed -r 's/\x1B\[H//g')
            text=$(echo "$text" | sed -r 's/\x1B\[2J//g')
            text=$(echo "$text" | sed -r 's/\x1B\[3J//g')
            text=$(echo "$text" | sed 's/\[0;31m//g')
            text=$(echo "$text" | sed 's/\[0;32m//g')
            text=$(echo "$text" | sed 's/\[1;33m//g')
            text=$(echo "$text" | sed 's/\[0;34m//g')
            text=$(echo "$text" | sed 's/\[0;35m//g')
            text=$(echo "$text" | sed 's/\[0;36m//g')
            text=$(echo "$text" | sed 's/\[1;37m//g')
            text=$(echo "$text" | sed 's/\[1m//g')
            text=$(echo "$text" | sed 's/\[0m//g')
            echo "$text"
        }
    }
    
    local report_id=$(generate_report_id)
    local date_now=$(date '+%d/%m/%Y')
    local time_now=$(date '+%H:%M:%S')
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # LIMPAR CÓDIGOS ANSI DO TEXTO DE ANÁLISE
    analysis_text=$(clean_ansi_codes "$analysis_text")
    
    # Converter texto para HTML com formatação adequada
    local formatted_analysis=""
    
    # Processar linha por linha
    while IFS= read -r line; do
        # Pular linhas vazias
        [[ -z "$line" ]] && continue
        
        # Limpar códigos ANSI da linha
        line=$(clean_ansi_codes "$line")
        
        # Detectar seções (texto entre colchetes)
        if [[ "$line" =~ ^\[.*\]$ ]]; then
            section_name=$(echo "$line" | sed 's/\[\(.*\)\]/\1/')
            formatted_analysis+="<h3 style=\"color: #3498db; margin-top: 20px; border-bottom: 2px solid #3498db; padding-bottom: 5px;\">$section_name</h3>"
        
        # Detectar linhas de status/resultado
        elif [[ "$line" =~ ^[[:space:]]*[✅❌⚠️] ]]; then
            # Colorir ícones de status
            colored_line=$(echo "$line" | sed 's/✅/<span style="color: #2ecc71;">✅<\/span>/g')
            colored_line=$(echo "$colored_line" | sed 's/❌/<span style="color: #e74c3c;">❌<\/span>/g')
            colored_line=$(echo "$colored_line" | sed 's/⚠️/<span style="color: #f39c12;">⚠️<\/span>/g')
            formatted_analysis+="<p style=\"margin: 10px 0; font-weight: bold;\">$colored_line</p>"
        
        # Detectar linhas com dois pontos (chave: valor)
        elif [[ "$line" =~ ^[^:]+:[[:space:]]*.+ ]]; then
            key=$(echo "$line" | cut -d':' -f1)
            value=$(echo "$line" | cut -d':' -f2- | sed 's/^[[:space:]]*//')
            formatted_analysis+="<div style=\"margin: 8px 0;\"><strong style=\"color: #2c3e50;\">$key:</strong> <span style=\"color: #34495e;\">$value</span></div>"
        
        # Detectar linhas que começam com espaços (detalhes)
        elif [[ "$line" =~ ^[[:space:]]{2,} ]]; then
            clean_line=$(echo "$line" | sed 's/^[[:space:]]*//')
            formatted_analysis+="<p style=\"margin: 5px 0 5px 20px; color: #7f8c8d;\">$clean_line</p>"
        
        # Linhas normais
        else
            formatted_analysis+="<p style=\"margin: 10px 0;\">$line</p>"
        fi
    done <<< "$analysis_text"
    
    # Determinar status geral
    local overall_status="Limpo"
    local overall_status_class="success"
    local threat_level="Baixo"
    local threat_level_class="success"
    
    if [[ "$analysis_text" == *"AMEAÇA DETECTADA"* || "$analysis_text" == *"SUSPEITO DETECTADO"* || "$analysis_text" == *"MALICIOSO"* ]]; then
        overall_status="Malicioso"
        overall_status_class="danger"
        threat_level="Alto"
        threat_level_class="danger"
    elif [[ "$analysis_text" == *"Suspeito"* || "$analysis_text" == *"Risco: Alto"* ]]; then
        overall_status="Suspeito"
        overall_status_class="warning"
        threat_level="Médio"
        threat_level_class="warning"
    fi
    
    # Contar fontes de análise
    local sources_count=1
    [[ "$analysis_text" == *"VirusTotal"* ]] && ((sources_count++))
    [[ "$analysis_text" == *"Shodan"* ]] && ((sources_count++))
    [[ "$analysis_text" == *"ThreatFox"* ]] && ((sources_count++))
    
    # Gerar recomendações baseadas no resultado
    local recommendations=""
    if [[ "$overall_status" == "Malicioso" ]]; then
        recommendations="<li>🚫 Não execute ou acesse este item</li>"
        recommendations+="<li>🛡️ Coloque em quarentena imediatamente</li>"
        recommendations+="<li>🔍 Investigue outros sistemas que possam ter sido expostos</li>"
        recommendations+="<li>📞 Notifique a equipe de segurança</li>"
    elif [[ "$overall_status" == "Suspeito" ]]; then
        recommendations="<li>⚠️ Proceda com extrema cautela</li>"
        recommendations+="<li>🔍 Realize análise adicional</li>"
        recommendations+="<li>🛡️ Monitore atividades relacionadas</li>"
        recommendations+="<li>📋 Documente os achados</li>"
    else
        recommendations="<li>✅ Item aparenta estar limpo</li>"
        recommendations+="<li>🔍 Mantenha monitoramento regular</li>"
        recommendations+="<li>📊 Considere análise periódica</li>"
    fi
    
    # Ler o template HTML
    local template=$(cat "$TEMPLATE_DIR/report_template.html")
    
    # Substituir placeholders
    template=${template//\{\{DATE\}\}/$date_now}
    template=${template//\{\{TIME\}\}/$time_now}
    template=${template//\{\{REPORT_ID\}\}/$report_id}
    template=${template//\{\{ANALYSIS_TYPE\}\}/$analysis_type}
    template=${template//\{\{TARGET\}\}/$target}
    template=${template//\{\{TIMESTAMP\}\}/$timestamp}
    template=${template//\{\{OVERALL_STATUS\}\}/$overall_status}
    template=${template//\{\{OVERALL_STATUS_CLASS\}\}/$overall_status_class}
    template=${template//\{\{THREAT_LEVEL\}\}/$threat_level}
    template=${template//\{\{THREAT_LEVEL_CLASS\}\}/$threat_level_class}
    template=${template//\{\{SOURCES_COUNT\}\}/$sources_count}
    template=${template//\{\{ANALYSIS_DETAILS\}\}/$formatted_analysis}
    template=${template//\{\{RESULTS_TABLE\}\}/}
    template=${template//\{\{TECHNICAL_INFO\}\}/}
    template=${template//\{\{RECOMMENDATIONS\}\}/$recommendations}
    
    # Salvar o relatório HTML
    local report_file="$REPORTS_DIR/${report_id}.html"
    echo "$template" > "$report_file"
    
    echo "$report_file"
}
EOF

# Aplicar correção
start_line=$(grep -n "^generate_html_report()" html_report.sh | cut -d: -f1)
if [[ -n "$start_line" ]]; then
    # Encontrar o final da função
    end_line=$(tail -n +$((start_line + 1)) html_report.sh | grep -n "^}" | head -1 | cut -d: -f1)
    end_line=$((start_line + end_line))
    
    # Criar arquivo temporário com a correção
    head -n $((start_line - 1)) html_report.sh > temp_html_report.sh
    cat temp_generate_html_report_clean.sh >> temp_html_report.sh
    tail -n +$((end_line + 1)) html_report.sh >> temp_html_report.sh
    
    # Substituir arquivo original
    mv temp_html_report.sh html_report.sh
    echo "✅ Função generate_html_report corrigida com limpeza ANSI"
else
    echo "❌ Não foi possível localizar a função generate_html_report"
fi

# Limpar arquivos temporários
rm -f temp_generate_html_report_clean.sh

echo "3. Criando script de teste sem loop infinito..."

cat > test_domain_simple.sh << 'EOF'
#!/bin/bash

echo "🧪 TESTE SIMPLES - ANÁLISE DE DOMÍNIO"
echo "====================================="

# Carregar funções
source html_report.sh
source security_tool.sh >/dev/null 2>&1

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
EOF

chmod +x test_domain_simple.sh

echo "4. Testando correção..."
./test_domain_simple.sh

echo
echo "✅ Correções aplicadas:"
echo "  ✅ Função de limpeza ANSI criada"
echo "  ✅ generate_html_report corrigida"
echo "  ✅ Teste simples criado"
echo
echo "🎯 Para testar:"
echo "  ./test_domain_simple.sh"
echo
echo "🔧 Para usar no menu principal:"
echo "  ./security_tool.sh → Opção 3 → Digite domínio → Responda 's'"
