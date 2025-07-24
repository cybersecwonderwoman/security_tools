#!/bin/bash

# ========================================
# Script de integração de relatórios HTML para Security Analyzer Tool
# ========================================

# Importar funções do script de relatórios HTML
source "$(dirname "$(readlink -f "$0")")/html_report.sh"

# Função para capturar a saída de uma análise e gerar um relatório HTML
capture_and_report() {
    local analysis_type="$1"
    local target="$2"
    local analysis_function="$3"
    
    # Criar arquivo temporário para capturar a saída
    local temp_output=$(mktemp)
    
    # Executar a função de análise e capturar a saída
    $analysis_function "$target" | tee "$temp_output"
    
    # Gerar relatório HTML com a saída capturada
    local analysis_text=$(cat "$temp_output")
    local report_file=$(generate_html_report "$analysis_type" "$target" "$analysis_text")
    
    # Remover arquivo temporário
    rm -f "$temp_output"
    
    # Perguntar se deseja abrir o relatório no navegador
    echo
    echo -e "${CYAN}Relatório HTML gerado: $report_file${NC}"
    echo -n "Deseja abrir o relatório no navegador? (s/n): "
    read -r open_browser
    
    if [[ "$open_browser" == "s" || "$open_browser" == "S" ]]; then
        open_report "$report_file"
    fi
}

# Função para analisar arquivo com relatório HTML
analyze_file_with_report() {
    local file_path="$1"
    capture_and_report "Arquivo" "$file_path" "analyze_file_internal"
}

# Função para analisar URL com relatório HTML
analyze_url_with_report() {
    local url="$1"
    capture_and_report "URL" "$url" "analyze_url_internal"
}

# Função para analisar domínio com relatório HTML
analyze_domain_with_report() {
    local domain="$1"
    capture_and_report "Domínio" "$domain" "analyze_domain_internal"
}

# Função para analisar hash com relatório HTML
analyze_hash_with_report() {
    local hash="$1"
    capture_and_report "Hash" "$hash" "analyze_hash_internal"
}

# Função para analisar email com relatório HTML
analyze_email_with_report() {
    local email="$1"
    capture_and_report "Email" "$email" "analyze_email_internal"
}

# Função para analisar cabeçalho de email com relatório HTML
analyze_header_with_report() {
    local header_file="$1"
    capture_and_report "Cabeçalho de Email" "$header_file" "analyze_header_internal"
}

# Função para analisar IP com relatório HTML
analyze_ip_with_report() {
    local ip="$1"
    capture_and_report "IP" "$ip" "analyze_ip_internal"
}

