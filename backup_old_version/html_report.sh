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
# Função principal para gerar relatório HTML (versão corrigida)
# Função principal para gerar relatório HTML (versão com limpeza ANSI)
# Função principal para gerar relatório HTML (versão com limpeza ANSI)
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

# Função para abrir o relatório no navegador (versão corrigida)
# Função para abrir o relatório no navegador (versão com nova janela forçada)
open_report() {
    local report_file="$1"
    local report_name=$(basename "$report_file")
    
    echo "🌐 Abrindo relatório: $report_name"
    
    # Verificar se o arquivo existe
    if [[ ! -f "$report_file" ]]; then
        echo "❌ Arquivo de relatório não encontrado: $report_file"
        return 1
    fi
    
    # Verificar se o servidor já está rodando
    if ! pgrep -f "python.*http.server.*$PORT" &>/dev/null && ! pgrep -f "python.*SimpleHTTPServer.*$PORT" &>/dev/null; then
        echo "🚀 Iniciando servidor web..."
        start_report_server
        sleep 2
    else
        echo "✅ Servidor já está rodando"
    fi
    
    # Verificar se o servidor está respondendo
    local max_attempts=5
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -s -I "http://localhost:$PORT/" >/dev/null 2>&1; then
            echo "✅ Servidor respondendo (tentativa $attempt)"
            break
        else
            echo "⏳ Aguardando servidor... (tentativa $attempt)"
            sleep 2
            ((attempt++))
        fi
    done
    
    if [[ $attempt -gt $max_attempts ]]; then
        echo "❌ Servidor não está respondendo após $max_attempts tentativas"
        echo "🔧 Tentando reiniciar servidor..."
        stop_report_server
        sleep 1
        start_report_server
        sleep 3
    fi
    
    # URL do relatório
    local report_url="http://localhost:$PORT/$report_name"
    
    # Verificar se o relatório está acessível
    if curl -s -I "$report_url" >/dev/null 2>&1; then
        echo "✅ Relatório acessível em: $report_url"
        
        # NOVA ABORDAGEM: Tentar múltiplos métodos com nova janela forçada
        local opened=false
        
        # Método 1: Firefox com nova janela
        if command -v firefox &>/dev/null && [[ "$opened" == false ]]; then
            echo "🌐 Tentando abrir com Firefox (nova janela)..."
            if firefox --new-window "$report_url" &>/dev/null & then
                echo "✅ Firefox executado"
                opened=true
                sleep 2
            fi
        fi
        
        # Método 2: Google Chrome com nova janela
        if command -v google-chrome &>/dev/null && [[ "$opened" == false ]]; then
            echo "🌐 Tentando abrir com Google Chrome (nova janela)..."
            if google-chrome --new-window "$report_url" &>/dev/null & then
                echo "✅ Google Chrome executado"
                opened=true
                sleep 2
            fi
        fi
        
        # Método 3: Chromium com nova janela
        if command -v chromium-browser &>/dev/null && [[ "$opened" == false ]]; then
            echo "🌐 Tentando abrir com Chromium (nova janela)..."
            if chromium-browser --new-window "$report_url" &>/dev/null & then
                echo "✅ Chromium executado"
                opened=true
                sleep 2
            fi
        fi
        
        # Método 4: xdg-open como fallback
        if [[ "$opened" == false ]]; then
            echo "🌐 Usando xdg-open como fallback..."
            if command -v xdg-open &>/dev/null; then
                xdg-open "$report_url" &
                echo "✅ xdg-open executado"
                opened=true
            fi
        fi
        
        if [[ "$opened" == true ]]; then
            echo "🎯 Relatório disponível em: $report_url"
            echo ""
            echo "📋 INSTRUÇÕES:"
            echo "   - O navegador deve abrir em NOVA JANELA"
            echo "   - Se não aparecer, verifique a barra de tarefas"
            echo "   - Ou acesse manualmente: $report_url"
            echo "   - Use Alt+Tab para encontrar a janela"
        else
            echo "⚠️  Não foi possível abrir automaticamente"
            echo "📋 Acesse manualmente: $report_url"
        fi
        
        return 0
    else
        echo "❌ Relatório não está acessível via HTTP"
        echo "📁 Arquivo local: $report_file"
        return 1
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
# Função para abrir relatório com controle do usuário
open_report_controlled() {
    local report_file="$1"
    local report_name=$(basename "$report_file")
    
    if [[ ! -f "$report_file" ]]; then
        echo "❌ Arquivo de relatório não encontrado: $report_file"
        return 1
    fi
    
    echo
    echo "📄 Relatório HTML gerado: $report_name"
    echo "🌐 Deseja abrir o relatório no navegador? (s/n): "
    read -r open_choice
    
    if [[ "$open_choice" =~ ^[Ss]$ ]]; then
        echo
        echo "🚀 Iniciando servidor web temporário..."
        
        # Parar qualquer servidor existente
        pkill -f "python.*http.server.*$PORT" 2>/dev/null
        pkill -f "python.*SimpleHTTPServer.*$PORT" 2>/dev/null
        sleep 1
        
        # Ir para o diretório de relatórios
        cd "$(dirname "$report_file")"
        
        # Iniciar servidor em background
        python3 -m http.server $PORT > /dev/null 2>&1 &
        local server_pid=$!
        
        # Aguardar servidor inicializar
        sleep 2
        
        # Verificar se o servidor está rodando
        if kill -0 $server_pid 2>/dev/null; then
            echo "✅ Servidor iniciado (PID: $server_pid)"
            
            local report_url="http://localhost:$PORT/$report_name"
            
            # Verificar se o relatório está acessível
            if curl -s -I "$report_url" >/dev/null 2>&1; then
                echo "✅ Relatório acessível em: $report_url"
                echo
                echo "🌐 Abrindo navegador..."
                
                # Tentar abrir com diferentes métodos
                local opened=false
                
                if command -v firefox &>/dev/null; then
                    echo "🦊 Abrindo com Firefox..."
                    firefox --new-window "$report_url" &>/dev/null &
                    opened=true
                elif command -v google-chrome &>/dev/null; then
                    echo "🌐 Abrindo com Google Chrome..."
                    google-chrome --new-window "$report_url" &>/dev/null &
                    opened=true
                elif command -v xdg-open &>/dev/null; then
                    echo "🔗 Abrindo com xdg-open..."
                    xdg-open "$report_url" &>/dev/null &
                    opened=true
                fi
                
                if [[ "$opened" == true ]]; then
                    echo "✅ Navegador executado"
                    echo
                    echo "📋 INSTRUÇÕES:"
                    echo "   - O relatório deve abrir no navegador"
                    echo "   - Se não aparecer, acesse: $report_url"
                    echo "   - Pressione ENTER quando terminar de visualizar"
                    echo
                    echo -n "⏳ Pressione ENTER para finalizar o servidor..."
                    read -r
                    
                    # Parar servidor
                    echo "🛑 Finalizando servidor..."
                    kill $server_pid 2>/dev/null
                    sleep 1
                    
                    # Verificar se o servidor foi parado
                    if kill -0 $server_pid 2>/dev/null; then
                        echo "⚠️  Forçando parada do servidor..."
                        kill -9 $server_pid 2>/dev/null
                    fi
                    
                    echo "✅ Servidor finalizado"
                else
                    echo "❌ Não foi possível abrir o navegador automaticamente"
                    echo "📋 Acesse manualmente: $report_url"
                    echo -n "⏳ Pressione ENTER para finalizar o servidor..."
                    read -r
                    kill $server_pid 2>/dev/null
                fi
            else
                echo "❌ Relatório não está acessível"
                kill $server_pid 2>/dev/null
                return 1
            fi
        else
            echo "❌ Falha ao iniciar servidor"
            return 1
        fi
    else
        echo "📁 Relatório salvo em: $report_file"
        echo "🌐 Para visualizar depois, acesse:"
        echo "   cd $(dirname "$report_file")"
        echo "   python3 -m http.server $PORT"
        echo "   Navegador: http://localhost:$PORT/$report_name"
    fi
    
    return 0
}
