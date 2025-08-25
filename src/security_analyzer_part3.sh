# ========================================
# Security Analyzer Tool v3.0 - Parte 3
# Configurações, relatórios e utilitários
# ========================================

# Menu de configuração de APIs
configure_apis_menu() {
    while true; do
        clear
        echo -e "${CYAN}⚙️  CONFIGURAÇÃO DE APIs${NC}"
        echo "========================"
        echo ""
        
        list_configured_apis
        
        echo ""
        echo -e "${YELLOW}OPÇÕES DE CONFIGURAÇÃO${NC}"
        echo "  [1] 🔑 Configurar VirusTotal"
        echo "  [2] 🔑 Configurar URLScan.io"
        echo "  [3] 🔑 Configurar Shodan"
        echo "  [4] 🔑 Configurar ThreatFox"
        echo "  [5] 🧪 Testar Todas as APIs"
        echo "  [6] 🗑️  Remover API"
        echo "  [0] 🔙 Voltar"
        echo ""
        echo -n "➤ "
        read -r api_choice
        
        case "$api_choice" in
            1) configure_api_interactive "virustotal" ;;
            2) configure_api_interactive "urlscan" ;;
            3) configure_api_interactive "shodan" ;;
            4) configure_api_interactive "threatfox" ;;
            5) test_all_apis ;;
            6) remove_api_menu ;;
            0) break ;;
            *) 
                echo -e "${RED}Opção inválida!${NC}"
                sleep 1
                ;;
        esac
        
        if [[ "$api_choice" != "0" ]]; then
            echo ""
            echo "Pressione ENTER para continuar..."
            read -r
        fi
    done
}

# Testar todas as APIs configuradas
test_all_apis() {
    echo -e "${CYAN}🧪 TESTANDO TODAS AS APIs${NC}"
    echo "========================="
    echo ""
    
    local apis_tested=0
    local apis_working=0
    
    for api_name in "${!SUPPORTED_APIS[@]}"; do
        if is_api_configured "$api_name"; then
            echo -n "Testando ${SUPPORTED_APIS[$api_name]}... "
            
            if test_api_connection "$api_name" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ OK${NC}"
                apis_working=$((apis_working + 1))
            else
                echo -e "${RED}❌ FALHA${NC}"
            fi
            
            apis_tested=$((apis_tested + 1))
        fi
    done
    
    echo ""
    echo "Resultado: $apis_working/$apis_tested APIs funcionando"
    
    if [[ $apis_working -eq $apis_tested && $apis_tested -gt 0 ]]; then
        echo -e "${GREEN}🎉 Todas as APIs estão funcionando!${NC}"
    elif [[ $apis_working -eq 0 ]]; then
        echo -e "${RED}❌ Nenhuma API está funcionando${NC}"
    else
        echo -e "${YELLOW}⚠️  Algumas APIs precisam de atenção${NC}"
    fi
}

