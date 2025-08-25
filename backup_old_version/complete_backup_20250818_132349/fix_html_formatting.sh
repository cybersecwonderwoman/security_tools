#!/bin/bash

echo "🔧 CORREÇÃO DA FORMATAÇÃO DOS RELATÓRIOS HTML"
echo "============================================="
echo

# Função para converter texto para HTML
convert_text_to_html() {
    local text="$1"
    
    # Converter quebras de linha para <br>
    text=$(echo "$text" | sed 's/\\n/<br>/g')
    
    # Converter seções em cabeçalhos
    text=$(echo "$text" | sed 's/\[\([^]]*\)\]/<h3 style="color: #3498db; margin-top: 20px;">\1<\/h3>/g')
    
    # Converter linhas que começam com espaços em parágrafos
    text=$(echo "$text" | sed 's/^  \(.*\)/<p style="margin-left: 20px;">\1<\/p>/g')
    
    # Converter texto de status
    text=$(echo "$text" | sed 's/✅/<span style="color: #2ecc71;">✅<\/span>/g')
    text=$(echo "$text" | sed 's/❌/<span style="color: #e74c3c;">❌<\/span>/g')
    text=$(echo "$text" | sed 's/⚠️/<span style="color: #f39c12;">⚠️<\/span>/g')
    
    echo "$text"
}

# Backup da função original
echo "1. Fazendo backup da função original..."
cp html_report.sh html_report.sh.backup.formatting

# Criar nova versão da função generate_html_report
echo "2. Criando versão corrigida..."

cat > temp_generate_html_report.sh << 'EOF'
# Função principal para gerar relatório HTML (versão corrigida)
generate_html_report() {
    local analysis_type="$1"
    local target="$2"
    local analysis_text="$3"
    
    local report_id=$(generate_report_id)
    local date_now=$(date '+%d/%m/%Y')
    local time_now=$(date '+%H:%M:%S')
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Converter texto para HTML com formatação adequada
    local formatted_analysis=""
    
    # Processar linha por linha
    while IFS= read -r line; do
        # Pular linhas vazias
        [[ -z "$line" ]] && continue
        
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

# Encontrar e substituir a função no arquivo original
echo "3. Aplicando correção..."

start_line=$(grep -n "^generate_html_report()" html_report.sh | cut -d: -f1)
if [[ -n "$start_line" ]]; then
    # Encontrar o final da função (próxima linha que começa com '}' no nível raiz)
    end_line=$(tail -n +$((start_line + 1)) html_report.sh | grep -n "^}" | head -1 | cut -d: -f1)
    end_line=$((start_line + end_line))
    
    # Criar arquivo temporário com a correção
    head -n $((start_line - 1)) html_report.sh > temp_html_report.sh
    cat temp_generate_html_report.sh >> temp_html_report.sh
    tail -n +$((end_line + 1)) html_report.sh >> temp_html_report.sh
    
    # Substituir arquivo original
    mv temp_html_report.sh html_report.sh
    echo "✅ Função generate_html_report corrigida"
else
    echo "❌ Não foi possível localizar a função generate_html_report"
fi

# Limpar arquivos temporários
rm -f temp_generate_html_report.sh

echo
echo "4. Testando correção..."

# Gerar um relatório de teste
source html_report.sh

test_content="📁 ANÁLISE DE ARQUIVO

[Informações Básicas]
Nome: teste.txt
Tipo: Arquivo de texto
Tamanho: 1024 bytes

[Análise de Malware]
✅ Nenhuma ameaça detectada
Status: Limpo
Recomendação: Arquivo seguro

[VirusTotal]
Detecções: 0/70 engines

Análise concluída em $(date '+%Y-%m-%d %H:%M:%S')"

echo "📄 Gerando relatório de teste..."
test_report=$(generate_html_report "Teste Formatação" "teste_formatacao.txt" "$test_content")

if [[ -f "$test_report" ]]; then
    echo "✅ Relatório de teste gerado: $(basename "$test_report")"
    
    # Verificar se o HTML está bem formatado
    if grep -q "<h3.*Informações Básicas" "$test_report"; then
        echo "✅ Formatação HTML aplicada corretamente"
    else
        echo "❌ Problema na formatação HTML"
    fi
    
    echo "🌐 Para testar:"
    echo "   source html_report.sh"
    echo "   open_report \"$test_report\""
    
else
    echo "❌ Erro ao gerar relatório de teste"
fi

echo
echo "✅ Correção da formatação HTML concluída!"
echo
echo "🎯 Agora os relatórios HTML devem exibir o conteúdo corretamente formatado no navegador."
