#!/bin/bash

# ========================================
# HTML Report Generator for Security Analyzer Tool
# ========================================

# Configurações
CONFIG_DIR="$HOME/.security_analyzer"
REPORTS_DIR="$CONFIG_DIR/reports"
TEMPLATE_DIR="$(dirname "$(readlink -f "$0")")/html_templates"
PORT=8080

# Criar diretório de relatórios se não existir
mkdir -p "$REPORTS_DIR"

# Função para gerar um ID de relatório único
generate_report_id() {
    echo "SA-$(date +%Y%m%d)-$(openssl rand -hex 4)"
}

# Função para limpar códigos ANSI do texto
clean_ansi_codes() {
    local text="$1"
    
    # Remover todos os códigos ANSI de escape (múltiplas variações)
    text=$(echo "$text" | sed -E 's/\x1B\[[0-9;]*[mK]//g')
    text=$(echo "$text" | sed -E 's/\033\[[0-9;]*[mK]//g')
    text=$(echo "$text" | sed -E 's/␛\[[0-9;]*[mK]//g')
    text=$(echo "$text" | sed -E 's/\[[0-9;]*m//g')
    
    # Remover sequências específicas que podem aparecer
    text=$(echo "$text" | sed -E 's/\x1B\[0;31m//g')
    text=$(echo "$text" | sed -E 's/\x1B\[0;32m//g')
    text=$(echo "$text" | sed -E 's/\x1B\[1;33m//g')
    text=$(echo "$text" | sed -E 's/\x1B\[0;34m//g')
    text=$(echo "$text" | sed -E 's/\x1B\[0;35m//g')
    text=$(echo "$text" | sed -E 's/\x1B\[0;36m//g')
    text=$(echo "$text" | sed -E 's/\x1B\[0m//g')
    
    # Remover caracteres de controle visíveis
    text=$(echo "$text" | tr -d '\033')
    
    echo "$text"
}

# Função para determinar a classe CSS baseada no status
get_status_class() {
    local status="$1"
    
    case "$status" in
        *"Limpo"*|*"Seguro"*|*"0 detecções"*)
            echo "safe"
            ;;
        *"Suspeito"*|*"Atenção"*)
            echo "warning"
            ;;
        *"Malicioso"*|*"Perigoso"*|*"Ameaça"*)
            echo "danger"
            ;;
        *)
            echo "warning"
            ;;
    esac
}

# Função para determinar o nível de ameaça baseado no texto da análise
determine_threat_level() {
    local analysis_text="$1"
    
    if [[ "$analysis_text" == *"AMEAÇA DETECTADA"* || "$analysis_text" == *"Malicioso"* ]]; then
        echo "Alto"
    elif [[ "$analysis_text" == *"Suspeito"* ]]; then
        echo "Médio"
    else
        echo "Baixo"
    fi
}