# Função para listar relatórios gerados
list_reports() {
    local reports_dir="$HOME/.security_analyzer/reports"
    
    echo -e "${CYAN}📋 RELATÓRIOS GERADOS${NC}"
    echo
    
    if [[ ! -d "$reports_dir" ]]; then
        echo "❌ Diretório de relatórios não encontrado."
        echo "Nenhum relatório foi gerado ainda."
        return
    fi
    
    # Contar relatórios
    local report_count=$(find "$reports_dir" -name "*.html" -type f 2>/dev/null | wc -l)
    
    if [[ $report_count -eq 0 ]]; then
        echo "📄 Nenhum relatório encontrado."
        echo "Execute uma análise para gerar relatórios."
        return
    fi
    
    echo "📊 Total de relatórios: $report_count"
    echo
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ID do Relatório          │ Data       │ Tipo        │ Status      │ Alvo     ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    
    # Listar relatórios ordenados por data (mais recente primeiro)
    local counter=1
    for report in $(find "$reports_dir" -name "*.html" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2-); do
        if [[ ! -f "$report" ]]; then
            continue
        fi
        
        local report_name=$(basename "$report" .html)
        local report_date=$(echo "$report_name" | cut -d'-' -f2)
        local report_date_formatted="${report_date:6:2}/${report_date:4:2}/${report_date:0:4}"
        
        # Extrair informações do arquivo HTML
        local analysis_type=$(grep -o '<strong>Tipo de Análise:</strong> [^<]*' "$report" 2>/dev/null | sed 's/<strong>Tipo de Análise:<\/strong> //' | head -1)
        local target=$(grep -o '<strong>Alvo:</strong> [^<]*' "$report" 2>/dev/null | sed 's/<strong>Alvo:<\/strong> //' | head -1)
        local overall_status=$(grep -o 'Status Geral</h3>[^<]*<p>[^<]*' "$report" 2>/dev/null | sed 's/.*<p>//' | head -1)
        
        # Valores padrão se não encontrar
        [[ -z "$analysis_type" ]] && analysis_type="N/A"
        [[ -z "$target" ]] && target="N/A"
        [[ -z "$overall_status" ]] && overall_status="N/A"
        
        # Truncar strings longas
        [[ ${#target} -gt 15 ]] && target="${target:0:12}..."
        [[ ${#analysis_type} -gt 10 ]] && analysis_type="${analysis_type:0:7}..."
        [[ ${#overall_status} -gt 10 ]] && overall_status="${overall_status:0:7}..."
        
        # Colorir status
        local status_color=""
        case "$overall_status" in
            *"Limpo"*|*"Seguro"*)
                status_color="${GREEN}"
                ;;
            *"Suspeito"*)
                status_color="${YELLOW}"
                ;;
            *"Malicioso"*|*"Perigoso"*)
                status_color="${RED}"
                ;;
            *)
                status_color="${NC}"
                ;;
        esac
        
        printf "${BLUE}│${NC} %-2d %-18s │ %-10s │ %-11s │ %s%-11s${NC} │ %-8s ${BLUE}│${NC}\n" \
            "$counter" "$report_name" "$report_date_formatted" "$analysis_type" \
            "$status_color" "$overall_status" "$target"
        
        ((counter++))
        
        # Limitar a 20 relatórios por página
        if [[ $counter -gt 20 ]]; then
            echo -e "${BLUE}│${NC} ... e mais $((report_count - 20)) relatórios                                    ${BLUE}│${NC}"
            break
        fi
    done
    
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
    
    # Menu de opções
    echo -e "${CYAN}Opções:${NC}"
    echo "  [1-$counter] Abrir relatório específico"
    echo "  [a] Abrir todos os relatórios recentes (últimos 5)"
    echo "  [s] Iniciar servidor web"
    echo "  [d] Excluir relatório"
    echo "  [c] Limpar todos os relatórios"
    echo "  [0] Voltar"
    echo
    echo -n "Escolha uma opção: "
    read -r choice
    
    case "$choice" in
        [1-9]|[1-2][0-9])
            # Abrir relatório específico
            local selected_report=$(find "$reports_dir" -name "*.html" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | sed -n "${choice}p" | cut -d' ' -f2-)
            if [[ -f "$selected_report" ]]; then
                echo "Abrindo relatório: $(basename "$selected_report")"
                open_report "$selected_report"
            else
                echo "❌ Relatório não encontrado."
            fi
            ;;
        "a"|"A")
            # Abrir últimos 5 relatórios
            echo "Abrindo os 5 relatórios mais recentes..."
            local count=0
            for report in $(find "$reports_dir" -name "*.html" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2-); do
                if [[ $count -lt 5 ]]; then
                    open_report "$report"
                    sleep 1  # Pequena pausa entre aberturas
                    ((count++))
                else
                    break
                fi
            done
            ;;
        "s"|"S")
            # Iniciar servidor web
            start_report_server
            echo "Servidor iniciado. Acesse: http://localhost:8080/"
            ;;
        "d"|"D")
            # Excluir relatório específico
            echo -n "Digite o número do relatório para excluir: "
            read -r del_choice
            local del_report=$(find "$reports_dir" -name "*.html" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | sed -n "${del_choice}p" | cut -d' ' -f2-)
            if [[ -f "$del_report" ]]; then
                echo -n "Tem certeza que deseja excluir $(basename "$del_report")? (s/n): "
                read -r confirm
                if [[ "$confirm" == "s" || "$confirm" == "S" ]]; then
                    rm -f "$del_report"
                    echo "✅ Relatório excluído com sucesso."
                else
                    echo "Operação cancelada."
                fi
            else
                echo "❌ Relatório não encontrado."
            fi
            ;;
        "c"|"C")
            # Limpar todos os relatórios
            echo -n "⚠️  Tem certeza que deseja excluir TODOS os relatórios? (s/n): "
            read -r confirm
            if [[ "$confirm" == "s" || "$confirm" == "S" ]]; then
                rm -f "$reports_dir"/*.html 2>/dev/null
                echo "✅ Todos os relatórios foram excluídos."
            else
                echo "Operação cancelada."
            fi
            ;;
        "0")
            return
            ;;
        *)
            echo "❌ Opção inválida."
            ;;
    esac
}

# Função para mostrar detalhes de um relatório específico
show_report_details() {
    local report_file="$1"
    
    if [[ ! -f "$report_file" ]]; then
        echo "❌ Relatório não encontrado: $report_file"
        return 1
    fi
    
    local report_name=$(basename "$report_file" .html)
    
    echo -e "${CYAN}📄 DETALHES DO RELATÓRIO${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Extrair informações do HTML
    local analysis_type=$(grep -o '<strong>Tipo de Análise:</strong> [^<]*' "$report_file" 2>/dev/null | sed 's/<strong>Tipo de Análise:<\/strong> //' | head -1)
    local target=$(grep -o '<strong>Alvo:</strong> [^<]*' "$report_file" 2>/dev/null | sed 's/<strong>Alvo:<\/strong> //' | head -1)
    local timestamp=$(grep -o '<strong>Timestamp:</strong> [^<]*' "$report_file" 2>/dev/null | sed 's/<strong>Timestamp:<\/strong> //' | head -1)
    local overall_status=$(grep -o 'Status Geral</h3>[^<]*<p>[^<]*' "$report_file" 2>/dev/null | sed 's/.*<p>//' | head -1)
    local threat_level=$(grep -o 'Nível de Ameaça</h3>[^<]*<p>[^<]*' "$report_file" 2>/dev/null | sed 's/.*<p>//' | head -1)
    local sources_count=$(grep -o 'Fontes Consultadas</h3>[^<]*<p>[^<]*' "$report_file" 2>/dev/null | sed 's/.*<p>//' | head -1)
    
    # Informações básicas
    echo -e "${YELLOW}ID do Relatório:${NC} $report_name"
    echo -e "${YELLOW}Tipo de Análise:${NC} ${analysis_type:-N/A}"
    echo -e "${YELLOW}Alvo Analisado:${NC} ${target:-N/A}"
    echo -e "${YELLOW}Data/Hora:${NC} ${timestamp:-N/A}"
    echo
    
    # Status com cores
    local status_color=""
    case "$overall_status" in
        *"Limpo"*|*"Seguro"*)
            status_color="${GREEN}"
            ;;
        *"Suspeito"*)
            status_color="${YELLOW}"
            ;;
        *"Malicioso"*|*"Perigoso"*)
            status_color="${RED}"
            ;;
        *)
            status_color="${NC}"
            ;;
    esac
    
    echo -e "${YELLOW}Status Geral:${NC} ${status_color}${overall_status:-N/A}${NC}"
    echo -e "${YELLOW}Nível de Ameaça:${NC} ${threat_level:-N/A}"
    echo -e "${YELLOW}Fontes Consultadas:${NC} ${sources_count:-N/A}"
    echo
    
    # Informações do arquivo
    local file_size=$(du -h "$report_file" 2>/dev/null | cut -f1)
    local file_date=$(stat -c %y "$report_file" 2>/dev/null | cut -d'.' -f1)
    
    echo -e "${BLUE}Informações do Arquivo:${NC}"
    echo -e "  Tamanho: ${file_size:-N/A}"
    echo -e "  Criado em: ${file_date:-N/A}"
    echo -e "  Localização: $report_file"
    echo
    
    # Opções
    echo -e "${CYAN}Opções:${NC}"
    echo "  [1] 🌐 Abrir no navegador"
    echo "  [2] 📋 Copiar caminho do arquivo"
    echo "  [3] 🗑️  Excluir este relatório"
    echo "  [0] 🔙 Voltar"
    echo
    echo -n "Escolha uma opção: "
    read -r choice
    
    case "$choice" in
        1)
            open_report "$report_file"
            ;;
        2)
            echo "$report_file" | xclip -selection clipboard 2>/dev/null || echo "Caminho: $report_file"
            echo "✅ Caminho copiado (ou exibido acima)"
            ;;
        3)
            echo -n "⚠️  Tem certeza que deseja excluir este relatório? (s/n): "
            read -r confirm
            if [[ "$confirm" == "s" || "$confirm" == "S" ]]; then
                rm -f "$report_file"
                echo "✅ Relatório excluído com sucesso."
                return 0
            else
                echo "Operação cancelada."
            fi
            ;;
        0)
            return 0
            ;;
        *)
            echo "❌ Opção inválida."
            ;;
    esac
    
    echo
    echo -n "Pressione Enter para continuar..."
    read
}
manage_reports() {
    while true; do
        echo -e "${CYAN}"
        cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                         GERENCIAMENTO DE RELATÓRIOS                         ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
        echo -e "${NC}"
        echo "  [1] 📋 Listar Relatórios        - Ver relatórios gerados"
        echo "  [2] 🌐 Iniciar Servidor         - Iniciar servidor web"
        echo "  [3] 🛑 Parar Servidor           - Parar servidor web"
        echo "  [4] 🗑️  Excluir Relatório        - Remover relatório específico"
        echo "  [5] 🗑️  Excluir Todos            - Remover todos os relatórios"
        echo
        echo "  [0] 🔙 Voltar                   - Retornar ao menu principal"
        echo
        echo -n "Escolha uma opção: "
        read -r option
        
        case "$option" in
            1)
                list_reports
                ;;
            2)
                start_report_server
                ;;
            3)
                stop_report_server
                ;;
            4)
                echo -n "Digite o ID do relatório a ser excluído: "
                read -r report_id
                if [[ -n "$report_id" && -f "$HOME/.security_analyzer/reports/$report_id.html" ]]; then
                    rm -f "$HOME/.security_analyzer/reports/$report_id.html"
                    echo "Relatório excluído com sucesso."
                else
                    echo "Relatório não encontrado."
                fi
                ;;
            5)
                echo -n "Tem certeza que deseja excluir TODOS os relatórios? (s/n): "
                read -r confirm
                if [[ "$confirm" == "s" || "$confirm" == "S" ]]; then
                    rm -f "$HOME/.security_analyzer/reports"/*.html
                    echo "Todos os relatórios foram excluídos."
                fi
                ;;
            0)
                return
                ;;
            *)
                echo "Opção inválida."
                ;;
        esac
        
        echo
        echo -n "Pressione Enter para continuar..."
        read
    done
}