# Menu para remover APIs
remove_api_menu() {
    echo -e "${CYAN}🗑️  REMOVER CONFIGURAÇÃO DE API${NC}"
    echo "==============================="
    echo ""
    
    local configured_apis=()
    for api_name in "${!SUPPORTED_APIS[@]}"; do
        if is_api_configured "$api_name"; then
            configured_apis+=("$api_name")
        fi
    done
    
    if [[ ${#configured_apis[@]} -eq 0 ]]; then
        echo "Nenhuma API configurada para remover."
        return
    fi
    
    echo "APIs configuradas:"
    local count=1
    for api_name in "${configured_apis[@]}"; do
        echo "  [$count] ${SUPPORTED_APIS[$api_name]}"
        count=$((count + 1))
    done
    
    echo "  [0] Cancelar"
    echo ""
    echo -n "Selecione a API para remover: "
    read -r remove_choice
    
    if [[ "$remove_choice" =~ ^[1-9][0-9]*$ ]] && [[ $remove_choice -le ${#configured_apis[@]} ]]; then
        local api_to_remove="${configured_apis[$((remove_choice - 1))]}"
        
        echo ""
        echo -e "${YELLOW}⚠️  Tem certeza que deseja remover ${SUPPORTED_APIS[$api_to_remove]}? (s/n)${NC}"
        read -r confirm
        
        if [[ "$confirm" =~ ^[Ss]$ ]]; then
            remove_api_key "$api_to_remove"
            echo -e "${GREEN}✅ API removida com sucesso${NC}"
        else
            echo "Operação cancelada"
        fi
    elif [[ "$remove_choice" != "0" ]]; then
        echo -e "${RED}Opção inválida${NC}"
    fi
}

# Menu de relatórios
reports_menu() {
    while true; do
        clear
        echo -e "${CYAN}📊 GERENCIAMENTO DE RELATÓRIOS${NC}"
        echo "=============================="
        echo ""
        
        echo -e "${YELLOW}OPÇÕES DE RELATÓRIOS${NC}"
        echo "  [1] 📋 Listar Relatórios"
        echo "  [2] 🌐 Abrir Relatório"
        echo "  [3] 🗑️  Limpar Relatórios Antigos"
        echo "  [4] 📊 Estatísticas de Relatórios"
        echo "  [0] 🔙 Voltar"
        echo ""
        echo -n "➤ "
        read -r report_choice
        
        case "$report_choice" in
            1) 
                list_reports
                ;;
            2) 
                open_report_menu
                ;;
            3) 
                cleanup_old_reports
                ;;
            4) 
                show_report_statistics
                ;;
            0) 
                break
                ;;
            *) 
                echo -e "${RED}Opção inválida!${NC}"
                sleep 1
                ;;
        esac
        
        if [[ "$report_choice" != "0" ]]; then
            echo ""
            echo "Pressione ENTER para continuar..."
            read -r
        fi
    done
}