# Função para gerar recomendações baseadas no tipo de análise e resultados
generate_recommendations() {
    local analysis_type="$1"
    local analysis_text="$2"
    local recommendations=""
    
    case "$analysis_type" in
        "Arquivo")
            if [[ "$analysis_text" == *"AMEAÇA DETECTADA"* ]]; then
                recommendations+="<li>Isole o arquivo em uma pasta segura ou exclua-o imediatamente</li>"
                recommendations+="<li>Execute uma varredura completa do sistema com seu antivírus</li>"
                recommendations+="<li>Verifique outros arquivos do mesmo diretório</li>"
            else
                recommendations+="<li>Mantenha seu antivírus atualizado para proteção contínua</li>"
                recommendations+="<li>Considere verificar periodicamente arquivos baixados da internet</li>"
            fi
            ;;
        "URL")
            if [[ "$analysis_text" == *"AMEAÇA DETECTADA"* || "$analysis_text" == *"Malicioso"* ]]; then
                recommendations+="<li>Evite acessar esta URL em qualquer dispositivo</li>"
                recommendations+="<li>Se você já acessou, verifique seu sistema com um antivírus</li>"
                recommendations+="<li>Considere alterar suas senhas se inseriu credenciais neste site</li>"
            else
                recommendations+="<li>Sempre verifique URLs antes de inserir informações sensíveis</li>"
                recommendations+="<li>Utilize extensões de navegador para proteção contra phishing</li>"
            fi
            ;;
        "Domínio")
            if [[ "$analysis_text" == *"AMEAÇA DETECTADA"* || "$analysis_text" == *"Malicioso"* ]]; then
                recommendations+="<li>Evite qualquer interação com este domínio</li>"
                recommendations+="<li>Considere bloquear este domínio em seu firewall ou DNS</li>"
                recommendations+="<li>Verifique se há outros domínios relacionados</li>"
            else
                recommendations+="<li>Monitore regularmente domínios críticos para sua organização</li>"
                recommendations+="<li>Implemente DMARC, SPF e DKIM para seus domínios</li>"
            fi
            ;;
        "Hash")
            if [[ "$analysis_text" == *"AMEAÇA DETECTADA"* || "$analysis_text" == *"Malicioso"* ]]; then
                recommendations+="<li>Localize e remova qualquer arquivo com este hash</li>"
                recommendations+="<li>Investigue como este arquivo chegou ao sistema</li>"
                recommendations+="<li>Verifique logs de sistema para atividades suspeitas</li>"
            else
                recommendations+="<li>Mantenha uma base de hashes conhecidos para referência futura</li>"
                recommendations+="<li>Considere implementar whitelisting de aplicações</li>"
            fi
            ;;
        "Email")
            if [[ "$analysis_text" == *"AMEAÇA DETECTADA"* || "$analysis_text" == *"Suspeito"* ]]; then
                recommendations+="<li>Não responda ou clique em links deste email</li>"
                recommendations+="<li>Reporte o email como phishing para sua equipe de segurança</li>"
                recommendations+="<li>Verifique se outros usuários receberam emails similares</li>"
            else
                recommendations+="<li>Implemente filtros de spam e phishing em sua organização</li>"
                recommendations+="<li>Treine usuários para identificar emails suspeitos</li>"
            fi
            ;;
        "IP")
            if [[ "$analysis_text" == *"AMEAÇA DETECTADA"* || "$analysis_text" == *"Malicioso"* ]]; then
                recommendations+="<li>Bloqueie este IP em seu firewall</li>"
                recommendations+="<li>Investigue qualquer comunicação prévia com este IP</li>"
                recommendations+="<li>Verifique logs de acesso para atividades suspeitas</li>"
            else
                recommendations+="<li>Monitore regularmente tráfego de rede para IPs desconhecidos</li>"
                recommendations+="<li>Implemente um sistema de detecção de intrusão</li>"
            fi
            ;;
        *)
            recommendations+="<li>Mantenha seus sistemas e softwares atualizados</li>"
            recommendations+="<li>Implemente uma política de segurança abrangente</li>"
            recommendations+="<li>Realize análises de segurança periódicas</li>"
            ;;
    esac
    
    echo "$recommendations"
}

# Função para extrair resultados por fonte
extract_results_by_source() {
    local analysis_text="$1"
    local results_table=""
    
    # Extrair resultados de VirusTotal
    if [[ "$analysis_text" == *"[VirusTotal]"* ]]; then
        local vt_line=$(echo "$analysis_text" | grep -A 2 "\[VirusTotal\]")
        local vt_status=$(echo "$vt_line" | head -n 1)
        local vt_details=$(echo "$vt_line" | tail -n 2)
        local status_class=$(get_status_class "$vt_status")
        
        results_table+="<tr>"
        results_table+="<td>VirusTotal</td>"
        results_table+="<td><span class=\"status-badge $status_class\">$(echo "$vt_status" | sed -E 's/.*\[(.*)\].*/\1/')</span></td>"
        results_table+="<td>$vt_details</td>"
        results_table+="</tr>"
    fi
    
    # Extrair resultados de ThreatFox
    if [[ "$analysis_text" == *"[ThreatFox]"* ]]; then
        local tf_line=$(echo "$analysis_text" | grep -A 1 "\[ThreatFox\]")
        local tf_status=$(echo "$tf_line" | head -n 1)
        local tf_details=$(echo "$tf_line" | tail -n 1)
        local status_class=$(get_status_class "$tf_status")
        
        results_table+="<tr>"
        results_table+="<td>ThreatFox</td>"
        results_table+="<td><span class=\"status-badge $status_class\">$(echo "$tf_status" | sed -E 's/.*\[(.*)\].*/\1/')</span></td>"
        results_table+="<td>$tf_details</td>"
        results_table+="</tr>"
    fi
    
    # Adicionar outras fontes conforme necessário
    # Se não encontrou nenhuma fonte específica, adicionar uma entrada genérica
    if [[ -z "$results_table" ]]; then
        results_table+="<tr>"
        results_table+="<td>Análise Local</td>"
        results_table+="<td><span class=\"status-badge warning\">Informativo</span></td>"
        results_table+="<td>Análise básica realizada localmente</td>"
        results_table+="</tr>"
    fi
    
    echo "$results_table"
}

