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
    
    echo -e "${CYAN}Relatórios Gerados:${NC}"
    echo
    
    if [[ ! -d "$reports_dir" || -z "$(ls -A "$reports_dir")" ]]; then
        echo "Nenhum relatório encontrado."
        return
    fi
    
    echo -e "ID\t\t\tData\t\tTipo\t\tAlvo"
    echo -e "----------------------------------------------------------------------"
    
    for report in "$reports_dir"/*.html; do
        local report_name=$(basename "$report" .html)
        local report_date=$(echo "$report_name" | cut -d'-' -f2)
        local report_date_formatted="${report_date:0:4}-${report_date:4:2}-${report_date:6:2}"
        
        # Extrair tipo e alvo do arquivo HTML
        local analysis_type=$(grep -o '<strong>Tipo de Análise:</strong> [^<]*' "$report" | sed 's/<strong>Tipo de Análise:<\/strong> //')
        local target=$(grep -o '<strong>Alvo:</strong> [^<]*' "$report" | sed 's/<strong>Alvo:<\/strong> //')
        
        echo -e "$report_name\t$report_date_formatted\t$analysis_type\t$target"
    done
    
    echo
    echo -n "Digite o ID do relatório para abrir (ou Enter para voltar): "
    read -r report_id
    
    if [[ -n "$report_id" && -f "$reports_dir/$report_id.html" ]]; then
        open_report "$reports_dir/$report_id.html"
    fi
}

# Função para gerenciar relatórios
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