# Menu para abrir relatório específico
open_report_menu() {
    echo -e "${CYAN}🌐 ABRIR RELATÓRIO${NC}"
    echo "=================="
    echo ""
    
    local reports=($(find "$REPORTS_DIR" -name "*.html" -type f 2>/dev/null | sort -r))
    
    if [[ ${#reports[@]} -eq 0 ]]; then
        echo "Nenhum relatório encontrado."
        return
    fi
    
    echo "Relatórios disponíveis:"
    local count=1
    for report in "${reports[@]}"; do
        local report_name=$(basename "$report")
        local report_date=$(stat -c %y "$report" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
        
        printf "%2d. %s (%s)\n" "$count" "$report_name" "$report_date"
        count=$((count + 1))
    done
    
    echo "  [0] Cancelar"
    echo ""
    echo -n "Selecione o relatório para abrir: "
    read -r report_choice
    
    if [[ "$report_choice" =~ ^[1-9][0-9]*$ ]] && [[ $report_choice -le ${#reports[@]} ]]; then
        local selected_report="${reports[$((report_choice - 1))]}"
        echo ""
        echo -e "${YELLOW}Abrindo relatório...${NC}"
        open_report_controlled "$selected_report"
    elif [[ "$report_choice" != "0" ]]; then
        echo -e "${RED}Opção inválida${NC}"
    fi
}

# Mostrar estatísticas de relatórios
show_report_statistics() {
    echo -e "${CYAN}📊 ESTATÍSTICAS DE RELATÓRIOS${NC}"
    echo "============================="
    echo ""
    
    if [[ ! -d "$REPORTS_DIR" ]]; then
        echo "Diretório de relatórios não encontrado."
        return
    fi
    
    local total_reports=$(find "$REPORTS_DIR" -name "*.html" -type f 2>/dev/null | wc -l)
    local total_size=$(du -sh "$REPORTS_DIR" 2>/dev/null | cut -f1)
    
    echo "📋 Total de relatórios: $total_reports"
    echo "💾 Espaço utilizado: $total_size"
    
    if [[ $total_reports -gt 0 ]]; then
        echo ""
        echo "📅 Relatórios por período:"
        
        # Últimos 7 dias
        local last_week=$(find "$REPORTS_DIR" -name "*.html" -type f -mtime -7 2>/dev/null | wc -l)
        echo "  Última semana: $last_week"
        
        # Último mês
        local last_month=$(find "$REPORTS_DIR" -name "*.html" -type f -mtime -30 2>/dev/null | wc -l)
        echo "  Último mês: $last_month"
        
        # Mais antigos
        local older=$(find "$REPORTS_DIR" -name "*.html" -type f -mtime +30 2>/dev/null | wc -l)
        echo "  Mais antigos: $older"
    fi
}

# Menu de estatísticas gerais
show_statistics() {
    clear
    echo -e "${CYAN}📈 ESTATÍSTICAS DO SISTEMA${NC}"
    echo "=========================="
    echo ""
    
    # Estatísticas de logs
    echo -e "${BLUE}📝 Logs${NC}"
    analyze_logs
    
    echo ""
    echo -e "${BLUE}📊 Relatórios${NC}"
    show_report_statistics
    
    echo ""
    echo -e "${BLUE}🔑 APIs${NC}"
    local configured_apis=0
    local working_apis=0
    
    for api_name in "${!SUPPORTED_APIS[@]}"; do
        if is_api_configured "$api_name"; then
            configured_apis=$((configured_apis + 1))
            
            if test_api_connection "$api_name" >/dev/null 2>&1; then
                working_apis=$((working_apis + 1))
            fi
        fi
    done
    
    echo "APIs configuradas: $configured_apis/${#SUPPORTED_APIS[@]}"
    echo "APIs funcionando: $working_apis/$configured_apis"
    
    echo ""
    echo -e "${BLUE}💾 Sistema${NC}"
    echo "Versão: $APP_VERSION"
    echo "Diretório de configuração: $CONFIG_DIR"
    
    local config_size=$(du -sh "$CONFIG_DIR" 2>/dev/null | cut -f1)
    echo "Espaço utilizado: $config_size"
}

# Menu de logs
logs_menu() {
    while true; do
        clear
        echo -e "${CYAN}📝 VISUALIZAÇÃO DE LOGS${NC}"
        echo "======================"
        echo ""
        
        echo -e "${YELLOW}OPÇÕES DE LOGS${NC}"
        echo "  [1] 📄 Ver Logs Recentes"
        echo "  [2] 🔍 Buscar nos Logs"
        echo "  [3] 📊 Estatísticas de Logs"
        echo "  [4] 🔄 Monitorar em Tempo Real"
        echo "  [5] 📤 Exportar Logs"
        echo "  [6] 🗑️  Limpar Logs Antigos"
        echo "  [0] 🔙 Voltar"
        echo ""
        echo -n "➤ "
        read -r log_choice
        
        case "$log_choice" in
            1) 
                echo ""
                echo -e "${CYAN}📄 LOGS RECENTES (últimas 50 linhas)${NC}"
                echo "===================================="
                tail -50 "$LOG_FILE" 2>/dev/null || echo "Arquivo de log não encontrado"
                ;;
            2) 
                echo ""
                echo "Digite o termo para buscar:"
                read -r search_term
                echo ""
                echo -e "${CYAN}🔍 RESULTADOS DA BUSCA${NC}"
                echo "====================="
                search_logs "$search_term"
                ;;
            3) 
                echo ""
                analyze_logs
                ;;
            4) 
                echo ""
                echo -e "${CYAN}🔄 MONITORAMENTO EM TEMPO REAL${NC}"
                echo "=============================="
                echo "Pressione Ctrl+C para parar"
                echo ""
                tail_logs
                ;;
            5) 
                echo ""
                echo "Digite o nome do arquivo para exportar:"
                read -r export_file
                export_logs "" "" "$export_file"
                ;;
            6) 
                cleanup_old_logs
                ;;
            0) 
                break
                ;;
            *) 
                echo -e "${RED}Opção inválida!${NC}"
                sleep 1
                ;;
        esac
        
        if [[ "$log_choice" != "0" && "$log_choice" != "4" ]]; then
            echo ""
            echo "Pressione ENTER para continuar..."
            read -r
        fi
    done
}