# Função principal para gerar relatório HTML
generate_html_report() {
    local analysis_type="$1"
    local target="$2"
    local analysis_text="$3"
    
    local report_id=$(generate_report_id)
    local date_now=$(date '+%d/%m/%Y')
    local time_now=$(date '+%H:%M:%S')
    local timestamp="$date_now $time_now"
    
    # Determinar status geral e nível de ameaça
    local overall_status="Limpo"
    if [[ "$analysis_text" == *"AMEAÇA DETECTADA"* || "$analysis_text" == *"Malicioso"* ]]; then
        overall_status="Malicioso"
    elif [[ "$analysis_text" == *"Suspeito"* ]]; then
        overall_status="Suspeito"
    fi
    
    local overall_status_class=$(get_status_class "$overall_status")
    local threat_level=$(determine_threat_level "$analysis_text")
    local threat_level_class=$(get_status_class "$threat_level")
    
    # Contar fontes consultadas (simplificado)
    local sources_count=1
    if [[ "$analysis_text" == *"[VirusTotal]"* ]]; then ((sources_count++)); fi
    if [[ "$analysis_text" == *"[ThreatFox]"* ]]; then ((sources_count++)); fi
    if [[ "$analysis_text" == *"[URLScan]"* ]]; then ((sources_count++)); fi
    if [[ "$analysis_text" == *"[Shodan]"* ]]; then ((sources_count++)); fi
    
    # Preparar detalhes da análise com formatação melhorada
    local analysis_details=""
    
    # Limpar códigos ANSI do texto de análise
    local clean_text=$(clean_ansi_codes "$analysis_text")
    
    # Processar o texto linha por linha para melhor formatação
    while IFS= read -r line; do
        # Pular linhas vazias
        if [[ -z "$line" ]]; then
            analysis_details+="<br>"
            continue
        fi
        
        # Destacar cabeçalhos entre colchetes
        if [[ "$line" == *"["*"]"* ]]; then
            # Extrair apenas o texto entre colchetes
            local header=$(echo "$line" | grep -o '\[.*\]')
            
            # Adicionar espaçamento antes de novos cabeçalhos (exceto o primeiro)
            if [[ "$analysis_details" != "" ]]; then
                analysis_details+="<br><br>"
            fi
            
            # Usar apenas o cabeçalho formatado, sem duplicar
            analysis_details+="<div class=\"section-header\"><strong style=\"color: #3498db;\">$header</strong></div>"
        else
            # Processar linhas normais
            # Verificar se é uma linha com ":" para formatar como par chave-valor
            if [[ "$line" == *":"* && ! "$line" == "http"* && ! "$line" == "https"* ]]; then
                local key=$(echo "$line" | cut -d':' -f1)
                local value=$(echo "$line" | cut -d':' -f2-)
                analysis_details+="<div class=\"detail-item\"><span class=\"detail-key\">$key:</span>$value</div>"
            else
                analysis_details+="<div class=\"detail-text\">$line</div>"
            fi
        fi
    done <<< "$clean_text"
    
    # Extrair resultados por fonte
    local results_table=$(extract_results_by_source "$analysis_text")
    
    # Gerar recomendações
    local recommendations=$(generate_recommendations "$analysis_type" "$analysis_text")
    
    # Preparar informações técnicas com formatação melhorada
    local technical_info=""
    local tech_data=""
    
    # Limpar códigos ANSI do texto de análise
    local clean_analysis_text=$(clean_ansi_codes "$analysis_text")
    
    case "$analysis_type" in
        "Arquivo")
            # Extrair informações de hash e formatar adequadamente
            tech_data=$(echo "$clean_analysis_text" | grep -A 5 "\[Hashes\]")
            ;;
        "URL")
            tech_data="URL: $target"
            if [[ "$clean_analysis_text" == *"Domínio:"* ]]; then
                tech_data+=$'\n'$(echo "$clean_analysis_text" | grep "Domínio:")
            fi
            if [[ "$clean_analysis_text" == *"Caminho:"* ]]; then
                tech_data+=$'\n'$(echo "$clean_analysis_text" | grep "Caminho:")
            fi
            if [[ "$clean_analysis_text" == *"Parâmetros:"* ]]; then
                tech_data+=$'\n'$(echo "$clean_analysis_text" | grep "Parâmetros:")
            fi
            ;;
        "Domínio")
            tech_data="Domínio: $target"
            if [[ "$clean_analysis_text" == *"Registros DNS"* ]]; then
                tech_data+=$'\n\nRegistros DNS:'
                tech_data+=$'\n'$(echo "$clean_analysis_text" | grep -A 5 "Registros DNS" | grep -v "Registros DNS")
            fi
            ;;
        "Hash")
            tech_data="Hash: $target"
            if [[ "$clean_analysis_text" == *"Tipo:"* ]]; then
                tech_data+=$'\n'$(echo "$clean_analysis_text" | grep "Tipo:")
            fi
            ;;
        "Email")
            tech_data="Email: $target"
            if [[ "$clean_analysis_text" == *"Domínio:"* ]]; then
                tech_data+=$'\n'$(echo "$clean_analysis_text" | grep "Domínio:")
            fi
            ;;
        "IP")
            tech_data="IP: $target"
            if [[ "$clean_analysis_text" == *"Localização:"* ]]; then
                tech_data+=$'\n'$(echo "$clean_analysis_text" | grep "Localização:")
            fi
            if [[ "$clean_analysis_text" == *"ASN:"* ]]; then
                tech_data+=$'\n'$(echo "$clean_analysis_text" | grep "ASN:")
            fi
            ;;
        *)
            tech_data="Tipo de análise: $analysis_type"
            tech_data+=$'\n'"Alvo: $target"
            ;;
    esac
    
    # Formatar as informações técnicas em HTML
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            technical_info+="<br>"
            continue
        fi
        
        # Formatar pares chave-valor
        if [[ "$line" == *":"* ]]; then
            local key=$(echo "$line" | cut -d':' -f1)
            local value=$(echo "$line" | cut -d':' -f2-)
            technical_info+="<div class=\"tech-item\"><span class=\"tech-key\">$key:</span>$value</div>"
        else
            technical_info+="<div>$line</div>"
        fi
    done <<< "$tech_data"
    
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
    template=${template//\{\{ANALYSIS_DETAILS\}\}/$analysis_details}
    template=${template//\{\{RESULTS_TABLE\}\}/$results_table}
    template=${template//\{\{TECHNICAL_INFO\}\}/$technical_info}
    template=${template//\{\{RECOMMENDATIONS\}\}/$recommendations}
    
    # Salvar o relatório HTML
    local report_file="$REPORTS_DIR/${report_id}.html"
    echo "$template" > "$report_file"
    
    echo "$report_file"
}

# Função para iniciar um servidor web simples para servir os relatórios
start_report_server() {
    # Verificar se o Python está instalado
    if command -v python3 &>/dev/null; then
        cd "$REPORTS_DIR" && python3 -m http.server $PORT &
        echo "Servidor iniciado em http://localhost:$PORT/"
        return 0
    elif command -v python &>/dev/null; then
        cd "$REPORTS_DIR" && python -m SimpleHTTPServer $PORT &
        echo "Servidor iniciado em http://localhost:$PORT/"
        return 0
    else
        echo "Erro: Python não encontrado. Não foi possível iniciar o servidor."
        return 1
    fi
}

# Função para abrir o relatório no navegador
open_report() {
    local report_file="$1"
    local report_name=$(basename "$report_file")
    
    # Verificar se o servidor já está rodando
    if ! pgrep -f "python.*http.server $PORT" &>/dev/null && ! pgrep -f "python.*SimpleHTTPServer $PORT" &>/dev/null; then
        start_report_server
    fi
    
    # Abrir o navegador
    if command -v xdg-open &>/dev/null; then
        xdg-open "http://localhost:$PORT/$report_name"
    elif command -v open &>/dev/null; then
        open "http://localhost:$PORT/$report_name"
    else
        echo "Não foi possível abrir o navegador automaticamente."
        echo "Por favor, acesse: http://localhost:$PORT/$report_name"
    fi
}

# Função para parar o servidor
stop_report_server() {
    pkill -f "python.*http.server $PORT" 2>/dev/null
    pkill -f "python.*SimpleHTTPServer $PORT" 2>/dev/null
    echo "Servidor parado."
}

# Exportar funções para uso em outros scripts
export -f generate_html_report
export -f open_report
export -f stop_report_server