# Menu de manutenção
maintenance_menu() {
    clear
    echo -e "${CYAN}🔧 MANUTENÇÃO DO SISTEMA${NC}"
    echo "======================="
    echo ""
    
    echo -e "${YELLOW}OPÇÕES DE MANUTENÇÃO${NC}"
    echo "  [1] 🗑️  Limpar Cache"
    echo "  [2] 📊 Limpar Relatórios Antigos"
    echo "  [3] 📝 Limpar Logs Antigos"
    echo "  [4] 🔄 Verificar Integridade"
    echo "  [5] 📦 Backup de Configurações"
    echo "  [6] 🧹 Limpeza Completa"
    echo "  [0] 🔙 Voltar"
    echo ""
    echo -n "➤ "
    read -r maintenance_choice
    
    case "$maintenance_choice" in
        1) 
            echo ""
            echo -e "${YELLOW}🗑️  Limpando cache...${NC}"
            rm -rf "$CACHE_DIR"/*
            create_secure_directory "$CACHE_DIR"
            echo -e "${GREEN}✅ Cache limpo${NC}"
            ;;
        2) 
            echo ""
            cleanup_old_reports
            ;;
        3) 
            echo ""
            cleanup_old_logs
            ;;
        4) 
            echo ""
            echo -e "${YELLOW}🔄 Verificando integridade...${NC}"
            check_system_dependencies
            ;;
        5) 
            echo ""
            backup_configurations
            ;;
        6) 
            echo ""
            full_cleanup
            ;;
        0) 
            return
            ;;
        *) 
            echo -e "${RED}Opção inválida!${NC}"
            ;;
    esac
    
    if [[ "$maintenance_choice" != "0" ]]; then
        echo ""
        echo "Pressione ENTER para continuar..."
        read -r
    fi
}

# Backup de configurações
backup_configurations() {
    echo -e "${YELLOW}📦 Criando backup de configurações...${NC}"
    
    local backup_dir="$HOME/security_analyzer_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Copiar configurações (sem chaves de API por segurança)
    cp -r "$CONFIG_DIR" "$backup_dir/" 2>/dev/null || true
    
    # Remover chaves de API do backup
    rm -f "$backup_dir/.security_analyzer/api_keys.enc" 2>/dev/null
    
    # Criar arquivo de informações
    cat > "$backup_dir/backup_info.txt" << EOF
Security Analyzer Tool - Backup
Data: $(date)
Versão: $APP_VERSION
Sistema: $(uname -a)

Conteúdo:
- Logs de análise
- Relatórios HTML
- Cache (se aplicável)

NOTA: Chaves de API não foram incluídas por segurança
EOF
    
    echo -e "${GREEN}✅ Backup criado em: $backup_dir${NC}"
}

# Limpeza completa
full_cleanup() {
    echo -e "${YELLOW}🧹 Executando limpeza completa...${NC}"
    echo ""
    
    echo "⚠️  Esta operação irá:"
    echo "  - Limpar todo o cache"
    echo "  - Remover relatórios antigos"
    echo "  - Limpar logs antigos"
    echo "  - Otimizar arquivos de configuração"
    echo ""
    echo "Deseja continuar? (s/n)"
    read -r confirm_cleanup
    
    if [[ "$confirm_cleanup" =~ ^[Ss]$ ]]; then
        # Limpar cache
        rm -rf "$CACHE_DIR"/*
        create_secure_directory "$CACHE_DIR"
        echo "✅ Cache limpo"
        
        # Limpar relatórios antigos
        cleanup_old_reports
        
        # Limpar logs antigos
        cleanup_old_logs
        
        echo ""
        echo -e "${GREEN}🎉 Limpeza completa concluída!${NC}"
    else
        echo "Operação cancelada"
    fi
}
